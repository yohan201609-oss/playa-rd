import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';

/// Servicio para obtener datos del clima desde OpenWeatherMap API
/// Incluye caché local para reducir llamadas a la API
class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Duración del caché: 45 minutos (OpenWeatherMap actualiza cada 10 min)
  static const Duration _cacheDuration = Duration(minutes: 45);

  /// Obtiene la API key desde las variables de entorno
  static String get _apiKey {
    final key = dotenv.env['OPENWEATHER_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
          'OPENWEATHER_API_KEY no encontrada. Asegúrate de configurar el archivo .env');
    }
    return key;
  }

  /// Obtiene datos del clima para unas coordenadas específicas
  /// Intenta primero obtener desde caché, si no está disponible o expiró, consulta la API
  Future<WeatherData> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
    String language = 'es',
  }) async {
    final cacheKey = _getCacheKey(latitude, longitude, language);

    // Intentar obtener desde caché si no se fuerza refresh
    if (!forceRefresh) {
      final cachedData = await _getCachedWeather(cacheKey);
      if (cachedData != null) {
        print('✅ Clima obtenido desde caché para ($latitude, $longitude)');
        return cachedData;
      }
    }

    // Si no hay caché o está expirado, consultar la API
    try {
      print('🌐 Consultando API del clima para ($latitude, $longitude) en idioma: $language');
      final weatherData =
          await _fetchWeatherFromAPI(latitude: latitude, longitude: longitude, language: language);

      // Guardar en caché
      await _cacheWeather(cacheKey, weatherData);

      return weatherData;
    } catch (e) {
      // Si falla la API, intentar retornar datos cacheados aunque estén expirados
      final cachedData = await _getCachedWeather(cacheKey, ignoreExpiry: true);
      if (cachedData != null) {
        print('⚠️ Usando datos de caché expirados debido a error en API');
        return cachedData;
      }
      rethrow; // Si no hay caché, lanzar el error
    }
  }

  /// Consulta la API de OpenWeatherMap
  Future<WeatherData> _fetchWeatherFromAPI({
    required double latitude,
    required double longitude,
    String language = 'es',
  }) async {
    // Primero obtenemos los datos básicos del clima
    final weatherUrl = Uri.parse(
      '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=$language',
    );

    final weatherResponse = await http.get(weatherUrl).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Timeout al consultar el clima'),
        );

    if (weatherResponse.statusCode != 200) {
      throw Exception(
          'Error al obtener clima: ${weatherResponse.statusCode} - ${weatherResponse.body}');
    }

    final weatherJson = json.decode(weatherResponse.body);

    // Intentar obtener datos adicionales con One Call API (incluye UV index)
    // Nota: One Call 3.0 requiere plan de pago, pero podemos intentar 2.5
    try {
      final oneCallUrl = Uri.parse(
        '$_baseUrl/onecall?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=$language&exclude=minutely,hourly,daily,alerts',
      );

      final oneCallResponse = await http.get(oneCallUrl).timeout(
            const Duration(seconds: 10),
          );

      if (oneCallResponse.statusCode == 200) {
        final oneCallJson = json.decode(oneCallResponse.body);
        // Agregar datos de UV index si están disponibles
        if (oneCallJson['current'] != null &&
            oneCallJson['current']['uvi'] != null) {
          weatherJson['uvi'] = oneCallJson['current']['uvi'];
        }
      }
    } catch (e) {
      print('ℹ️ No se pudo obtener índice UV (puede requerir plan premium): $e');
      // Continuar sin UV index
    }

    return WeatherData.fromJson(weatherJson);
  }

  /// Obtiene la clave para el caché basada en coordenadas e idioma
  String _getCacheKey(double latitude, double longitude, String language) {
    // Redondear a 2 decimales para que playas cercanas compartan caché
    final lat = latitude.toStringAsFixed(2);
    final lon = longitude.toStringAsFixed(2);
    return 'weather_${lat}_${lon}_$language';
  }

  /// Obtiene datos del clima desde caché local
  Future<WeatherData?> _getCachedWeather(
    String cacheKey, {
    bool ignoreExpiry = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);

      if (cachedData == null) return null;

      final Map<String, dynamic> dataMap = json.decode(cachedData);
      final WeatherData weather = WeatherData.fromCache(dataMap);

      // Verificar si el caché expiró
      if (!ignoreExpiry) {
        final age = DateTime.now().difference(weather.timestamp);
        if (age > _cacheDuration) {
          print('⏰ Caché expirado (${age.inMinutes} minutos)');
          return null;
        }
      }

      return weather;
    } catch (e) {
      print('⚠️ Error al leer caché: $e');
      return null;
    }
  }

  /// Guarda datos del clima en caché local
  Future<void> _cacheWeather(String cacheKey, WeatherData weather) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(weather.toJson());
      await prefs.setString(cacheKey, jsonData);
      print('💾 Clima guardado en caché');
    } catch (e) {
      print('⚠️ Error al guardar en caché: $e');
      // No lanzar error, el caché es opcional
    }
  }

  /// Limpia el caché de clima
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('weather_')) {
          await prefs.remove(key);
        }
      }
      print('🗑️ Caché de clima limpiado');
    } catch (e) {
      print('⚠️ Error al limpiar caché: $e');
    }
  }

  /// Precarga el clima para múltiples ubicaciones (batch)
  /// Útil para cargar el clima de varias playas a la vez
  Future<Map<String, WeatherData>> batchGetWeather(
    List<Map<String, dynamic>> locations,
  ) async {
    final results = <String, WeatherData>{};

    // Procesar en lotes de 5 para no saturar la API
    const batchSize = 5;
    for (var i = 0; i < locations.length; i += batchSize) {
      final batch = locations.skip(i).take(batchSize).toList();

      final futures = batch.map((location) async {
        final lat = location['latitude']!;
        final lon = location['longitude']!;
        final lang = location['language'] as String? ?? 'es';
        try {
          final weather = await getWeatherByCoordinates(
            latitude: lat,
            longitude: lon,
            language: lang,
          );
          return MapEntry('${lat}_$lon', weather);
        } catch (e) {
          print('⚠️ Error obteniendo clima para ($lat, $lon): $e');
          return null;
        }
      });

      final batchResults = await Future.wait(futures);
      for (final result in batchResults) {
        if (result != null) {
          results[result.key] = result.value;
        }
      }

      // Pequeña pausa entre lotes para respetar rate limits
      if (i + batchSize < locations.length) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    return results;
  }

  /// Verifica si la API key está configurada
  static bool isConfigured() {
    try {
      return dotenv.env['OPENWEATHER_API_KEY']?.isNotEmpty ?? false;
    } catch (e) {
      return false;
    }
  }
}


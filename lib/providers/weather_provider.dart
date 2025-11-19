import 'package:flutter/foundation.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

/// Provider para gestionar el estado del clima en la aplicación
class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  // Mapa para almacenar el clima de cada playa (key: "lat_lon")
  final Map<String, WeatherData> _weatherCache = {};

  // Mapa para rastrear el estado de carga de cada ubicación
  final Map<String, bool> _loadingStates = {};

  // Mapa para rastrear errores por ubicación
  final Map<String, String?> _errors = {};

  /// Obtiene el clima para una ubicación específica
  WeatherData? getWeatherForLocation(double latitude, double longitude) {
    final key = _getLocationKey(latitude, longitude);
    return _weatherCache[key];
  }

  /// Verifica si se está cargando el clima para una ubicación
  bool isLoadingForLocation(double latitude, double longitude) {
    final key = _getLocationKey(latitude, longitude);
    return _loadingStates[key] ?? false;
  }

  /// Obtiene el error (si existe) para una ubicación
  String? getErrorForLocation(double latitude, double longitude) {
    final key = _getLocationKey(latitude, longitude);
    return _errors[key];
  }

  /// Carga el clima para una playa específica
  Future<void> fetchWeatherForBeach({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
    String? language,
  }) async {
    final key = _getLocationKey(latitude, longitude);
    final lang = language ?? 'es';

    // Si ya tenemos datos y no se fuerza refresh, no hacer nada
    if (!forceRefresh && _weatherCache.containsKey(key)) {
      return;
    }

    // Marcar como cargando
    _loadingStates[key] = true;
    _errors[key] = null;
    notifyListeners();

    try {
      final weather = await _weatherService.getWeatherByCoordinates(
        latitude: latitude,
        longitude: longitude,
        forceRefresh: forceRefresh,
        language: lang,
      );

      _weatherCache[key] = weather;
      _errors[key] = null;
    } catch (e) {
      _errors[key] = _parseError(e);
      print('❌ Error al obtener clima: $e');
    } finally {
      _loadingStates[key] = false;
      notifyListeners();
    }
  }

  /// Carga el clima para múltiples playas (optimizado)
  Future<void> fetchWeatherForMultipleBeaches(
    List<Map<String, dynamic>> locations, {
    bool forceRefresh = false,
    String? language,
  }) async {
    final lang = language ?? 'es';
    
    // Filtrar las ubicaciones que ya tienen datos (si no se fuerza refresh)
    final locationsToFetch = forceRefresh
        ? locations
        : locations.where((loc) {
            final key = _getLocationKey(loc['latitude']!, loc['longitude']!);
            return !_weatherCache.containsKey(key);
          }).toList();

    if (locationsToFetch.isEmpty) return;

    // Agregar idioma a cada ubicación
    final locationsWithLang = locationsToFetch.map((loc) {
      return {
        'latitude': loc['latitude'],
        'longitude': loc['longitude'],
        'language': lang,
      };
    }).toList();

    // Marcar todas como cargando
    for (final loc in locationsToFetch) {
      final key = _getLocationKey(loc['latitude']!, loc['longitude']!);
      _loadingStates[key] = true;
      _errors[key] = null;
    }
    notifyListeners();

    try {
      final results = await _weatherService.batchGetWeather(locationsWithLang);

      // Actualizar caché con resultados
      for (final entry in results.entries) {
        _weatherCache[entry.key] = entry.value;
      }
    } catch (e) {
      print('❌ Error en batch fetch: $e');
    } finally {
      // Desmarcar todas como cargando
      for (final loc in locationsToFetch) {
        final key = _getLocationKey(loc['latitude']!, loc['longitude']!);
        _loadingStates[key] = false;
      }
      notifyListeners();
    }
  }

  /// Refresca el clima para una ubicación
  Future<void> refreshWeather(double latitude, double longitude, {String? language}) async {
    return fetchWeatherForBeach(
      latitude: latitude,
      longitude: longitude,
      forceRefresh: true,
      language: language,
    );
  }

  /// Limpia todos los datos de clima
  Future<void> clearAllWeather() async {
    _weatherCache.clear();
    _loadingStates.clear();
    _errors.clear();
    await _weatherService.clearCache();
    notifyListeners();
  }

  /// Genera una clave única para una ubicación (redondeando a 2 decimales)
  String _getLocationKey(double latitude, double longitude) {
    final lat = latitude.toStringAsFixed(2);
    final lon = longitude.toStringAsFixed(2);
    return '${lat}_$lon';
  }

  /// Parsea el error a un mensaje amigable
  String _parseError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('timeout')) {
      return 'Tiempo de espera agotado';
    }
    if (errorStr.contains('socket') || errorStr.contains('network')) {
      return 'Sin conexión a internet';
    }
    if (errorStr.contains('401')) {
      return 'API key inválida';
    }
    if (errorStr.contains('429')) {
      return 'Límite de consultas excedido';
    }
    if (errorStr.contains('api_key')) {
      return 'API key no configurada';
    }

    return 'Error al obtener el clima';
  }

  /// Verifica si el servicio de clima está configurado
  bool get isWeatherServiceConfigured {
    return WeatherService.isConfigured();
  }

  /// Obtiene estadísticas del caché
  Map<String, int> get cacheStats {
    return {
      'total': _weatherCache.length,
      'loading': _loadingStates.values.where((v) => v).length,
      'errors': _errors.values.where((v) => v != null).length,
    };
  }
}


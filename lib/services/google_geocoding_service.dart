import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio para obtener coordenadas precisas usando Google Geocoding API
class GoogleGeocodingService {
  // Obtener la API key desde variables de entorno
  static String? get _apiKey {
    try {
      // Intentar diferentes nombres de variables comunes
      String? envKey;
      String? keyName;
      
      // Prioridad 1: GOOGLE_MAPS_API_KEY (nombre estándar)
      envKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (envKey != null && envKey.trim().isNotEmpty) {
        keyName = 'GOOGLE_MAPS_API_KEY';
      }
      
      // Prioridad 2: MAPS_API_KEY (nombre alternativo común)
      if (envKey == null || envKey.trim().isEmpty) {
        envKey = dotenv.env['MAPS_API_KEY'];
        if (envKey != null && envKey.trim().isNotEmpty) {
          keyName = 'MAPS_API_KEY';
        }
      }
      
      // Prioridad 3: GOOGLE_API_KEY (otra variante)
      if (envKey == null || envKey.trim().isEmpty) {
        envKey = dotenv.env['GOOGLE_API_KEY'];
        if (envKey != null && envKey.trim().isNotEmpty) {
          keyName = 'GOOGLE_API_KEY';
        }
      }
      
      if (envKey != null && keyName != null) {
        // Limpiar espacios en blanco
        final cleanKey = envKey.trim();
        if (cleanKey.isNotEmpty) {
          print('✅ Usando Google Maps API Key desde .env (variable: $keyName, ${cleanKey.length} caracteres)');
          return cleanKey;
        } else {
          print('⚠️ API Key en .env está vacía o contiene solo espacios');
        }
      } else {
        print('⚠️ Variables de API Key no encontradas en .env');
        print('⚠️ Buscadas: GOOGLE_MAPS_API_KEY, MAPS_API_KEY, GOOGLE_API_KEY');
        print('🔍 Variables disponibles: ${dotenv.env.keys.join(", ")}');
      }
    } catch (e) {
      print('⚠️ Error accediendo a dotenv: $e');
    }
    
    // No hay fallback - la key debe estar en .env
    print('❌ Google Maps API Key no disponible. Asegúrate de configurar GOOGLE_MAPS_API_KEY en .env');
    return null;
  }
  
  // Método público para verificar si la API key está configurada
  static String? get apiKey => _apiKey;

  /// Obtener coordenadas precisas desde una dirección o nombre de lugar
  /// 
  /// [query] puede ser:
  /// - Nombre de la playa: "Playa Bávaro"
  /// - Dirección completa: "Playa Bávaro, Punta Cana, La Altagracia, República Dominicana"
  /// - Coordenadas aproximadas para refinar: "Playa Bávaro, 18.6825, -68.4276"
  /// 
  /// Retorna un Map con 'latitude', 'longitude', 'formatted_address' y 'place_id' o null si hay error
  static Future<Map<String, dynamic>?> getCoordinatesFromQuery(
    String query, {
    String? region,
    String? province,
    String? municipality,
  }) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        print('⚠️ Google Maps API Key no configurada');
        return null;
      }

      // Construir la query de búsqueda mejorada
      String searchQuery = query;
      
      // Agregar contexto geográfico para mejorar la precisión
      if (municipality != null && municipality.isNotEmpty) {
        searchQuery += ', $municipality';
      }
      if (province != null && province.isNotEmpty) {
        searchQuery += ', $province';
      }
      if (region == null || region.isEmpty) {
        searchQuery += ', República Dominicana';
      } else {
        searchQuery += ', $region';
      }

      // URL de la API de Geocoding
      final encodedQuery = Uri.encodeComponent(searchQuery);
      final url = 
          'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedQuery&key=$apiKey&region=do';

      print('🔍 Buscando coordenadas para: $searchQuery');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];
          
          final latitude = (location['lat'] as num).toDouble();
          final longitude = (location['lng'] as num).toDouble();
          
          // Obtener información adicional de la respuesta
          final formattedAddress = result['formatted_address'] ?? '';
          final placeId = result['place_id'] ?? '';
          
          print('✅ Coordenadas encontradas: $latitude, $longitude');
          print('📍 Dirección: $formattedAddress');
          print('🆔 Place ID: $placeId');

          return {
            'latitude': latitude,
            'longitude': longitude,
            'formatted_address': formattedAddress,
            'place_id': placeId,
          };
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('⚠️ No se encontraron resultados para: $searchQuery');
          return null;
        } else {
          print('⚠️ Error en la API: ${data['status']}');
          print('📄 Respuesta completa: ${data['error_message'] ?? 'Sin mensaje de error'}');
          return null;
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        print('📄 Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo coordenadas: $e');
      return null;
    }
  }

  /// Obtener coordenadas usando Google Places API (más preciso para lugares específicos)
  /// 
  /// Esta función busca específicamente playas y lugares turísticos
  static Future<Map<String, dynamic>?> getCoordinatesFromPlace(
    String placeName, {
    String? province,
    String? municipality,
    double? approximateLatitude,
    double? approximateLongitude,
  }) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        print('⚠️ Google Maps API Key no configurada');
        return null;
      }

      // Construir query para Places API
      String searchQuery = placeName;
      if (municipality != null && municipality.isNotEmpty) {
        searchQuery += ' $municipality';
      }
      if (province != null && province.isNotEmpty) {
        searchQuery += ' $province';
      }
      searchQuery += ' República Dominicana playa beach';

      // URL de Places API Text Search
      final encodedQuery = Uri.encodeComponent(searchQuery);
      String url = 
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&key=$apiKey';

      // Si tenemos coordenadas aproximadas, agregarlas para mejorar la búsqueda
      if (approximateLatitude != null && approximateLongitude != null) {
        url += '&location=$approximateLatitude,$approximateLongitude&radius=50000';
      }

      print('🔍 Buscando lugar en Places API: $searchQuery');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];
          
          final latitude = (location['lat'] as num).toDouble();
          final longitude = (location['lng'] as num).toDouble();
          
          final name = result['name'] ?? '';
          final formattedAddress = result['formatted_address'] ?? '';
          final placeId = result['place_id'] ?? '';
          final rating = result['rating'] ?? 0.0;
          
          print('✅ Lugar encontrado: $name');
          print('📍 Coordenadas: $latitude, $longitude');
          print('📍 Dirección: $formattedAddress');
          print('⭐ Rating: $rating');
          print('🆔 Place ID: $placeId');

          return {
            'latitude': latitude,
            'longitude': longitude,
            'formatted_address': formattedAddress,
            'place_id': placeId,
            'name': name,
            'rating': rating,
          };
        } else {
          print('⚠️ No se encontró el lugar en Places API: ${data['status']}');
          // Intentar con Geocoding API como fallback
          return await getCoordinatesFromQuery(
            placeName,
            province: province,
            municipality: municipality,
          );
        }
      } else {
        print('❌ Error HTTP en Places API: ${response.statusCode}');
        // Intentar con Geocoding API como fallback
        return await getCoordinatesFromQuery(
          placeName,
          province: province,
          municipality: municipality,
        );
      }
    } catch (e) {
      print('❌ Error en Places API: $e');
      // Intentar con Geocoding API como fallback
      return await getCoordinatesFromQuery(
        placeName,
        province: province,
        municipality: municipality,
      );
    }
  }

  /// Obtener información detallada de un lugar usando su Place ID
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      final url = 
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=geometry,formatted_address,name,rating,photos,opening_hours';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo detalles del lugar: $e');
      return null;
    }
  }

  /// Verificar si la API key está configurada y es válida
  static Future<bool> verifyApiKey() async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        print('⚠️ API Key es null o vacía');
        return false;
      }

      // Verificar que la key tenga un formato válido (las keys de Google empiezan con AIzaSy y tienen ~39 caracteres)
      if (apiKey.length < 30) {
        print('⚠️ API Key muy corta (${apiKey.length} caracteres). Una API Key válida de Google tiene ~39 caracteres');
        print('⚠️ Verifica que la API Key esté completa en el archivo .env');
        return false;
      }

      if (!apiKey.startsWith('AIzaSy')) {
        print('⚠️ API Key no tiene el formato correcto. Las keys de Google Maps empiezan con "AIzaSy"');
        print('⚠️ Key actual empieza con: ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}');
        return false;
      }

      // Si la key es el placeholder, no es válida
      if (apiKey.contains('tu_api_key') || apiKey.contains('placeholder') || apiKey == 'tu_api_key_aqui') {
        print('⚠️ API Key es un placeholder. Por favor, reemplázala con tu API Key real');
        return false;
      }

      // Hacer una búsqueda simple para verificar la key (solo si pasa las validaciones anteriores)
      final testUrl = 
          'https://maps.googleapis.com/maps/api/geocode/json?address=Santo%20Domingo&key=$apiKey';
      
      print('🔍 Verificando API Key con Google...');
      final response = await http.get(Uri.parse(testUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        
        if (status == 'REQUEST_DENIED') {
          print('❌ API Key rechazada por Google: ${data['error_message'] ?? 'Sin mensaje de error'}');
          print('⚠️ Verifica que:');
          print('⚠️ 1. La API Key sea correcta');
          print('⚠️ 2. Las APIs (Geocoding API, Places API) estén habilitadas en Google Cloud Console');
          print('⚠️ 3. No haya restricciones de IP o referrer que bloqueen las solicitudes');
          return false;
        } else if (status == 'OK') {
          print('✅ API Key válida y funcionando correctamente');
          return true;
        } else {
          print('⚠️ Respuesta inesperada de Google: $status');
          return false;
        }
      } else {
        print('❌ Error HTTP al verificar API Key: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error verificando API key: $e');
      return false;
    }
  }
}


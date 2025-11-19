import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/beach.dart';

/// Servicio para buscar y obtener playas usando Google Places API
class GooglePlacesService {
  // Obtener la API key
  static String? get _apiKey {
    // Intentar desde .env con diferentes nombres
    final envKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 
                   dotenv.env['MAPS_API_KEY'] ?? 
                   dotenv.env['GOOGLE_API_KEY'];
    
    if (envKey != null && envKey.trim().isNotEmpty) {
      final cleanKey = envKey.trim();
      if (cleanKey.length > 30 && cleanKey.startsWith('AIzaSy')) {
        return cleanKey;
      }
    }
    
    // Fallback al AndroidManifest
    return 'AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus';
  }

  /// Buscar playas en República Dominicana usando Places API
  /// 
  /// Retorna una lista de playas encontradas con sus detalles
  static Future<List<Map<String, dynamic>>> searchBeachesInDominicanRepublic({
    int maxResults = 50,
    String? province,
  }) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        print('❌ API Key no configurada');
        return [];
      }

      final List<Map<String, dynamic>> beaches = [];
      
      // Construir queries de búsqueda
      final queries = _buildSearchQueries(province);
      
      print('🔍 Buscando playas en República Dominicana...');
      print('📊 Queries a ejecutar: ${queries.length}');
      
      for (final query in queries) {
        print('🔍 Buscando: $query');
        
        final results = await _searchPlaces(query, apiKey);
        
        for (final place in results) {
          // Evitar duplicados
          if (!beaches.any((b) => b['place_id'] == place['place_id'])) {
            beaches.add(place);
            print('✅ Playa encontrada: ${place['name']}');
            
            // Limitar resultados
            if (beaches.length >= maxResults) {
              break;
            }
          }
        }
        
        // Pequeña pausa entre búsquedas
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (beaches.length >= maxResults) {
          break;
        }
      }
      
      print('✅ Total de playas encontradas: ${beaches.length}');
      return beaches;
    } catch (e) {
      print('❌ Error buscando playas: $e');
      return [];
    }
  }

  /// Construir queries de búsqueda para diferentes regiones
  static List<String> _buildSearchQueries(String? province) {
    final queries = <String>[];
    
    if (province != null && province.isNotEmpty) {
      // Búsqueda específica por provincia
      queries.add('playa beach $province República Dominicana');
      queries.add('beach $province Dominican Republic');
    } else {
      // Búsquedas generales por regiones
      queries.add('playas República Dominicana');
      queries.add('beaches Dominican Republic');
      queries.add('playa Punta Cana');
      queries.add('playa Bávaro');
      queries.add('playa Samaná');
      queries.add('playa Puerto Plata');
      queries.add('playa La Romana');
      queries.add('playa Barahona');
      queries.add('playa Sosúa');
      queries.add('playa Cabarete');
      queries.add('beach Punta Cana Dominican Republic');
      queries.add('beach Samana Dominican Republic');
      queries.add('beach Puerto Plata Dominican Republic');
    }
    
    return queries;
  }

  /// Buscar lugares usando Places API Text Search
  static Future<List<Map<String, dynamic>>> _searchPlaces(
    String query,
    String apiKey,
  ) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = 
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&key=$apiKey&region=do&language=es';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'] as List;
          
          // Filtrar solo playas (beach) o lugares turísticos relacionados
          return results.where((place) {
            final types = place['types'] as List<dynamic>?;
            if (types == null) return false;
            
            // Buscar tipos relacionados con playas
            return types.any((type) => 
              type.toString().contains('beach') ||
              type.toString().contains('natural_feature') ||
              type.toString().contains('tourist_attraction')
            );
          }).map((place) => place as Map<String, dynamic>).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('⚠️ No se encontraron resultados para: $query');
          return [];
        } else {
          print('⚠️ Error en Places API: ${data['status']}');
          if (data['error_message'] != null) {
            print('📄 Mensaje: ${data['error_message']}');
          }
          return [];
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error en _searchPlaces: $e');
      return [];
    }
  }

  /// Obtener detalles completos de un lugar usando su Place ID
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      // Campos a solicitar (solo los esenciales para evitar INVALID_REQUEST)
      final fields = [
        'name',
        'formatted_address',
        'geometry',
        'rating',
        'user_ratings_total',
        'photos',
        'types',
      ].join(',');

      final url = 
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=$fields&language=es';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['result'] != null) {
          return data['result'] as Map<String, dynamic>;
        } else {
          print('⚠️ Error obteniendo detalles: ${data['status']}');
          return null;
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error en getPlaceDetails: $e');
      return null;
    }
  }

  /// Convertir resultado de Places API a modelo Beach
  static Future<Beach?> convertPlaceToBeach(Map<String, dynamic> place) async {
    try {
      // Obtener detalles completos si no los tenemos
      Map<String, dynamic> placeData = place;
      if (!place.containsKey('reviews') || !place.containsKey('photos')) {
        final placeId = place['place_id'] as String?;
        if (placeId != null) {
          final details = await getPlaceDetails(placeId);
          if (details != null) {
            placeData = details;
          }
        }
      }

      // Extraer información básica
      final name = placeData['name'] as String? ?? 'Playa sin nombre';
      final placeId = placeData['place_id'] as String? ?? '';
      
      // Coordenadas
      final geometry = placeData['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final latitude = location?['lat'] as double? ?? 0.0;
      final longitude = location?['lng'] as double? ?? 0.0;
      
      if (latitude == 0.0 || longitude == 0.0) {
        print('⚠️ Coordenadas inválidas para: $name');
        return null;
      }
      
      // Dirección
      final formattedAddress = placeData['formatted_address'] as String? ?? '';
      
      // Rating y reseñas
      final rating = (placeData['rating'] as num?)?.toDouble() ?? 0.0;
      final reviewCount = placeData['user_ratings_total'] as int? ?? 0;
      
      // Fotos
      final photos = placeData['photos'] as List<dynamic>?;
      final imageUrls = <String>[];
      
      if (photos != null && photos.isNotEmpty && _apiKey != null) {
        // Obtener las primeras 3 fotos
        final maxPhotos = photos.length > 3 ? 3 : photos.length;
        for (int i = 0; i < maxPhotos; i++) {
          final photo = photos[i] as Map<String, dynamic>;
          final photoReference = photo['photo_reference'] as String?;
          if (photoReference != null) {
            // Construir URL de la foto
            final photoUrl = 
                'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photo_reference=$photoReference&key=${_apiKey}';
            imageUrls.add(photoUrl);
          }
        }
      }
      
      // Si no hay fotos, intentar usar imágenes de Unsplash como fallback
      if (imageUrls.isEmpty) {
        // Puedes agregar una imagen genérica de playa si quieres
        // imageUrls.add('https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800');
      }
      
      // Extraer provincia y municipio de la dirección
      final addressParts = formattedAddress.split(',');
      String province = 'República Dominicana';
      String municipality = '';
      
      // Intentar extraer provincia (generalmente antes de "República Dominicana")
      for (int i = addressParts.length - 1; i >= 0; i--) {
        final part = addressParts[i].trim();
        if (part.contains('República Dominicana') || part.contains('Dominican Republic')) {
          if (i > 0) {
            province = addressParts[i - 1].trim();
          }
          if (i > 1) {
            municipality = addressParts[i - 2].trim();
          }
          break;
        }
      }
      
      // Si no se encontró, intentar inferir desde coordenadas o nombre
      if (province == 'República Dominicana') {
        province = _inferProvinceFromCoordinates(latitude, longitude);
      }
      
      // Descripción
      String description = placeData['editorial_summary']?['overview'] as String? ?? 
                          placeData['description'] as String? ?? 
                          'Hermosa playa en República Dominicana';
      
      // Si hay reseñas, usar la primera como descripción adicional
      final reviews = placeData['reviews'] as List<dynamic>?;
      if (reviews != null && reviews.isNotEmpty && description.length < 100) {
        final firstReview = reviews[0] as Map<String, dynamic>;
        final reviewText = firstReview['text'] as String?;
        if (reviewText != null && reviewText.length > description.length) {
          description = reviewText.substring(0, reviewText.length > 200 ? 200 : reviewText.length);
        }
      }
      
      // Tipos para determinar actividades y amenities
      final types = placeData['types'] as List<dynamic>?;
      final activities = <String>[];
      final amenities = <String, bool>{};
      
      if (types != null) {
        // Determinar actividades basadas en tipos
        for (final type in types) {
          final typeStr = type.toString().toLowerCase();
          if (typeStr.contains('beach')) {
            activities.add('Natación');
          }
          if (typeStr.contains('surf')) {
            activities.add('Surf');
          }
          if (typeStr.contains('dive') || typeStr.contains('snorkel')) {
            activities.add('Snorkel');
            activities.add('Buceo');
          }
          if (typeStr.contains('kayak') || typeStr.contains('boat')) {
            activities.add('Kayak');
          }
        }
        
        // Intentar inferir amenities desde reviews o descripción
        // (Google Places API no siempre tiene esta información directamente)
        final descriptionLower = description.toLowerCase();
        if (descriptionLower.contains('restaurante') || descriptionLower.contains('restaurant')) {
          amenities['restaurantes'] = true;
        }
        if (descriptionLower.contains('parking') || descriptionLower.contains('estacionamiento')) {
          amenities['parking'] = true;
        }
        if (descriptionLower.contains('baño') || descriptionLower.contains('bathroom')) {
          amenities['baños'] = true;
        }
        if (descriptionLower.contains('ducha') || descriptionLower.contains('shower')) {
          amenities['duchas'] = true;
        }
      }
      
      // Si no hay actividades, agregar Natación por defecto
      if (activities.isEmpty) {
        activities.add('Natación');
      }
      
      // Crear el modelo Beach
      return Beach(
        id: placeId, // Usar place_id como ID único
        name: name,
        province: province,
        municipality: municipality.isNotEmpty ? municipality : province,
        address: formattedAddress,
        description: description,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
        rating: rating,
        reviewCount: reviewCount,
        currentCondition: 'Desconocido', // Se actualizará con reportes
        amenities: amenities.isNotEmpty ? amenities : {}, // Amenities inferidas desde descripción
        activities: activities.isNotEmpty ? activities : ['Natación'],
      );
    } catch (e) {
      print('❌ Error convirtiendo lugar a Beach: $e');
      return null;
    }
  }

  /// Inferir provincia desde coordenadas
  static String _inferProvinceFromCoordinates(double lat, double lng) {
    // Coordenadas aproximadas de provincias dominicanas
    if (lat >= 18.4 && lat <= 18.9 && lng >= -68.7 && lng <= -68.3) {
      return 'La Altagracia'; // Punta Cana
    } else if (lat >= 19.1 && lat <= 19.4 && lng >= -69.6 && lng <= -69.1) {
      return 'Samaná';
    } else if (lat >= 19.7 && lat <= 19.8 && lng >= -70.7 && lng <= -70.4) {
      return 'Puerto Plata';
    } else if (lat >= 18.4 && lat <= 18.5 && lng >= -69.7 && lng <= -69.5) {
      return 'Santo Domingo';
    } else if (lat >= 18.0 && lat <= 18.3 && lng >= -71.2 && lng <= -70.9) {
      return 'Barahona';
    } else if (lat >= 17.8 && lat <= 18.0 && lng >= -71.7 && lng <= -71.5) {
      return 'Pedernales';
    }
    
    return 'República Dominicana'; // Por defecto
  }

  /// Buscar playas y convertirlas a modelos Beach
  static Future<List<Beach>> searchAndConvertBeaches({
    int maxResults = 50,
    String? province,
    Function(int current, int total, String name)? onProgress,
  }) async {
    try {
      print('🔍 Iniciando búsqueda de playas...');
      
      // Buscar playas
      final places = await searchBeachesInDominicanRepublic(
        maxResults: maxResults,
        province: province,
      );
      
      if (places.isEmpty) {
        print('⚠️ No se encontraron playas');
        return [];
      }
      
      print('✅ ${places.length} lugares encontrados, obteniendo detalles...');
      
      final List<Beach> beaches = [];
      
      for (int i = 0; i < places.length; i++) {
        final place = places[i];
        final name = place['name'] as String? ?? 'Desconocido';
        
        // Reportar progreso
        if (onProgress != null) {
          onProgress(i + 1, places.length, name);
        }
        
        print('🔄 Procesando ${i + 1}/${places.length}: $name');
        
        // Convertir a Beach
        final beach = await convertPlaceToBeach(place);
        
        if (beach != null) {
          beaches.add(beach);
          print('✅ Playa agregada: ${beach.name}');
        } else {
          print('⚠️ No se pudo convertir: $name');
        }
        
        // Pausa entre solicitudes
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      print('✅ Total de playas procesadas: ${beaches.length}');
      return beaches;
    } catch (e) {
      print('❌ Error en searchAndConvertBeaches: $e');
      return [];
    }
  }

  /// Buscar una playa específica por nombre y ubicación
  /// Retorna el Place ID si se encuentra, o null si no se encuentra
  static Future<String?> findBeachPlaceId(
    String beachName, {
    String? province,
    String? municipality,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      // Construir query de búsqueda
      String query = beachName;
      if (municipality != null && municipality.isNotEmpty) {
        query += ' $municipality';
      }
      if (province != null && province.isNotEmpty) {
        query += ' $province';
      }
      query += ' República Dominicana beach playa';

      // Usar Text Search API
      final encodedQuery = Uri.encodeComponent(query);
      String url = 
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&key=$apiKey&region=do&language=es';

      // Si tenemos coordenadas, agregar bias para mejorar resultados
      if (latitude != null && longitude != null) {
        url += '&location=$latitude,$longitude&radius=10000'; // 10km radius
      }

      print('🔍 Buscando: $beachName');
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'] as List;
          
          // Filtrar solo playas (beach) o lugares relacionados
          final beachResults = results.where((place) {
            final types = place['types'] as List<dynamic>?;
            if (types == null) return false;
            
            return types.any((type) => 
              type.toString().contains('beach') ||
              type.toString().contains('natural_feature') ||
              type.toString().contains('tourist_attraction')
            );
          }).toList();

          if (beachResults.isNotEmpty) {
            // Tomar el primer resultado (el más relevante)
            final placeId = beachResults[0]['place_id'] as String?;
            if (placeId != null) {
              print('✅ Place ID encontrado para: $beachName');
              return placeId;
            }
          }
        }
        
        print('⚠️ No se encontró Place ID para: $beachName');
        return null;
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error buscando Place ID: $e');
      return null;
    }
  }

  /// Obtener fotos de una playa usando su nombre y ubicación
  /// Retorna una lista de URLs de fotos
  static Future<List<String>> getBeachPhotos(
    String beachName, {
    String? province,
    String? municipality,
    double? latitude,
    double? longitude,
    int maxPhotos = 5,
  }) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        return [];
      }

      // Buscar Place ID
      final placeId = await findBeachPlaceId(
        beachName,
        province: province,
        municipality: municipality,
        latitude: latitude,
        longitude: longitude,
      );

      if (placeId == null) {
        print('⚠️ No se encontró Place ID para: $beachName');
        return [];
      }

      // Obtener detalles del lugar (solo fotos)
      final details = await getPlaceDetails(placeId);
      if (details == null) {
        return [];
      }

      // Extraer fotos
      final photos = details['photos'] as List<dynamic>?;
      final imageUrls = <String>[];

      if (photos != null && photos.isNotEmpty) {
        // Obtener hasta maxPhotos fotos
        final photoCount = photos.length > maxPhotos ? maxPhotos : photos.length;
        for (int i = 0; i < photoCount; i++) {
          final photo = photos[i] as Map<String, dynamic>;
          final photoReference = photo['photo_reference'] as String?;
          if (photoReference != null) {
            // Construir URL de la foto
            final photoUrl = 
                'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1200&photo_reference=$photoReference&key=$apiKey';
            imageUrls.add(photoUrl);
          }
        }
      }

      print('📸 ${imageUrls.length} foto(s) encontrada(s) para: $beachName');
      return imageUrls;
    } catch (e) {
      print('❌ Error obteniendo fotos: $e');
      return [];
    }
  }

  /// Generar URL de imagen estática del mapa usando Google Maps Static API
  /// Útil cuando no hay fotos disponibles de la playa
  static String generateStaticMapImageUrl({
    required double latitude,
    required double longitude,
    required String beachName,
    int width = 800,
    int height = 600,
    int zoom = 15,
    String mapType = 'satellite', // roadmap, satellite, hybrid, terrain
  }) {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      print('⚠️ API Key no configurada para Static Maps');
      return '';
    }

    // Construir URL de Static Maps API
    // Formato: https://maps.googleapis.com/maps/api/staticmap?center=lat,lng&zoom=15&size=800x600&maptype=satellite&markers=color:red|label:B|lat,lng&key=API_KEY
    final url = 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$latitude,$longitude'
        '&zoom=$zoom'
        '&size=${width}x$height'
        '&maptype=$mapType'
        '&markers=color:blue%7Clabel:B%7C$latitude,$longitude'
        '&key=$apiKey';
    
    return url;
  }

  /// Obtener solo las fotos usando un Place ID
  /// Útil cuando ya tenemos el Place ID
  static Future<List<String>> getPhotosFromPlaceId(
    String placeId, {
    int maxPhotos = 5,
  }) async {
    try {
      final apiKey = _apiKey;
      if (apiKey == null || apiKey.isEmpty) {
        return [];
      }

      // Obtener detalles del lugar (solo fotos)
      final url = 
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=photos&language=es';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'] as Map<String, dynamic>;
          final photos = result['photos'] as List<dynamic>?;
          final imageUrls = <String>[];

          if (photos != null && photos.isNotEmpty) {
            // Obtener hasta maxPhotos fotos
            final photoCount = photos.length > maxPhotos ? maxPhotos : photos.length;
            for (int i = 0; i < photoCount; i++) {
              final photo = photos[i] as Map<String, dynamic>;
              final photoReference = photo['photo_reference'] as String?;
              if (photoReference != null) {
                // Construir URL de la foto
                final photoUrl = 
                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1200&photo_reference=$photoReference&key=$apiKey';
                imageUrls.add(photoUrl);
              }
            }
          }

          return imageUrls;
        }
      }
      
      return [];
    } catch (e) {
      print('❌ Error obteniendo fotos desde Place ID: $e');
      return [];
    }
  }
}


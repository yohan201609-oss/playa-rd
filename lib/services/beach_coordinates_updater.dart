import 'dart:math' as math;
import '../models/beach.dart';
import 'google_geocoding_service.dart';

/// Servicio para actualizar coordenadas de playas usando Google Geocoding API
class BeachCoordinatesUpdater {
  /// Actualizar coordenadas de una playa específica
  /// 
  /// Retorna una nueva instancia de Beach con coordenadas actualizadas,
  /// o null si no se pudieron obtener las coordenadas
  static Future<Beach?> updateBeachCoordinates(Beach beach) async {
    try {
      print('🔄 Actualizando coordenadas para: ${beach.name}');
      
      // Intentar primero con Places API (más preciso para lugares turísticos)
      final coordinates = await GoogleGeocodingService.getCoordinatesFromPlace(
        beach.name,
        province: beach.province,
        municipality: beach.municipality,
        approximateLatitude: beach.latitude,
        approximateLongitude: beach.longitude,
      );

      if (coordinates != null) {
        final updatedBeach = beach.copyWith(
          latitude: coordinates['latitude'] as double,
          longitude: coordinates['longitude'] as double,
        );

        // Si se obtuvo una dirección más precisa, actualizarla
        if (coordinates['formatted_address'] != null) {
          // Nota: El modelo Beach no tiene un campo para formatted_address,
          // pero podríamos actualizar el campo 'address' si existe
        }

        print('✅ Coordenadas actualizadas: ${updatedBeach.latitude}, ${updatedBeach.longitude}');
        return updatedBeach;
      } else {
        print('⚠️ No se pudieron actualizar las coordenadas para: ${beach.name}');
        return null;
      }
    } catch (e) {
      print('❌ Error actualizando coordenadas: $e');
      return null;
    }
  }

  /// Actualizar coordenadas de múltiples playas
  /// 
  /// [beaches] - Lista de playas a actualizar
  /// [onProgress] - Callback opcional para reportar progreso (índice, total, playa actual)
  /// 
  /// Retorna una lista con las playas actualizadas (solo las que se pudieron actualizar)
  static Future<List<Beach>> updateMultipleBeachesCoordinates(
    List<Beach> beaches, {
    Function(int current, int total, Beach beach)? onProgress,
  }) async {
    final updatedBeaches = <Beach>[];
    
    for (int i = 0; i < beaches.length; i++) {
      final beach = beaches[i];
      
      // Reportar progreso
      if (onProgress != null) {
        onProgress(i + 1, beaches.length, beach);
      }

      final updatedBeach = await updateBeachCoordinates(beach);
      
      if (updatedBeach != null) {
        updatedBeaches.add(updatedBeach);
      } else {
        // Si no se pudo actualizar, mantener la playa original
        updatedBeaches.add(beach);
      }

      // Pequeña pausa para no exceder los límites de la API
      await Future.delayed(const Duration(milliseconds: 200));
    }

    return updatedBeaches;
  }

  /// Verificar si las coordenadas de una playa necesitan actualización
  /// 
  /// Compara las coordenadas actuales con las obtenidas de Google
  /// Retorna true si hay una diferencia significativa (> 100 metros)
  static Future<bool> needsCoordinateUpdate(Beach beach) async {
    try {
      final newCoordinates = await GoogleGeocodingService.getCoordinatesFromPlace(
        beach.name,
        province: beach.province,
        municipality: beach.municipality,
        approximateLatitude: beach.latitude,
        approximateLongitude: beach.longitude,
      );

      if (newCoordinates == null) {
        return false;
      }

      final newLat = newCoordinates['latitude'] as double;
      final newLng = newCoordinates['longitude'] as double;

      // Calcular distancia en kilómetros usando fórmula de Haversine
      final distance = _calculateDistance(
        beach.latitude,
        beach.longitude,
        newLat,
        newLng,
      );

      // Si la diferencia es mayor a 100 metros, necesita actualización
      return distance > 0.1;
    } catch (e) {
      print('❌ Error verificando si necesita actualización: $e');
      return false;
    }
  }

  /// Calcular distancia entre dos puntos usando fórmula de Haversine
  /// Retorna la distancia en kilómetros
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radio de la Tierra en kilómetros

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}


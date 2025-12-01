import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

/// Servicio para abrir aplicaciones de navegación (Waze y Google Maps)
/// Maneja la apertura de aplicaciones de navegación con coordenadas o nombres de lugares
class NavigationService {
  // URLs de las tiendas de aplicaciones
  static const String _wazeAndroidStore = 'https://play.google.com/store/apps/details?id=com.waze';
  static const String _wazeIOSStore = 'https://apps.apple.com/app/waze-navigation-live-traffic/id323229106';
  
  /// Abre Waze con coordenadas específicas para navegación
  /// 
  /// [latitude] - Latitud del destino
  /// [longitude] - Longitud del destino
  /// [placeName] - Nombre opcional del lugar (para búsqueda alternativa)
  /// 
  /// Retorna true si se pudo abrir Waze, false en caso contrario
  /// 
  /// Nota: Prioriza búsqueda por nombre ya que es más confiable que coordenadas.
  /// Si las coordenadas son inválidas o Waze no las puede procesar, usa el nombre.
  static Future<bool> openWaze({
    required double latitude,
    required double longitude,
    String? placeName,
  }) async {
    try {
      // Validar coordenadas
      if (latitude.isNaN || longitude.isNaN || 
          latitude < -90 || latitude > 90 || 
          longitude < -180 || longitude > 180) {
        print('⚠️ Coordenadas inválidas: $latitude, $longitude');
        // Si las coordenadas son inválidas, intentar solo con nombre
        if (placeName != null && placeName.isNotEmpty) {
          return await _openWazeByName(placeName);
        }
        return false;
      }
      
      // PRIORIDAD 1: Intentar con búsqueda por nombre (más confiable)
      // Waze maneja mejor las búsquedas por nombre que por coordenadas
      if (placeName != null && placeName.isNotEmpty) {
        final success = await _openWazeByName(placeName);
        if (success) {
          return true;
        }
        // Si falla con nombre, continuar con coordenadas
        print('⚠️ Búsqueda por nombre falló, intentando con coordenadas...');
      }
      
      // PRIORIDAD 2: Intentar con coordenadas y nombre combinados (formato más robusto)
      if (placeName != null && placeName.isNotEmpty) {
        // Formato combinado: coordenadas + nombre
        final combinedUri = Uri.parse(
          'waze://?ll=$latitude,$longitude&q=${Uri.encodeComponent(placeName)}&navigate=yes',
        );
        
        if (await _tryLaunchWaze(combinedUri)) {
          print('✅ Waze abierto con coordenadas y nombre: $placeName');
          return true;
        }
      }
      
      // PRIORIDAD 3: Intentar solo con coordenadas (formato básico)
      final coordinatesUri = Uri.parse(
        'waze://?ll=$latitude,$longitude&navigate=yes',
      );
      
      if (await _tryLaunchWaze(coordinatesUri)) {
        print('✅ Waze abierto exitosamente con coordenadas: $latitude, $longitude');
        return true;
      }
      
      print('⚠️ No se pudo abrir Waze con ningún método.');
      return false;
    } catch (e) {
      print('❌ Error al abrir Waze: $e');
      return false;
    }
  }
  
  /// Intenta abrir Waze usando búsqueda por nombre
  static Future<bool> _openWazeByName(String placeName) async {
    try {
      // Formato de búsqueda por nombre: waze://?q=NOMBRE&navigate=yes
      final searchUri = Uri.parse(
        'waze://?q=${Uri.encodeComponent(placeName)}&navigate=yes',
      );
      
      return await _tryLaunchWaze(searchUri);
    } catch (e) {
      print('❌ Error al abrir Waze por nombre: $e');
      return false;
    }
  }
  
  /// Intenta lanzar Waze con el URI proporcionado
  /// Maneja tanto Android como iOS
  static Future<bool> _tryLaunchWaze(Uri uri) async {
    try {
      // En Android, intentar abrir directamente
      if (Platform.isAndroid) {
        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          return launched;
        } catch (e) {
          print('⚠️ Error al abrir Waze en Android: $e');
          return false;
        }
      }
      
      // En iOS u otras plataformas, verificar primero
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return launched;
      }
      
      return false;
    } catch (e) {
      print('❌ Error al intentar lanzar Waze: $e');
      return false;
    }
  }
  
  /// Abre la tienda de aplicaciones para instalar Waze
  /// 
  /// Detecta automáticamente la plataforma (Android/iOS) y abre la tienda correspondiente
  static Future<bool> openWazeStore() async {
    try {
      final storeUrl = Platform.isIOS ? _wazeIOSStore : _wazeAndroidStore;
      final uri = Uri.parse(storeUrl);
      
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          print('✅ Tienda de aplicaciones abierta para instalar Waze');
          return true;
        }
      }
      
      print('⚠️ No se pudo abrir la tienda de aplicaciones');
      return false;
    } catch (e) {
      print('❌ Error al abrir la tienda de aplicaciones: $e');
      return false;
    }
  }
  
  /// Abre Waze con coordenadas, y si no está instalado, redirige a la tienda
  /// 
  /// [latitude] - Latitud del destino
  /// [longitude] - Longitud del destino
  /// [placeName] - Nombre opcional del lugar
  /// [redirectToStore] - Si es true, abre la tienda si Waze no está instalado
  /// 
  /// Retorna true si se pudo abrir Waze o la tienda, false en caso contrario
  static Future<bool> openWazeWithFallback({
    required double latitude,
    required double longitude,
    String? placeName,
    bool redirectToStore = true,
  }) async {
    // Intentar abrir Waze primero
    final opened = await openWaze(
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
    );
    
    // Si no se pudo abrir y se solicita redirección a la tienda
    if (!opened && redirectToStore) {
      print('📱 Waze no está instalado. Redirigiendo a la tienda...');
      return await openWazeStore();
    }
    
    return opened;
  }
  
  /// Abre Google Maps con coordenadas específicas para navegación
  /// 
  /// [latitude] - Latitud del destino
  /// [longitude] - Longitud del destino
  /// [placeName] - Nombre opcional del lugar
  /// 
  /// Retorna true si se pudo abrir Google Maps, false en caso contrario
  static Future<bool> openGoogleMaps({
    required double latitude,
    required double longitude,
    String? placeName,
  }) async {
    try {
      String queryParam;
      
      // Priorizar nombre del lugar si está disponible
      if (placeName != null && placeName.isNotEmpty) {
        queryParam = Uri.encodeComponent(placeName);
      } else {
        // Usar coordenadas como respaldo
        queryParam = Uri.encodeComponent('$latitude,$longitude');
      }
      
      // URL de Google Maps para navegación
      final googleMapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$queryParam',
      );
      
      // Intentar abrir Google Maps
      if (await canLaunchUrl(googleMapsUri)) {
        final launched = await launchUrl(
          googleMapsUri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          print('✅ Google Maps abierto exitosamente con destino: $queryParam');
          return true;
        }
      }
      
      // Fallback: intentar con geo URI
      final geoUri = Uri.parse(
        'geo:$latitude,$longitude?q=${placeName ?? '$latitude,$longitude'}',
      );
      
      if (await canLaunchUrl(geoUri)) {
        final launched = await launchUrl(
          geoUri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          print('✅ Google Maps abierto con geo URI');
          return true;
        }
      }
      
      print('⚠️ No se pudo abrir Google Maps');
      return false;
    } catch (e) {
      print('❌ Error al abrir Google Maps: $e');
      return false;
    }
  }
  
  /// Verifica si Waze está instalado en el dispositivo
  /// 
  /// Retorna true si Waze puede ser abierto, false en caso contrario
  /// 
  /// Nota: En Android, canLaunchUrl puede no ser confiable. Este método
  /// intenta verificar, pero puede devolver false incluso si Waze está instalado.
  /// Por eso, siempre intentamos abrir Waze directamente cuando el usuario lo selecciona.
  static Future<bool> isWazeInstalled() async {
    try {
      // En Android, canLaunchUrl puede fallar incluso si Waze está instalado
      // Por eso siempre intentamos abrir directamente cuando el usuario selecciona Waze
      final wazeUri = Uri.parse('waze://');
      return await canLaunchUrl(wazeUri);
    } catch (e) {
      print('❌ Error al verificar si Waze está instalado: $e');
      // En caso de error, asumimos que no está instalado
      // pero siempre intentaremos abrir cuando el usuario lo seleccione
      return false;
    }
  }
  
  /// Obtiene el nombre completo del lugar para usar en navegación
  /// 
  /// [name] - Nombre del lugar
  /// [municipality] - Municipio
  /// [province] - Provincia
  /// 
  /// Retorna una cadena formateada con el nombre completo
  static String getFullPlaceName({
    required String name,
    String? municipality,
    String? province,
  }) {
    final parts = <String>[name];
    
    if (municipality != null && municipality.isNotEmpty) {
      parts.add(municipality);
    }
    
    if (province != null && province.isNotEmpty) {
      parts.add(province);
    }
    
    return parts.join(', ');
  }
}


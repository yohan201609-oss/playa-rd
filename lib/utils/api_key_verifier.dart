import '../services/google_geocoding_service.dart';

/// Utilidad para verificar el estado de la API Key de Google Maps
class ApiKeyVerifier {
  /// Verificar y mostrar el estado de la API Key
  static Future<Map<String, dynamic>> verifyApiKeyStatus() async {
    final apiKey = GoogleGeocodingService.apiKey;
    final isValid = await GoogleGeocodingService.verifyApiKey();
    
    return {
      'configured': apiKey != null && apiKey.isNotEmpty,
      'valid': isValid,
      'source': apiKey != null && apiKey.length > 10 
          ? (apiKey.substring(0, 10) == 'AIzaSyCFt8' 
              ? 'AndroidManifest (fallback)' 
              : '.env file')
          : 'Unknown',
      'preview': apiKey != null && apiKey.length > 10 
          ? '${apiKey.substring(0, 10)}...' 
          : 'Not configured',
    };
  }
  
  /// Obtener mensaje de estado legible
  static Future<String> getStatusMessage() async {
    final status = await verifyApiKeyStatus();
    
    if (!status['configured']) {
      return '❌ API Key no configurada';
    }
    
    if (!status['valid']) {
      return '⚠️ API Key configurada pero inválida';
    }
    
    return '✅ API Key configurada y válida (${status['source']})';
  }
}


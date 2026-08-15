import 'package:flutter/foundation.dart';

/// Utilidades para URLs de fotos de playas (Firebase Storage vs Google Places).
class BeachImageUtils {
  BeachImageUtils._();

  /// Debe coincidir con [DefaultFirebaseOptions] / Firebase Console.
  static const storageBucket = 'playas-rd-2b475.firebasestorage.app';

  static const androidPackage = 'com.playasrd.playasrd';
  static const iosBundleId = 'com.playasrd.playasrd';

  /// SHA-1 debug (sin `:`) — keystore de desarrollo Android.
  static const _debugSha1 = '72F17A530F1BEBE00DDD1D920F565A8D2D0508E6';

  /// SHA-1 upload/release local (sin `:`).
  /// Si la app viene de Play App Signing, usa el SHA-1 de Play Console.
  static const _releaseSha1 = '3B28ECD60C45155C9A6215344FBE771250F62486';

  static bool isFirebaseStorageImageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com') ||
        _isStoragePath(url);
  }

  static bool isGooglePlacesPhotoUrl(String url) {
    return url.contains('maps.googleapis.com/maps/api/place/photo');
  }

  static bool isGoogleStaticMapUrl(String url) {
    return url.contains('maps.googleapis.com/maps/api/staticmap');
  }

  static bool isGoogleMapsRestrictedUrl(String url) {
    return isGooglePlacesPhotoUrl(url) || isGoogleStaticMapUrl(url);
  }

  static bool beachHasFirebasePhotos(List<String> imageUrls) {
    return imageUrls.any(isFirebaseStorageImageUrl);
  }

  /// Convierte URL con token o ruta de Storage a URL pública estable (sin token).
  /// Requiere reglas `allow read: if true` en [storage.rules] para esa ruta.
  static String resolveImageUrl(String stored) {
    if (stored.isEmpty) return stored;
    if (isGooglePlacesPhotoUrl(stored) || isGoogleStaticMapUrl(stored)) {
      return stored;
    }

    final path = storagePathFromStored(stored);
    if (path != null) {
      return publicStorageUrl(path);
    }
    return stored;
  }

  static String? storagePathFromStored(String stored) {
    if (_isStoragePath(stored)) return stored;

    if (!stored.contains('firebasestorage.googleapis.com')) {
      return null;
    }

    final match = RegExp(r'/o/([^?]+)').firstMatch(stored);
    if (match == null) return null;

    return Uri.decodeComponent(match.group(1)!);
  }

  static String publicStorageUrl(String storagePath) {
    final encoded = Uri.encodeComponent(storagePath);
    return 'https://firebasestorage.googleapis.com/v0/b/$storageBucket/o/$encoded?alt=media';
  }

  static bool _isStoragePath(String value) {
    return value.startsWith('beaches/') || value.startsWith('beach_photos/');
  }

  /// Headers para peticiones JSON de Places/Geocoding y para cargar imágenes
  /// de Google Maps con API key restringida por app.
  static Map<String, String> googleMapsRequestHeaders() {
    if (kIsWeb) return const {};

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return const {'X-Ios-Bundle-Identifier': iosBundleId};
      case TargetPlatform.android:
        return {
          'X-Android-Package': androidPackage,
          'X-Android-Cert': kDebugMode ? _debugSha1 : _releaseSha1,
        };
      default:
        return const {};
    }
  }

  /// Headers HTTP solo cuando la URL requiere restricción de app Google.
  static Map<String, String>? httpHeadersForUrl(String url) {
    if (!isGoogleMapsRestrictedUrl(url)) return null;
    final headers = googleMapsRequestHeaders();
    return headers.isEmpty ? null : headers;
  }
}

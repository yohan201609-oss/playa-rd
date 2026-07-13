/// Utilidades para URLs de fotos de playas (Firebase Storage vs Google Places).
class BeachImageUtils {
  BeachImageUtils._();

  /// Debe coincidir con [DefaultFirebaseOptions] / Firebase Console.
  static const storageBucket = 'playas-rd-2b475.firebasestorage.app';

  static const _iosBundleHeader = {
    'X-Ios-Bundle-Identifier': 'com.playasrd.playasrd',
  };

  static bool isFirebaseStorageImageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com') ||
        _isStoragePath(url);
  }

  static bool isGooglePlacesPhotoUrl(String url) {
    return url.contains('maps.googleapis.com/maps/api/place/photo');
  }

  static bool beachHasFirebasePhotos(List<String> imageUrls) {
    return imageUrls.any(isFirebaseStorageImageUrl);
  }

  /// Convierte URL con token o ruta de Storage a URL pública estable (sin token).
  /// Requiere reglas `allow read: if true` en [storage.rules] para esa ruta.
  static String resolveImageUrl(String stored) {
    if (stored.isEmpty) return stored;
    if (isGooglePlacesPhotoUrl(stored)) return stored;

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

  /// Headers requeridos solo para fotos de Google Places (iOS).
  static Map<String, String>? httpHeadersForUrl(String url) {
    if (isGooglePlacesPhotoUrl(url)) {
      return _iosBundleHeader;
    }
    return null;
  }
}

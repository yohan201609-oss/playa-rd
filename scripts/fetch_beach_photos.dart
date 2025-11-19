import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';
import '../lib/services/firebase_service.dart';

/// Script para obtener fotos de las 45 playas originales desde Google Places API
/// Uso: flutter run -d [dispositivo] --target=scripts/fetch_beach_photos.dart
void main() async {
  print('🚀 Iniciando script para obtener fotos desde Google Places API...\n');

  try {
    // Inicializar Flutter binding
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente\n');

    // Obtener fotos de las 45 playas originales desde Google Places API
    await FirebaseService.fetchPhotosFromGooglePlacesForOriginalBeaches(
      onProgress: (current, total, name) {
        print('📸 Progreso: $current/$total - $name');
      },
    );

    print('\n✅ Script completado exitosamente');
    exit(0);
  } catch (e) {
    print('\n❌ Error ejecutando script: $e');
    exit(1);
  }
}



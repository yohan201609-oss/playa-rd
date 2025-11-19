import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';
import '../lib/services/firebase_service.dart';

/// Script para eliminar URLs de imágenes de las 45 playas originales en Firebase
/// Uso: flutter run -d [dispositivo] --target=scripts/remove_beach_images.dart
void main() async {
  print(
    '🚀 Iniciando script para eliminar URLs de imágenes de las 45 playas originales...\n',
  );

  try {
    // Inicializar Flutter binding
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente\n');

    // Eliminar URLs de imágenes de las 45 playas originales
    await FirebaseService.removeImageUrlsFromOriginalBeaches();

    print('\n✅ Script completado exitosamente');
    exit(0);
  } catch (e) {
    print('\n❌ Error ejecutando script: $e');
    exit(1);
  }
}

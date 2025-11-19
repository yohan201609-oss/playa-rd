import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../firebase_options.dart';
import 'admob_service.dart';
import 'firebase_service.dart';
import 'notification_service.dart';
import 'preferences_service.dart';

/// Resultado resumido del proceso de inicialización crítica
class AppInitializationResult {
  final bool preferencesReady;
  final bool envLoaded;
  final bool firebaseReady;
  final Duration elapsed;

  const AppInitializationResult({
    required this.preferencesReady,
    required this.envLoaded,
    required this.firebaseReady,
    required this.elapsed,
  });

  bool get isReady => preferencesReady && firebaseReady;
}

/// Orquesta las tareas necesarias para poder mostrar la UI rápidamente.
class AppInitializer {
  Future<AppInitializationResult> initialize() async {
    final stopwatch = Stopwatch()..start();
    var prefsReady = false;
    var envLoaded = false;
    var firebaseReady = false;

    await Future.wait([
      _initPreferences().then((value) => prefsReady = value),
      _loadEnvironment().then((value) => envLoaded = value),
      _initFirebase().then((value) => firebaseReady = value),
    ]);

    _kickOffBackgroundWork();

    stopwatch.stop();
    final result = AppInitializationResult(
      preferencesReady: prefsReady,
      envLoaded: envLoaded,
      firebaseReady: firebaseReady,
      elapsed: stopwatch.elapsed,
    );

    print(
      '🚀 Inicialización crítica completada en ${result.elapsed.inMilliseconds} ms',
    );

    return result;
  }

  Future<bool> _initPreferences() async {
    try {
      await PreferencesService.init();
      print('✅ Preferencias inicializadas');
      return true;
    } catch (e) {
      print('⚠️ Error inicializando preferencias: $e');
      return false;
    }
  }

  Future<bool> _loadEnvironment() async {
    if (dotenv.isInitialized) {
      return true;
    }

    try {
      await dotenv.load(fileName: '.env');
      print('✅ Archivo .env cargado (${dotenv.env.length} variables)');
      return true;
    } catch (e) {
      print('⚠️ No se pudo cargar .env: $e');
      print('⚠️ Se usará la configuración por defecto incluida en el build');
      return false;
    }
  }

  Future<bool> _initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase inicializado correctamente');
      return true;
    } catch (e) {
      print('⚠️ Firebase no configurado: $e');
      print('La app funcionará con datos locales sin autenticación');
      return false;
    }
  }

  void _kickOffBackgroundWork() {
    Future.microtask(() async {
      try {
        await NotificationService().initialize();
        print('✅ Servicio de notificaciones inicializado (post-arranque)');
      } catch (e) {
        print('⚠️ Error inicializando notificaciones: $e');
      }
    });

    Future.microtask(() async {
      try {
        final adService = AdMobService();
        await adService.initialize();
        await adService.configureRequest();
        print('✅ AdMob inicializado correctamente (post-arranque)');
      } catch (e) {
        print('⚠️ Error inicializando AdMob: $e');
      }
    });

    Future.microtask(() async {
      try {
        await FirebaseService.syncBeachesToFirestore();
        await FirebaseService.updateAllBeachesWithEnglishDescriptions();
      } catch (e) {
        print('⚠️ Error sincronizando playas: $e');
      }
    });
  }
}


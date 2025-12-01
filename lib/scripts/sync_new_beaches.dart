import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../services/firebase_service.dart';

/// Script para sincronizar las nuevas playas de San Pedro de Macorís con Firebase
/// Ejecutar con: dart run lib/scripts/sync_new_beaches.dart
Future<void> main() async {
  print('🔥 Iniciando sincronización de playas con Firebase...\n');
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado\n');
    
    // Sincronizar playas
    print('🔄 Sincronizando playas...');
    await FirebaseService.syncBeachesToFirestore();
    
    print('\n✅ Sincronización completada');
    print('📊 Las nuevas playas de San Pedro de Macorís han sido agregadas a Firebase');
    
    exit(0);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}


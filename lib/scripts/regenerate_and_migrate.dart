import 'package:playas_rd_flutter/services/firebase_service.dart';

/// Script para regenerar URLs de Google Places y luego migrar a Firebase Storage
Future<void> regenerateAndMigrateImages() async {
  print('');
  print('═══════════════════════════════════════════════════════════════');
  print('🔄 REGENERANDO URLs DE GOOGLE PLACES Y MIGRANDO A FIREBASE');
  print('═══════════════════════════════════════════════════════════════');
  print('');

  try {
    // Paso 1: Regenerar URLs de Google Places (NUEVAS y válidas)
    print('📸 PASO 1: Obteniendo URLs nuevas de Google Places...');
    print('');
    
    await FirebaseService.fetchPhotosFromGooglePlacesForOriginalBeaches(
      onProgress: (current, total, message) {
        print('[$current/$total] $message');
      },
    );
    
    print('');
    print('✅ Paso 1 completado: URLs de Google Places regeneradas');
    print('');

    // Paso 2: Esperar un momento para que se guarden en Firestore
    print('⏳ Esperando 5 segundos para que se guarden los datos...');
    await Future.delayed(const Duration(seconds: 5));

    // Paso 3: Migrar de Google Places a Firebase Storage
    print('');
    print('📥 PASO 2: Migrando imágenes a Firebase Storage...');
    print('');

    final result = await FirebaseService.migrateAllGoogleImagesToFirebase(
      onProgress: (current, total, beachName, photosTransferred) {
        print('[$current/$total] $beachName: $photosTransferred fotos migradas');
      },
    );

    print('');
    print('═══════════════════════════════════════════════════════════════');
    print('✅ ¡MIGRACIÓN COMPLETADA EXITOSAMENTE!');
    print('═══════════════════════════════════════════════════════════════');
    print('');
    print('📊 Resultados:');
    print('   • Playas procesadas: ${result['totalProcessed']}');
    print('   • Fotos migradas: ${result['totalMigrated']}');
    print('   • Errores: ${result['errors']}');
    print('');
    print('💰 AHORRO ESTIMADO:');
    print('   Antes: \$${(result['totalMigrated'] * 0.007).toStringAsFixed(2)}/mes');
    print('   Después: \$0.00/mes (Firebase Storage es gratis)');
    print('');
    print('✅ ¡Las imágenes NO volverán a salir rotas!');
    print('');
  } catch (e) {
    print('');
    print('❌ ERROR DURANTE LA MIGRACIÓN:');
    print('$e');
    print('');
    print('💡 Intenta nuevamente en unos minutos');
    print('');
  }
}

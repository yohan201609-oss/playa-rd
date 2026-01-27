import '../services/firebase_service.dart';

/// Utilidades para ejecutar migraciones de datos
/// 
/// Uso: Llamar desde main.dart o desde un botón de administrador en la app
class MigrationUtils {
  /// Ejecutar la migración de todas las imágenes de Google a Firebase Storage
  /// 
  /// Esta función:
  /// 1. Obtiene todas las playas de Firestore
  /// 2. Identifica las URLs que apuntan a Google Places
  /// 3. Las descarga y sube a Firebase Storage
  /// 4. Actualiza Firestore con las nuevas URLs permanentes
  /// 5. Genera un ahorro estimado en costos de Google
  /// 
  /// ⚠️ ADVERTENCIA: Este proceso toma tiempo (puede ser 10-60 minutos dependiendo de cantidad de playas y fotos)
  /// ⚠️ Solo ejecutar desde modo debug o como tarea nocturna, NO en producción con usuarios activos
  static Future<void> runMigration() async {
    print('');
    print('═══════════════════════════════════════════════════════════════');
    print('  INICIANDO MIGRACIÓN DE IMÁGENES A FIREBASE STORAGE');
    print('═══════════════════════════════════════════════════════════════');
    print('');
    print('Este proceso:');
    print('  ✓ Descarga fotos de Google Places API');
    print('  ✓ Las sube a Firebase Storage');
    print('  ✓ Actualiza Firestore con las nuevas URLs');
    print('  ✓ AHORRA dinero en costos de Google');
    print('');

    try {
      final result =
          await FirebaseService.migrateAllGoogleImagesToFirebase();

      if (result['success'] == true) {
        print('');
        print('═══════════════════════════════════════════════════════════════');
        print('✅ MIGRACIÓN EXITOSA');
        print('═══════════════════════════════════════════════════════════════');
        print('');
        print('Resultados:');
        print(
          '  • Playas procesadas: ${result['totalBeaches']}',
        );
        print(
          '  • Playas modificadas: ${result['beachesModified']}',
        );
        print(
          '  • Fotos migradas: ${result['totalMigrated']}',
        );
        print(
          '  • Total de fotos procesadas: ${result['totalPhotos']}',
        );
        print(
          '  • Errores: ${result['errors']}',
        );
        print('');
        print('💰 AHORRO ESTIMADO MENSUAL:');
        print(
          '  Antes: \$${((result['totalMigrated'] as int) * 0.007).toStringAsFixed(2)} (Google Places)',
        );
        print('  Después: \$0.00 (Firebase Storage es gratis)');
        print('');
        print('✅ ¡Las imágenes ya NO saldrán rotas nunca más!');
        print('');
      } else {
        print('❌ Migración fallida: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error ejecutando migración: $e');
      rethrow;
    }
  }

  /// Migrar solo una playa específica (útil para testing)
  static Future<bool> migrateBeach(String beachId) async {
    print('Migrando playa ID: $beachId');
    return await FirebaseService.migrateBeachImagesToFirebase(beachId);
  }
}

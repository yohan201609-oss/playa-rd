import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/firebase_options.dart';
import '../lib/services/firebase_service.dart';
import '../lib/services/beach_service.dart';
import '../lib/services/google_places_service.dart';

/// Script para obtener fotos de todas las playas usando Google Places API
/// y actualizarlas en Firebase
/// 
/// Uso: flutter run -d [dispositivo] --target=scripts/fetch_beach_images.dart
void main() async {
  print(
    '🚀 Iniciando script para obtener fotos de playas desde Google Places API...\n',
  );

  try {
    // Inicializar Flutter binding
    WidgetsFlutterBinding.ensureInitialized();

    // Cargar variables de entorno si existen
    try {
      await dotenv.load(fileName: '.env');
      print('✅ Variables de entorno cargadas\n');
    } catch (e) {
      print('⚠️ No se pudo cargar .env (continuando con configuración por defecto)\n');
    }

    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente\n');

    // Obtener todas las playas desde Firebase (no solo las 45 originales)
    print('📥 Obteniendo todas las playas desde Firebase...');
    final beaches = await FirebaseService.getBeachesOnce();
    print('📊 Total de playas encontradas en Firebase: ${beaches.length}\n');
    
    if (beaches.isEmpty) {
      print('⚠️ No se encontraron playas en Firebase');
      print('💡 Intentando usar playas locales como respaldo...');
      final localBeaches = BeachService.getDominicanBeaches();
      print('📊 Total de playas locales: ${localBeaches.length}\n');
      exit(0);
    }

    int successCount = 0;
    int errorCount = 0;
    int skippedCount = 0;
    int alreadyHasPhotos = 0;

    // Filtrar playas que necesitan fotos (sin fotos o con menos de 3 fotos)
    final beachesToUpdate = beaches.where((beach) {
      return beach.imageUrls.isEmpty || beach.imageUrls.length < 3;
    }).toList();

    print('📸 Playas que necesitan fotos: ${beachesToUpdate.length}');
    print('✅ Playas que ya tienen suficientes fotos: ${beaches.length - beachesToUpdate.length}\n');

    // Procesar cada playa que necesita fotos
    for (int i = 0; i < beachesToUpdate.length; i++) {
      final beach = beachesToUpdate[i];
      print('🔄 [${i + 1}/${beachesToUpdate.length}] Procesando: ${beach.name}');

      try {
        // Obtener fotos usando Google Places API
        final photos = await GooglePlacesService.getBeachPhotos(
          beach.name,
          province: beach.province,
          municipality: beach.municipality,
          latitude: beach.latitude,
          longitude: beach.longitude,
          maxPhotos: 5, // Obtener hasta 5 fotos por playa
        );

        if (photos.isEmpty) {
          print('⚠️ No se encontraron fotos para: ${beach.name}');
          skippedCount++;
          continue;
        }

        print('📸 ${photos.length} foto(s) encontrada(s) para: ${beach.name}');

        // Combinar fotos existentes con nuevas (eliminar duplicados)
        final existingPhotos = beach.imageUrls;
        final allPhotos = <String>[...existingPhotos];
        
        for (final photo in photos) {
          if (!allPhotos.contains(photo)) {
            allPhotos.add(photo);
          }
        }

        // Limitar a 5 fotos máximo
        final finalPhotos = allPhotos.length > 5 
            ? allPhotos.sublist(0, 5) 
            : allPhotos;

        // Actualizar la playa con las nuevas URLs de fotos
        final updatedBeach = beach.copyWith(
          imageUrls: finalPhotos,
        );

        // Actualizar en Firebase
        await FirebaseService.updateBeach(updatedBeach);

        print('✅ Fotos actualizadas para: ${beach.name} (${finalPhotos.length} fotos totales)\n');
        successCount++;

        // Pausa entre solicitudes para evitar rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('❌ Error procesando ${beach.name}: $e\n');
        errorCount++;
      }
    }

    // Contar playas que ya tienen suficientes fotos
    alreadyHasPhotos = beaches.length - beachesToUpdate.length;

    // Resumen final
    print('\n' + '=' * 50);
    print('📊 RESUMEN FINAL');
    print('=' * 50);
    print('✅ Playas actualizadas exitosamente: $successCount');
    print('✅ Playas que ya tenían suficientes fotos: $alreadyHasPhotos');
    print('⚠️ Playas sin fotos encontradas: $skippedCount');
    print('❌ Playas con errores: $errorCount');
    print('📊 Total de playas en Firebase: ${beaches.length}');
    print('📊 Total procesadas: ${beachesToUpdate.length}');
    print('=' * 50);

    print('\n✅ Script completado exitosamente');
    exit(0);
  } catch (e) {
    print('\n❌ Error ejecutando script: $e');
    exit(1);
  }
}


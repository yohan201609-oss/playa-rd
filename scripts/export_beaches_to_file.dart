import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import '../lib/firebase_options.dart';

// Modelo simplificado de Beach para el script
class BeachData {
  final String id;
  final String name;
  final String province;
  final String municipality;
  final String description;
  final double rating;
  final int reviewCount;
  final String currentCondition;

  BeachData({
    required this.id,
    required this.name,
    required this.province,
    required this.municipality,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.currentCondition,
  });

  factory BeachData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BeachData(
      id: doc.id,
      name: data['name'] ?? '',
      province: data['province'] ?? '',
      municipality: data['municipality'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      currentCondition: data['currentCondition'] ?? 'Desconocido',
    );
  }
}

/// Script para exportar todas las playas desde Firestore a un archivo de texto
/// Uso: dart scripts/export_beaches_to_file.dart
void main() async {
  print('🚀 Iniciando exportación de playas desde Firestore...');

  try {
    // Inicializar Flutter binding
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado');

    // Obtener todas las playas desde Firestore
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('beaches').get();

    print('📊 Encontradas ${snapshot.docs.length} playas en Firestore');

    // Agrupar por provincia
    final Map<String, List<BeachData>> beachesByProvince = {};

    for (var doc in snapshot.docs) {
      try {
        final beach = BeachData.fromFirestore(doc);
        if (!beachesByProvince.containsKey(beach.province)) {
          beachesByProvince[beach.province] = [];
        }
        beachesByProvince[beach.province]!.add(beach);
      } catch (e) {
        print('⚠️ Error procesando playa ${doc.id}: $e');
      }
    }

    // Ordenar provincias alfabéticamente
    final sortedProvinces = beachesByProvince.keys.toList()..sort();

    // Generar contenido del archivo
    final buffer = StringBuffer();
    buffer.writeln(
      '═══════════════════════════════════════════════════════════════',
    );
    buffer.writeln('   LISTADO DE PLAYAS POR PROVINCIA - REPÚBLICA DOMINICANA');
    buffer.writeln(
      '═══════════════════════════════════════════════════════════════',
    );
    buffer.writeln();

    int totalBeaches = 0;

    for (final province in sortedProvinces) {
      final beaches = beachesByProvince[province]!;
      // Ordenar playas por nombre
      beaches.sort((a, b) => a.name.compareTo(b.name));

      buffer.writeln(province.toUpperCase());
      buffer.writeln('─' * 63);

      for (int i = 0; i < beaches.length; i++) {
        final beach = beaches[i];
        buffer.writeln('${i + 1}. ${beach.name}');
        buffer.writeln('   - Municipio: ${beach.municipality}');
        buffer.writeln('   - Calificación: ${beach.rating}/5.0');
        buffer.writeln('   - Condición: ${beach.currentCondition}');
        if (beach.reviewCount > 0) {
          buffer.writeln('   - Reseñas: ${beach.reviewCount}');
        }
        if (beach.description.isNotEmpty) {
          final shortDesc = beach.description.length > 100
              ? '${beach.description.substring(0, 100)}...'
              : beach.description;
          buffer.writeln('   - Descripción: $shortDesc');
        }
        buffer.writeln();
      }

      buffer.writeln('Total: ${beaches.length} playas');
      buffer.writeln();
      buffer.writeln();

      totalBeaches += beaches.length;
    }

    // Agregar resumen
    buffer.writeln(
      '═══════════════════════════════════════════════════════════════',
    );
    buffer.writeln('                      RESUMEN GENERAL');
    buffer.writeln(
      '═══════════════════════════════════════════════════════════════',
    );
    buffer.writeln();
    buffer.writeln('Total de Provincias: ${sortedProvinces.length}');
    buffer.writeln('Total de Playas: $totalBeaches');
    buffer.writeln();
    buffer.writeln('Provincias con más playas:');

    // Ordenar provincias por cantidad de playas (descendente)
    final provincesByCount = beachesByProvince.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    for (int i = 0; i < provincesByCount.length; i++) {
      final entry = provincesByCount[i];
      buffer.writeln('${i + 1}. ${entry.key} - ${entry.value.length} playas');
    }

    buffer.writeln();
    buffer.writeln(
      '═══════════════════════════════════════════════════════════════',
    );
    buffer.writeln('Generado desde: playas_rd_flutter');
    buffer.writeln('Fuente: Firestore');
    buffer.writeln('Fecha: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln(
      '═══════════════════════════════════════════════════════════════',
    );

    // Obtener directorio para guardar el archivo
    Directory? directory;
    try {
      // Intentar obtener el directorio de descargas externo
      directory = await getExternalStorageDirectory();
      if (directory == null) {
        // Si no hay almacenamiento externo, usar el directorio de documentos
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      // Fallback: usar el directorio de documentos de la aplicación
      directory = await getApplicationDocumentsDirectory();
    }

    // Crear directorio Downloads si no existe
    final downloadsDir = Directory('${directory!.path}/Download');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    // Escribir archivo
    final file = File('${downloadsDir.path}/listado_playas_por_provincia.txt');
    await file.writeAsString(buffer.toString());

    print('✅ Archivo generado: ${file.path}');
    print(
      '📄 Total: $totalBeaches playas en ${sortedProvinces.length} provincias',
    );
    print('💾 Ubicación: ${file.path}');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  } finally {
    exit(0);
  }
}

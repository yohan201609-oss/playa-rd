import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

/// Script para eliminar playas específicas desde Firestore
/// Uso: flutter run -d [dispositivo] --target=scripts/delete_beaches.dart
void main() async {
  print('🗑️  Iniciando eliminación de playas desde Firestore...');

  try {
    // Inicializar Flutter binding
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado');

    // Lista de playas a eliminar (por nombre)
    final beachesToDelete = [
      'Parador Fotográfico Barahona',
      'San Rafael',
      'Barahona',
      'Acapulco beach',
      'Casa de Campo Resort and Villas',
      'Playa Publica Bayahibe',
      'Playa Bayahibe',
      'Playa Teco Maimón Puerto Plata',
      'Playa de Güibia',
      'Public Beach Playa Dominicus',
      'Puerto Turístico Taíno Bay',
      'Terminal Turística Amber Cove',
      'La Caleta',
    ];

    final firestore = FirebaseFirestore.instance;

    // Buscar y eliminar cada playa
    int deletedCount = 0;
    int notFoundCount = 0;

    for (final beachName in beachesToDelete) {
      try {
        // Buscar por nombre (case insensitive)
        final querySnapshot = await firestore
            .collection('beaches')
            .where('name', isEqualTo: beachName)
            .get();

        if (querySnapshot.docs.isEmpty) {
          // Intentar búsqueda parcial (por si el nombre tiene variaciones)
          final allBeaches = await firestore.collection('beaches').get();
          final matchingBeaches = allBeaches.docs.where((doc) {
            final name = (doc.data()['name'] as String? ?? '').toLowerCase();
            final searchName = beachName.toLowerCase();
            return name.contains(searchName) || searchName.contains(name);
          }).toList();

          if (matchingBeaches.isNotEmpty) {
            for (var doc in matchingBeaches) {
              await doc.reference.delete();
              print('✅ Eliminada: ${doc.data()['name']} (ID: ${doc.id})');
              deletedCount++;
            }
          } else {
            print('⚠️  No encontrada: $beachName');
            notFoundCount++;
          }
        } else {
          for (var doc in querySnapshot.docs) {
            await doc.reference.delete();
            print('✅ Eliminada: ${doc.data()['name']} (ID: ${doc.id})');
            deletedCount++;
          }
        }
      } catch (e) {
        print('❌ Error eliminando $beachName: $e');
      }
    }

    print('');
    print('═══════════════════════════════════════════════════════════════');
    print('                      RESUMEN DE ELIMINACIÓN');
    print('═══════════════════════════════════════════════════════════════');
    print('✅ Playas eliminadas: $deletedCount');
    print('⚠️  Playas no encontradas: $notFoundCount');
    print('📋 Total de playas buscadas: ${beachesToDelete.length}');
    print('═══════════════════════════════════════════════════════════════');

    // Verificar el total actual de playas
    final allBeaches = await firestore.collection('beaches').get();
    print('📊 Total de playas restantes en Firestore: ${allBeaches.docs.length}');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}


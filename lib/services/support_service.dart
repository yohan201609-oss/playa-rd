import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum SupportRequestType { issue, suggestion }

/// Servicio para enviar solicitudes de soporte (problemas o sugerencias).
/// Los datos se almacenan en Firestore y una Cloud Function se encarga
/// de reenviarlos vía correo electrónico al equipo.
class SupportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> submit({
    required SupportRequestType type,
    required String message,
    String? contact,
  }) async {
    try {
      final user = _auth.currentUser;

      // Validar que el mensaje no esté vacío
      if (message.trim().isEmpty) {
        throw Exception('El mensaje no puede estar vacío');
      }

      final docRef = await _firestore.collection('support_requests').add({
        'type': type.name,
        'message': message.trim(),
        'contact': contact?.trim() ?? '',
        'userId': user?.uid ?? null,
        'userEmail': user?.email ?? null,
        'userDisplayName': user?.displayName ?? null,
        'platform': defaultTargetPlatform.name,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Solicitud de soporte enviada correctamente. ID: ${docRef.id}');
      
      // Verificar que el documento se creó correctamente
      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('No se pudo crear la solicitud de soporte');
      }
      
      print('✅ Documento verificado en Firestore: ${doc.id}');
    } on FirebaseException catch (e) {
      print('❌ Error de Firebase enviando solicitud de soporte: ${e.code} - ${e.message}');
      throw Exception('Error de conexión: ${e.message ?? e.code}');
    } catch (e, stackTrace) {
      print('❌ Error enviando solicitud de soporte: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Re-lanzar el error para que el UI lo maneje
    }
  }
}


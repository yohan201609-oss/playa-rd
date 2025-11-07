import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/beach.dart';
import '../utils/notification_helper.dart';
import 'beach_service.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =======================
  // AUTENTICACIÓN
  // =======================

  // Usuario actual
  static User? get currentUser => _auth.currentUser;

  // Stream de autenticación
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registro con email y contraseña
  static Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Actualizar perfil
      await userCredential.user?.updateDisplayName(displayName);

      // Crear documento de usuario en Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'favoriteBeaches': [],
        'visitedBeaches': [],
        'reportsCount': 0,
        'fcmToken': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      print('Error en registro: $e');
      rethrow;
    }
  }

  // Iniciar sesión con email y contraseña
  static Future<UserCredential?> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error en inicio de sesión: $e');
      rethrow;
    }
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Restablecer contraseña
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Iniciar sesión con Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Configurar Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Iniciar el proceso de autenticación
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el proceso
        return null;
      }

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crear una nueva credencial
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión con Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Crear o actualizar documento de usuario en Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'provider': 'google',
          'favoriteBeaches': [],
          'reportsCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      print('Error en Google Sign-In: $e');
      rethrow;
    }
  }

  // =======================
  // USUARIOS
  // =======================

  // Obtener datos del usuario
  static Future<AppUser?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }

  // Agregar playa a favoritos
  static Future<void> addFavoriteBeach(String userId, String beachId) async {
    await _firestore.collection('users').doc(userId).update({
      'favoriteBeaches': FieldValue.arrayUnion([beachId]),
    });
  }

  // Remover playa de favoritos
  static Future<void> removeFavoriteBeach(String userId, String beachId) async {
    await _firestore.collection('users').doc(userId).update({
      'favoriteBeaches': FieldValue.arrayRemove([beachId]),
    });
  }

  // Agregar playa a visitadas
  static Future<void> addVisitedBeach(String userId, String beachId) async {
    await _firestore.collection('users').doc(userId).update({
      'visitedBeaches': FieldValue.arrayUnion([beachId]),
    });
  }

  // Remover playa de visitadas
  static Future<void> removeVisitedBeach(String userId, String beachId) async {
    await _firestore.collection('users').doc(userId).update({
      'visitedBeaches': FieldValue.arrayRemove([beachId]),
    });
  }

  // Guardar FCM token del usuario
  static Future<void> saveFCMToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Obtener usuarios que tienen una playa como favorita (para notificaciones)
  static Future<List<String>> getUsersWithFavoriteBeach(String beachId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('favoriteBeaches', arrayContains: beachId)
          .get();
      
      return querySnapshot.docs
          .where((doc) => doc.data()['fcmToken'] != null)
          .map((doc) => doc.data()['fcmToken'] as String)
          .toList();
    } catch (e) {
      print('Error obteniendo usuarios con favoritos: $e');
      return [];
    }
  }

  // =======================
  // PLAYAS
  // =======================

  // Sincronizar playas locales con Firestore
  static Future<void> syncBeachesToFirestore() async {
    try {
      // Obtener playas locales
      final localBeaches = _getLocalBeaches();

      for (final beach in localBeaches) {
        // Verificar si la playa ya existe
        DocumentSnapshot doc = await _firestore
            .collection('beaches')
            .doc(beach.id)
            .get();

        if (!doc.exists) {
          // Crear la playa en Firestore
          await _firestore.collection('beaches').doc(beach.id).set({
            'id': beach.id,
            'name': beach.name,
            'province': beach.province,
            'municipality': beach.municipality,
            'description': beach.description,
            'latitude': beach.latitude,
            'longitude': beach.longitude,
            'imageUrls': beach.imageUrls,
            'rating': beach.rating,
            'reviewCount': beach.reviewCount,
            'currentCondition': beach.currentCondition,
            'amenities': beach.amenities,
            'activities': beach.activities,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          print('✅ Playa ${beach.name} sincronizada con Firestore');
        }
      }
    } catch (e) {
      print('Error sincronizando playas: $e');
    }
  }

  // Método auxiliar para obtener playas locales
  static List<Beach> _getLocalBeaches() {
    return BeachService.getDominicanBeaches();
  }

  // Obtener todas las playas
  static Stream<List<Beach>> getBeaches() {
    return _firestore
        .collection('beaches')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Beach.fromFirestore(doc)).toList(),
        );
  }

  // Obtener playa por ID
  static Future<Beach?> getBeachById(String beachId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('beaches')
          .doc(beachId)
          .get();
      if (doc.exists) {
        return Beach.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo playa: $e');
      return null;
    }
  }

  // Buscar playas por provincia
  static Stream<List<Beach>> getBeachesByProvince(String province) {
    return _firestore
        .collection('beaches')
        .where('province', isEqualTo: province)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Beach.fromFirestore(doc)).toList(),
        );
  }

  // =======================
  // REPORTES
  // =======================

  // Crear nuevo reporte
  static Future<String?> createReport(BeachReport report) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('reports')
          .add(report.toFirestore());

      // Incrementar contador de reportes del usuario
      await _firestore.collection('users').doc(report.userId).update({
        'reportsCount': FieldValue.increment(1),
      });

      // Notificar a usuarios que tienen esta playa como favorita
      _notifyFavoriteBeachUsers(report);

      // Actualizar condición de la playa (tomar la condición más reciente)
      // Verificar si la playa existe antes de actualizar
      DocumentSnapshot beachDoc = await _firestore
          .collection('beaches')
          .doc(report.beachId)
          .get();

      if (beachDoc.exists) {
        await _firestore.collection('beaches').doc(report.beachId).update({
          'currentCondition': report.condition,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        print('⚠️ Playa con ID ${report.beachId} no existe en Firestore');
        // Buscar la playa en los datos locales y crearla
        final localBeaches = _getLocalBeaches();
        final localBeach = localBeaches.firstWhere(
          (beach) => beach.id == report.beachId,
          orElse: () => throw Exception('Playa no encontrada en datos locales'),
        );

        // Crear la playa en Firestore con todos los datos
        await _firestore.collection('beaches').doc(report.beachId).set({
          'id': localBeach.id,
          'name': localBeach.name,
          'province': localBeach.province,
          'municipality': localBeach.municipality,
          'description': localBeach.description,
          'latitude': localBeach.latitude,
          'longitude': localBeach.longitude,
          'imageUrls': localBeach.imageUrls,
          'rating': localBeach.rating,
          'reviewCount': localBeach.reviewCount,
          'currentCondition': report.condition, // Usar la condición del reporte
          'amenities': localBeach.amenities,
          'activities': localBeach.activities,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print('✅ Playa ${localBeach.name} creada en Firestore');
      }

      return docRef.id;
    } catch (e) {
      print('Error creando reporte: $e');
      return null;
    }
  }

  // Obtener reportes de una playa
  static Stream<List<BeachReport>> getBeachReports(String beachId) {
    return _firestore
        .collection('reports')
        .where('beachId', isEqualTo: beachId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BeachReport.fromFirestore(doc))
              .toList(),
        );
  }

  // Marcar reporte como útil
  static Future<void> markReportHelpful(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({
      'helpfulCount': FieldValue.increment(1),
    });
  }

  // Notificar a usuarios que tienen la playa como favorita (llamado internamente)
  static void _notifyFavoriteBeachUsers(BeachReport report) async {
    try {
      // Obtener nombre de la playa
      final localBeaches = _getLocalBeaches();
      final beach = localBeaches.firstWhere(
        (b) => b.id == report.beachId,
        orElse: () => Beach(
          id: report.beachId,
          name: 'Una playa',
          province: '',
          municipality: '',
          description: '',
          latitude: 0,
          longitude: 0,
          imageUrls: const [],
          rating: 0,
          reviewCount: 0,
          currentCondition: 'Desconocido',
          amenities: const {},
          activities: const [],
        ),
      );

      // Enviar notificación local (esto se enviará a todos los usuarios con la app)
      // En producción, esto debería ser una Cloud Function que envíe push notifications
      await NotificationHelper.sendNewReportInFavoriteBeach(
        beach.name,
        report.condition,
      );
      
      print('🔔 Notificación enviada: Nuevo reporte en ${beach.name}');
    } catch (e) {
      print('⚠️ Error enviando notificación: $e');
    }
  }
}

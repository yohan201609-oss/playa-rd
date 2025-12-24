import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../models/beach.dart';
import '../utils/notification_helper.dart';
import 'beach_service.dart';
import 'google_places_service.dart';

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

  // Reautenticar usuario con email y contraseña
  static Future<bool> reauthenticateWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Usuario reautenticado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error en reautenticación: $e');
      rethrow;
    }
  }

  // Reautenticar usuario con Google
  static Future<bool> reauthenticateWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return false; // Usuario canceló
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Usuario reautenticado con Google exitosamente');
      return true;
    } catch (e) {
      print('❌ Error en reautenticación con Google: $e');
      rethrow;
    }
  }

  // Iniciar sesión con Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Configurar Google Sign-In
      // El serverClientId es el Web Client ID necesario para obtener el idToken
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6.apps.googleusercontent.com',
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
          'photoUrl': userCredential.user!.photoURL,
          'provider': 'google',
          'favoriteBeaches': [],
          'reportsCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      print('❌ Error en Google Sign-In: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Iniciar sesión con Apple
  static Future<UserCredential?> signInWithApple() async {
    try {
      // Solicitar credencial de Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Crear credencial de Firebase con los datos de Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Iniciar sesión con Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        oauthCredential,
      );

      // Si el usuario es nuevo y Apple proporcionó nombre, actualizarlo
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty && userCredential.user != null) {
          await userCredential.user?.updateDisplayName(displayName);
        }
      }

      // Crear o actualizar documento de usuario en Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email ?? appleCredential.email ?? '',
          'displayName':
              userCredential.user!.displayName ??
              '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                  .trim(),
          'photoUrl': userCredential.user!.photoURL,
          'provider': 'apple',
          'favoriteBeaches': [],
          'reportsCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      print('❌ Error en Apple Sign-In: $e');
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
        final data = doc.data() as Map<String, dynamic>?;
        // Si la cuenta está desactivada temporalmente, no devolver datos
        if (data != null && data['isActive'] == false) {
          print('⚠️ Cuenta desactivada temporalmente: $userId');
          return null;
        }
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }

  // Obtener el conteo real de reportes de un usuario
  static Future<int> getUserReportsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error obteniendo conteo de reportes: $e');
      return 0;
    }
  }

  // Sincronizar el contador de reportes del usuario con el conteo real
  static Future<void> syncUserReportsCount(String userId) async {
    try {
      final realCount = await getUserReportsCount(userId);
      await _firestore.collection('users').doc(userId).update({
        'reportsCount': realCount,
      });
      print(
        '✅ Contador de reportes sincronizado para usuario $userId: $realCount',
      );
    } catch (e) {
      print('⚠️ Error sincronizando contador de reportes: $e');
    }
  }

  // Agregar playa a favoritos
  static Future<void> addFavoriteBeach(String userId, String beachId) async {
    try {
      print('💖 Agregando playa $beachId a favoritos del usuario $userId');

      // Verificar que el documento del usuario exista
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('⚠️ El documento del usuario no existe, creándolo...');
        await _firestore.collection('users').doc(userId).set({
          'favoriteBeaches': [beachId],
          'visitedBeaches': [],
          'reportsCount': 0,
        }, SetOptions(merge: true));
        print('✅ Documento de usuario creado con favorito');
        return;
      }

      // Verificar que el campo favoriteBeaches exista, si no, inicializarlo
      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('favoriteBeaches')) {
        print('⚠️ El campo favoriteBeaches no existe, inicializándolo...');
        await _firestore.collection('users').doc(userId).set({
          'favoriteBeaches': [beachId],
        }, SetOptions(merge: true));
        print('✅ Campo favoriteBeaches inicializado');
        return;
      }

      // Actualizar favoritos
      await _firestore.collection('users').doc(userId).update({
        'favoriteBeaches': FieldValue.arrayUnion([beachId]),
      });

      // Verificar que se guardó correctamente
      final updatedDoc = await _firestore.collection('users').doc(userId).get();
      final favorites = List<String>.from(
        updatedDoc.data()?['favoriteBeaches'] ?? [],
      );
      print(
        '✅ Playa agregada a favoritos. Total favoritos: ${favorites.length}',
      );
      print('📋 Favoritos actuales: $favorites');
    } catch (e) {
      print('❌ Error agregando playa a favoritos: $e');
      rethrow;
    }
  }

  // Remover playa de favoritos
  static Future<void> removeFavoriteBeach(String userId, String beachId) async {
    try {
      print('💔 Removiendo playa $beachId de favoritos del usuario $userId');

      // Verificar que el documento del usuario exista
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('⚠️ El documento del usuario no existe');
        return;
      }

      // Verificar que el campo favoriteBeaches exista
      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('favoriteBeaches')) {
        print('⚠️ El campo favoriteBeaches no existe, no hay nada que remover');
        return;
      }

      // Actualizar favoritos
      await _firestore.collection('users').doc(userId).update({
        'favoriteBeaches': FieldValue.arrayRemove([beachId]),
      });

      // Verificar que se guardó correctamente
      final updatedDoc = await _firestore.collection('users').doc(userId).get();
      final favorites = List<String>.from(
        updatedDoc.data()?['favoriteBeaches'] ?? [],
      );
      print(
        '✅ Playa removida de favoritos. Total favoritos: ${favorites.length}',
      );
      print('📋 Favoritos actuales: $favorites');
    } catch (e) {
      print('❌ Error removiendo playa de favoritos: $e');
      rethrow;
    }
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

  // Actualizar foto de perfil del usuario
  static Future<String?> updateProfilePhoto(
    String userId,
    File imageFile,
  ) async {
    try {
      // Crear referencia en Storage: profiles/{userId}/{timestamp}.jpg
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$timestamp.jpg';
      final ref = FirebaseStorage.instance.ref().child(
        'profiles/$userId/$fileName',
      );

      // Subir imagen
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Actualizar Firebase Auth
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(downloadUrl);
        await user.reload();
      }

      // Actualizar Firestore
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': downloadUrl,
      });

      print('✅ Foto de perfil actualizada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error actualizando foto de perfil: $e');
      rethrow;
    }
  }

  // Eliminar cuenta temporalmente (desactivar)
  static Future<bool> deleteAccountTemporary(String userId) async {
    try {
      // Marcar cuenta como desactivada en Firestore
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'fcmToken': null, // Eliminar token FCM para no recibir notificaciones
      });

      // Cerrar sesión del usuario
      await _auth.signOut();

      print('✅ Cuenta desactivada temporalmente: $userId');
      return true;
    } catch (e) {
      print('❌ Error desactivando cuenta: $e');
      rethrow;
    }
  }

  // Eliminar cuenta permanentemente
  static Future<bool> deleteAccountPermanent(
    String userId, {
    String? password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        throw Exception('Usuario no autenticado o ID no coincide');
      }

      // Intentar eliminar directamente, si falla por requires-recent-login, reautenticar
      try {
        // 1. Eliminar fotos de perfil del Storage
        try {
          final storageRef = FirebaseStorage.instance.ref().child(
            'profiles/$userId',
          );
          final listResult = await storageRef.listAll();

          // Eliminar todos los archivos en la carpeta del usuario
          await Future.wait(listResult.items.map((ref) => ref.delete()));
          print('✅ Fotos de perfil eliminadas del Storage');
        } catch (e) {
          print(
            '⚠️ Error eliminando fotos de Storage (puede que no existan): $e',
          );
          // Continuar aunque falle, no es crítico
        }

        // 2. Marcar reportes como anónimos (opcional: eliminar userId)
        try {
          final reportsSnapshot = await _firestore
              .collection('reports')
              .where('userId', isEqualTo: userId)
              .get();

          final batch = _firestore.batch();
          for (final doc in reportsSnapshot.docs) {
            batch.update(doc.reference, {
              'userId': 'deleted_user',
              'userDisplayName': 'Usuario eliminado',
            });
          }
          await batch.commit();
          print('✅ Reportes marcados como anónimos');
        } catch (e) {
          print('⚠️ Error actualizando reportes: $e');
          // Continuar aunque falle
        }

        // 3. Eliminar documento del usuario en Firestore
        await _firestore.collection('users').doc(userId).delete();
        print('✅ Documento de usuario eliminado de Firestore');

        // 4. Eliminar cuenta de Firebase Auth
        await user.delete();
        print('✅ Cuenta eliminada de Firebase Auth');

        print('✅ Cuenta eliminada permanentemente: $userId');
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // Necesita reautenticación
          print('⚠️ Se requiere reautenticación reciente');

          // Si se proporcionó contraseña, intentar reautenticar
          if (password != null && user.email != null) {
            try {
              await reauthenticateWithEmail(user.email!, password);
              // Reintentar eliminar después de reautenticar
              return await deleteAccountPermanent(userId);
            } catch (reauthError) {
              print('❌ Error en reautenticación: $reauthError');
              rethrow;
            }
          } else {
            // Lanzar error para que la UI solicite reautenticación
            rethrow;
          }
        } else {
          rethrow;
        }
      }
    } catch (e) {
      print('❌ Error eliminando cuenta permanentemente: $e');
      rethrow;
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
          final beachData = <String, dynamic>{
            'id': beach.id,
            'name': beach.name,
            'province': beach.province,
            'municipality': beach.municipality,
            'description': beach.description,
            'descriptionEn': beach.descriptionEn ?? '',
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
          };

          // Agregar campos opcionales si existen
          if (beach.postalCode != null && beach.postalCode!.isNotEmpty) {
            beachData['postalCode'] = beach.postalCode!;
          }
          if (beach.address != null && beach.address!.isNotEmpty) {
            beachData['address'] = beach.address!;
          }

          await _firestore.collection('beaches').doc(beach.id).set(beachData);
          print('✅ Playa ${beach.name} sincronizada con Firestore');
        } else {
          // Actualizar playa existente para asegurar que tenga descriptionEn
          final existingData = doc.data() as Map<String, dynamic>?;
          final existingDescriptionEn =
              existingData?['descriptionEn'] as String?;
          if (existingDescriptionEn == null || existingDescriptionEn.isEmpty) {
            final updateData = <String, dynamic>{
              'lastUpdated': FieldValue.serverTimestamp(),
            };
            if (beach.descriptionEn != null &&
                beach.descriptionEn!.isNotEmpty) {
              updateData['descriptionEn'] = beach.descriptionEn;
            }
            await _firestore
                .collection('beaches')
                .doc(beach.id)
                .update(updateData);
            print('✅ Descripción en inglés agregada a ${beach.name}');
          }
        }
      }
    } catch (e) {
      print('Error sincronizando playas: $e');
    }
  }

  // Actualizar todas las playas en Firestore con descripciones en inglés
  // Esta función actualiza TODAS las playas en Firebase, incluso las que no están en el archivo local
  static Future<void> updateAllBeachesWithEnglishDescriptions() async {
    try {
      print('🔄 Iniciando actualización de descripciones en inglés...');

      // Obtener todas las playas de Firestore
      final snapshot = await _firestore.collection('beaches').get();
      final allBeaches = snapshot.docs;

      print('📊 Encontradas ${allBeaches.length} playas en Firestore');

      // Obtener playas locales para mapear traducciones
      final localBeaches = _getLocalBeaches();
      final localBeachesMap = <String, Beach>{};
      // También crear un mapa por nombre para buscar por nombre si no hay por ID
      final localBeachesByName = <String, Beach>{};
      for (final beach in localBeaches) {
        localBeachesMap[beach.id] = beach;
        localBeachesByName[beach.name.toLowerCase().trim()] = beach;
      }

      int updated = 0;
      int skipped = 0;
      int notFound = 0;
      int needsTranslation = 0;

      for (final doc in allBeaches) {
        final data = doc.data();
        final beachId = doc.id;
        final beachName = data['name'] ?? 'Sin nombre';
        final existingDescriptionEn = data['descriptionEn'];
        final description = data['description'] ?? '';

        // Si ya tiene descriptionEn y no está vacío, saltar
        if (existingDescriptionEn != null &&
            existingDescriptionEn.toString().trim().isNotEmpty) {
          skipped++;
          continue;
        }

        bool wasUpdated = false;

        // Buscar en playas locales por ID
        if (localBeachesMap.containsKey(beachId)) {
          final localBeach = localBeachesMap[beachId]!;
          if (localBeach.descriptionEn != null &&
              localBeach.descriptionEn!.trim().isNotEmpty) {
            await _firestore.collection('beaches').doc(beachId).update({
              'descriptionEn': localBeach.descriptionEn,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
            updated++;
            wasUpdated = true;
            print('✅ Actualizada por ID: $beachName (ID: $beachId)');
          }
        }
        // Si no se encontró por ID, intentar buscar por nombre
        else if (localBeachesByName.containsKey(
          beachName.toLowerCase().trim(),
        )) {
          final localBeach =
              localBeachesByName[beachName.toLowerCase().trim()]!;
          if (localBeach.descriptionEn != null &&
              localBeach.descriptionEn!.trim().isNotEmpty) {
            await _firestore.collection('beaches').doc(beachId).update({
              'descriptionEn': localBeach.descriptionEn,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
            updated++;
            wasUpdated = true;
            print('✅ Actualizada por nombre: $beachName (ID: $beachId)');
          }
        }

        // Si no se encontró en el archivo local
        if (!wasUpdated) {
          notFound++;

          // Si tiene descripción en español, usar la descripción en español como temporal
          // Esto evita que se muestre "auto translate" o placeholder molesto
          // El usuario verá la descripción en español mientras no haya traducción manual
          if (description.isNotEmpty) {
            // Usar la descripción en español directamente (sin prefijos molestos)
            // En el futuro se puede mejorar con una API de traducción
            await _firestore.collection('beaches').doc(beachId).update({
              'descriptionEn': description, // Usar español temporalmente
              'lastUpdated': FieldValue.serverTimestamp(),
            });
            updated++;
            print(
              '✅ Descripción temporal (español) agregada: $beachName (ID: $beachId)',
            );
          } else {
            needsTranslation++;
            print(
              '⚠️ Playa sin descripción ni traducción: $beachName (ID: $beachId)',
            );
          }
        }
      }

      print('');
      print('✅ Actualización completada:');
      print('   - Actualizadas: $updated');
      print('   - Omitidas (ya tenían traducción): $skipped');
      print('   - No encontradas en archivo local: $notFound');
      print('   - Necesitan traducción manual: $needsTranslation');
      print('   - Total procesadas: ${allBeaches.length}');

      if (needsTranslation > 0) {
        print('');
        print(
          '⚠️ ATENCIÓN: $needsTranslation playas aún necesitan traducción manual.',
        );
        print(
          '   Considera agregarlas al archivo lib/services/beach_service.dart',
        );
      }
    } catch (e) {
      print('❌ Error actualizando descripciones: $e');
      rethrow;
    }
  }

  // Método auxiliar para obtener playas locales
  static List<Beach> _getLocalBeaches() {
    return BeachService.getDominicanBeaches();
  }

  // Obtener todas las playas
  // Los datos de rating, reviewCount y currentCondition se calculan desde reportes reales
  static Stream<List<Beach>> getBeaches() {
    return _firestore.collection('beaches').snapshots().asyncMap((
      snapshot,
    ) async {
      final beaches = snapshot.docs
          .map((doc) => Beach.fromFirestore(doc))
          .toList();

      // Actualizar estadísticas desde reportes para todas las playas
      // Hacerlo de forma asíncrona para no bloquear el stream
      final updatedBeaches = await Future.wait(
        beaches.map((beach) async {
          try {
            final stats = await calculateBeachStatsFromReports(beach.id);

            // Solo actualizar si hay diferencias
            if (beach.reviewCount == 0 ||
                (stats['reviewCount'] as int) != beach.reviewCount ||
                (stats['currentCondition'] as String) !=
                    beach.currentCondition) {
              // Actualizar en Firestore de forma asíncrona (no esperar)
              _firestore
                  .collection('beaches')
                  .doc(beach.id)
                  .update({
                    'rating': stats['rating'],
                    'reviewCount': stats['reviewCount'],
                    'currentCondition': stats['currentCondition'],
                    'lastUpdated': FieldValue.serverTimestamp(),
                  })
                  .catchError((e) {
                    print(
                      '⚠️ Error actualizando estadísticas de ${beach.name}: $e',
                    );
                  });

              // Retornar playa actualizada
              return beach.copyWith(
                rating: stats['rating'] as double,
                reviewCount: stats['reviewCount'] as int,
                currentCondition: stats['currentCondition'] as String,
              );
            }

            return beach;
          } catch (e) {
            print('⚠️ Error calculando estadísticas para ${beach.name}: $e');
            return beach;
          }
        }),
      );

      return updatedBeaches;
    });
  }

  // Obtener todas las playas (una sola vez, no stream)
  // Los datos de rating, reviewCount y currentCondition se calculan desde reportes reales
  static Future<List<Beach>> getBeachesOnce() async {
    try {
      final snapshot = await _firestore.collection('beaches').get();
      final beaches = snapshot.docs
          .map((doc) => Beach.fromFirestore(doc))
          .toList();

      // Actualizar estadísticas desde reportes para todas las playas
      // Esto asegura que los datos estén siempre actualizados
      final updatedBeaches = await Future.wait(
        beaches.map((beach) async {
          try {
            final stats = await calculateBeachStatsFromReports(beach.id);

            // Solo actualizar si hay diferencias significativas o si no hay datos
            if (beach.reviewCount == 0 ||
                (stats['reviewCount'] as int) != beach.reviewCount ||
                (stats['currentCondition'] as String) !=
                    beach.currentCondition) {
              // Actualizar en Firestore de forma asíncrona (no esperar)
              _firestore
                  .collection('beaches')
                  .doc(beach.id)
                  .update({
                    'rating': stats['rating'],
                    'reviewCount': stats['reviewCount'],
                    'currentCondition': stats['currentCondition'],
                    'lastUpdated': FieldValue.serverTimestamp(),
                  })
                  .catchError((e) {
                    print(
                      '⚠️ Error actualizando estadísticas de ${beach.name}: $e',
                    );
                  });

              // Retornar playa actualizada
              return beach.copyWith(
                rating: stats['rating'] as double,
                reviewCount: stats['reviewCount'] as int,
                currentCondition: stats['currentCondition'] as String,
              );
            }

            return beach;
          } catch (e) {
            print('⚠️ Error calculando estadísticas para ${beach.name}: $e');
            return beach;
          }
        }),
      );

      return updatedBeaches;
    } catch (e) {
      print('Error obteniendo playas de Firestore: $e');
      return [];
    }
  }

  // Obtener playa por ID
  // Los datos de rating, reviewCount y currentCondition se calculan desde reportes reales
  static Future<Beach?> getBeachById(String beachId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('beaches')
          .doc(beachId)
          .get();
      if (doc.exists) {
        final beach = Beach.fromFirestore(doc);

        // Calcular estadísticas desde reportes
        final stats = await calculateBeachStatsFromReports(beachId);

        // Actualizar en Firestore si hay diferencias
        if (beach.reviewCount == 0 ||
            (stats['reviewCount'] as int) != beach.reviewCount ||
            (stats['currentCondition'] as String) != beach.currentCondition) {
          // Actualizar en Firestore
          await _firestore.collection('beaches').doc(beachId).update({
            'rating': stats['rating'],
            'reviewCount': stats['reviewCount'],
            'currentCondition': stats['currentCondition'],
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          // Retornar playa actualizada
          return beach.copyWith(
            rating: stats['rating'] as double,
            reviewCount: stats['reviewCount'] as int,
            currentCondition: stats['currentCondition'] as String,
          );
        }

        return beach;
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

  // Actualizar o crear una playa (usa set con merge para crear si no existe)
  static Future<void> updateBeach(Beach beach) async {
    try {
      await _firestore.collection('beaches').doc(beach.id).set({
        'name': beach.name,
        'province': beach.province,
        'municipality': beach.municipality,
        'postalCode': beach.postalCode,
        'address': beach.address,
        'description': beach.description,
        'descriptionEn': beach.descriptionEn,
        'latitude': beach.latitude,
        'longitude': beach.longitude,
        'imageUrls': beach.imageUrls,
        'rating': beach.rating,
        'reviewCount': beach.reviewCount,
        'currentCondition': beach.currentCondition,
        'amenities': beach.amenities,
        'activities': beach.activities,
        'isFavorite': beach.isFavorite,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Usar merge para crear o actualizar
      print('✅ Playa ${beach.name} guardada en Firestore');
    } catch (e) {
      print('❌ Error guardando playa en Firestore: $e');
      rethrow;
    }
  }

  // Actualizar solo la descripción en inglés de una playa específica
  // Útil para actualizar playas individuales desde la app o scripts
  static Future<void> updateBeachEnglishDescription(
    String beachId,
    String englishDescription,
  ) async {
    try {
      await _firestore.collection('beaches').doc(beachId).update({
        'descriptionEn': englishDescription,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('✅ Descripción en inglés actualizada para playa ID: $beachId');
    } catch (e) {
      print('❌ Error actualizando descripción en inglés: $e');
      rethrow;
    }
  }

  // Actualizar descripción en inglés de una playa por nombre
  static Future<void> updateBeachEnglishDescriptionByName(
    String beachName,
    String englishDescription,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('beaches')
          .where('name', isEqualTo: beachName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ No se encontró playa con nombre: $beachName');
        return;
      }

      final doc = querySnapshot.docs.first;
      await doc.reference.update({
        'descriptionEn': englishDescription,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      print('✅ Descripción en inglés actualizada para: $beachName');
    } catch (e) {
      print('❌ Error actualizando descripción en inglés: $e');
      rethrow;
    }
  }

  // Eliminar URLs de imágenes de las 45 playas originales (IDs 1-45)
  static Future<void> removeImageUrlsFromOriginalBeaches() async {
    try {
      print(
        '🔄 Iniciando eliminación de URLs de imágenes de las 45 playas originales...',
      );

      int updated = 0;
      int notFound = 0;
      int errors = 0;

      // IDs de las 45 playas originales
      final List<String> originalBeachIds = List.generate(
        45,
        (index) => '${index + 1}',
      );

      for (final beachId in originalBeachIds) {
        try {
          final docRef = _firestore.collection('beaches').doc(beachId);
          final doc = await docRef.get();

          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            final beachName = data['name'] ?? 'Sin nombre';

            // Actualizar imageUrls a lista vacía
            await docRef.update({
              'imageUrls': <String>[],
              'lastUpdated': FieldValue.serverTimestamp(),
            });

            updated++;
            print('✅ Eliminadas imágenes de: $beachName (ID: $beachId)');
          } else {
            notFound++;
            print('⚠️ Playa no encontrada en Firebase: ID $beachId');
          }
        } catch (e) {
          errors++;
          print('❌ Error actualizando playa ID $beachId: $e');
        }
      }

      print('');
      print('✅ Proceso completado:');
      print('   - Actualizadas: $updated');
      print('   - No encontradas: $notFound');
      print('   - Errores: $errors');
      print('   - Total procesadas: ${originalBeachIds.length}');
    } catch (e) {
      print('❌ Error eliminando URLs de imágenes: $e');
      rethrow;
    }
  }

  // Obtener fotos de las 45 playas originales desde Google Places API
  static Future<void> fetchPhotosFromGooglePlacesForOriginalBeaches({
    Function(int current, int total, String name)? onProgress,
  }) async {
    try {
      print(
        '🔄 Iniciando obtención de fotos desde Google Places API para las 45 playas originales...\n',
      );

      // Obtener playas locales (las 45 originales)
      final localBeaches = _getLocalBeaches();
      final originalBeaches = localBeaches.where((beach) {
        final id = int.tryParse(beach.id);
        return id != null && id >= 1 && id <= 45;
      }).toList();

      print('📊 Total de playas a procesar: ${originalBeaches.length}\n');

      int updated = 0;
      int notFound = 0;
      int noPhotos = 0;
      int errors = 0;

      for (int i = 0; i < originalBeaches.length; i++) {
        final beach = originalBeaches[i];

        try {
          // Reportar progreso
          if (onProgress != null) {
            onProgress(i + 1, originalBeaches.length, beach.name);
          }

          print(
            '🔄 [${i + 1}/${originalBeaches.length}] Buscando fotos para: ${beach.name}',
          );

          // Buscar fotos usando Google Places API
          final photos = await GooglePlacesService.getBeachPhotos(
            beach.name,
            province: beach.province,
            municipality: beach.municipality,
            latitude: beach.latitude,
            longitude: beach.longitude,
            maxPhotos: 5, // Obtener hasta 5 fotos
          );

          if (photos.isEmpty) {
            noPhotos++;
            print('⚠️ No se encontraron fotos para: ${beach.name}');
          } else {
            // Actualizar en Firebase
            final docRef = _firestore.collection('beaches').doc(beach.id);
            final doc = await docRef.get();

            if (doc.exists) {
              await docRef.update({
                'imageUrls': photos,
                'lastUpdated': FieldValue.serverTimestamp(),
              });

              updated++;
              print('✅ ${photos.length} foto(s) agregada(s) a: ${beach.name}');
            } else {
              notFound++;
              print(
                '⚠️ Playa no encontrada en Firebase: ${beach.name} (ID: ${beach.id})',
              );
            }
          }

          // Pausa entre solicitudes para evitar rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          errors++;
          print('❌ Error procesando ${beach.name}: $e');
        }
      }

      print('');
      print('✅ Proceso completado:');
      print('   - Actualizadas con fotos: $updated');
      print('   - Sin fotos encontradas: $noPhotos');
      print('   - No encontradas en Firebase: $notFound');
      print('   - Errores: $errors');
      print('   - Total procesadas: ${originalBeaches.length}');
    } catch (e) {
      print('❌ Error obteniendo fotos desde Google Places: $e');
      rethrow;
    }
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

      // Esperar un momento para asegurar que el reporte esté disponible en la consulta
      await Future.delayed(const Duration(milliseconds: 500));

      // Calcular estadísticas actualizadas desde todos los reportes
      print('📊 Calculando estadísticas para playa ${report.beachId}...');
      final stats = await calculateBeachStatsFromReports(report.beachId);
      print(
        '📊 Estadísticas calculadas: rating=${stats['rating']}, reviewCount=${stats['reviewCount']}, condition=${stats['currentCondition']}',
      );

      // Verificar si la playa existe antes de actualizar
      DocumentSnapshot beachDoc = await _firestore
          .collection('beaches')
          .doc(report.beachId)
          .get();

      if (beachDoc.exists) {
        // Actualizar playa con datos calculados desde reportes
        await _firestore.collection('beaches').doc(report.beachId).update({
          'rating': stats['rating'],
          'reviewCount': stats['reviewCount'],
          'currentCondition': stats['currentCondition'],
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print(
          '✅ Estadísticas actualizadas desde reportes para playa ${report.beachId}: rating=${stats['rating']}, reviews=${stats['reviewCount']}, condition=${stats['currentCondition']}',
        );
      } else {
        print('⚠️ Playa con ID ${report.beachId} no existe en Firestore');
        // Buscar la playa en los datos locales y crearla
        final localBeaches = _getLocalBeaches();
        final localBeach = localBeaches.firstWhere(
          (beach) => beach.id == report.beachId,
          orElse: () => throw Exception('Playa no encontrada en datos locales'),
        );

        // Crear la playa en Firestore con datos calculados desde reportes
        await _firestore.collection('beaches').doc(report.beachId).set({
          'id': localBeach.id,
          'name': localBeach.name,
          'province': localBeach.province,
          'municipality': localBeach.municipality,
          'description': localBeach.description,
          'descriptionEn': localBeach.descriptionEn,
          'latitude': localBeach.latitude,
          'longitude': localBeach.longitude,
          'imageUrls': localBeach.imageUrls,
          'rating': stats['rating'], // Usar rating calculado desde reportes
          'reviewCount':
              stats['reviewCount'], // Usar reviewCount calculado desde reportes
          'currentCondition':
              stats['currentCondition'], // Usar condición calculada desde reportes
          'amenities': localBeach.amenities,
          'activities': localBeach.activities,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print(
          '✅ Playa ${localBeach.name} creada en Firestore con datos desde reportes',
        );
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

  // Obtener todos los reportes de una playa (sin límite)
  static Future<List<BeachReport>> getAllBeachReports(String beachId) async {
    try {
      // Intentar con orderBy primero
      try {
        final snapshot = await _firestore
            .collection('reports')
            .where('beachId', isEqualTo: beachId)
            .orderBy('timestamp', descending: true)
            .get();

        final reports = snapshot.docs
            .map((doc) => BeachReport.fromFirestore(doc))
            .toList();

        print(
          '✅ Obtenidos ${reports.length} reportes con orderBy para playa $beachId',
        );
        return reports;
      } catch (e) {
        // Si falla con orderBy (puede ser problema de índice), intentar sin orderBy
        print('⚠️ Error con orderBy, intentando sin orderBy: $e');
        final snapshot = await _firestore
            .collection('reports')
            .where('beachId', isEqualTo: beachId)
            .get();

        final reports = snapshot.docs
            .map((doc) => BeachReport.fromFirestore(doc))
            .toList();

        // Ordenar manualmente por timestamp
        reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        print(
          '✅ Obtenidos ${reports.length} reportes sin orderBy para playa $beachId',
        );
        return reports;
      }
    } catch (e) {
      print('❌ Error obteniendo reportes de playa $beachId: $e');
      return [];
    }
  }

  // Calcular datos de playa basándose en reportes reales
  static Future<Map<String, dynamic>> calculateBeachStatsFromReports(
    String beachId,
  ) async {
    try {
      print('🔍 Obteniendo reportes para playa $beachId...');
      final reports = await getAllBeachReports(beachId);
      print('📋 Encontrados ${reports.length} reportes para playa $beachId');

      if (reports.isEmpty) {
        // Si no hay reportes, retornar valores por defecto
        print(
          '⚠️ No hay reportes para playa $beachId, usando valores por defecto',
        );
        return {
          'rating': 0.0,
          'reviewCount': 0,
          'currentCondition': 'Desconocido',
        };
      }

      // Calcular reviewCount (total de reportes)
      final reviewCount = reports.length;

      // Calcular rating promedio
      // Priorizar ratings reales de los reportes, si no hay, usar condiciones como fallback
      double totalRating = 0.0;
      final conditionCounts = <String, int>{
        'Excelente': 0,
        'Bueno': 0,
        'Moderado': 0,
        'Peligroso': 0,
      };

      for (final report in reports) {
        // Si el reporte tiene rating real, usarlo
        if (report.rating != null && report.rating! > 0) {
          totalRating += report.rating!;
        } else {
          // Si no tiene rating, usar condición como fallback
          // Mapeo: Excelente = 5.0, Bueno = 4.0, Moderado = 3.0, Peligroso = 2.0
          switch (report.condition) {
            case 'Excelente':
              totalRating += 5.0;
              conditionCounts['Excelente'] = conditionCounts['Excelente']! + 1;
              break;
            case 'Bueno':
              totalRating += 4.0;
              conditionCounts['Bueno'] = conditionCounts['Bueno']! + 1;
              break;
            case 'Moderado':
              totalRating += 3.0;
              conditionCounts['Moderado'] = conditionCounts['Moderado']! + 1;
              break;
            case 'Peligroso':
              totalRating += 2.0;
              conditionCounts['Peligroso'] = conditionCounts['Peligroso']! + 1;
              break;
          }
        }
      }

      final rating = reviewCount > 0 ? totalRating / reviewCount : 0.0;

      // Calcular condición más común (moda)
      // Si hay empate, priorizar: Excelente > Bueno > Moderado > Peligroso
      String currentCondition = 'Desconocido';
      int maxCount = 0;

      // Orden de prioridad
      final priorityOrder = ['Excelente', 'Bueno', 'Moderado', 'Peligroso'];

      for (final condition in priorityOrder) {
        final count = conditionCounts[condition] ?? 0;
        if (count > maxCount) {
          maxCount = count;
          currentCondition = condition;
        }
      }

      // Si no hay ninguna condición con reportes, usar la más reciente
      if (currentCondition == 'Desconocido' && reports.isNotEmpty) {
        currentCondition = reports.first.condition;
      }

      return {
        'rating': rating,
        'reviewCount': reviewCount,
        'currentCondition': currentCondition,
      };
    } catch (e) {
      print('Error calculando estadísticas de playa: $e');
      return {
        'rating': 0.0,
        'reviewCount': 0,
        'currentCondition': 'Desconocido',
      };
    }
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import '../models/beach.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  AppUser? _appUser;
  bool _isLoading = false;
  String? _errorMessage;
  Function(List<String>)? onFavoritesChanged;
  bool _fcmTokenListenerSetup = false;

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Configurar listener de token FCM al inicializar
    _setupFCMTokenListener();

    // Escuchar cambios de autenticación
    FirebaseService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
        // Reconfigurar listener cuando hay un usuario autenticado
        _setupFCMTokenListener();
      } else {
        _appUser = null;
        // No limpiar favoritos al cerrar sesión - se mantendrán en la UI
        // y se restaurarán correctamente cuando el usuario vuelva a iniciar sesión
        // onFavoritesChanged?.call([]); // Comentado para evitar eliminar favoritos
      }
      notifyListeners();
    });
  }

  // Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    if (_user != null) {
      _appUser = await FirebaseService.getUserData(_user!.uid);

      // Sincronizar contador de reportes si está desactualizado
      if (_appUser != null) {
        final realCount = await FirebaseService.getUserReportsCount(_user!.uid);
        if (_appUser!.reportsCount != realCount) {
          // El contador está desactualizado, sincronizarlo
          await FirebaseService.syncUserReportsCount(_user!.uid);
          // Recargar datos del usuario para obtener el contador actualizado
          _appUser = await FirebaseService.getUserData(_user!.uid);
        }

        // Notificar cambio en favoritos
        onFavoritesChanged?.call(_appUser!.favoriteBeaches);
      }

      // Guardar FCM token para notificaciones push
      await _saveFCMToken();

      notifyListeners();
    }
  }

  // Guardar FCM token para recibir notificaciones push
  Future<void> _saveFCMToken() async {
    if (_user == null) return;

    try {
      final notificationService = NotificationService();
      final firebaseMessaging = FirebaseMessaging.instance;

      // Asegurarse de que el NotificationService esté inicializado
      try {
        await notificationService.initialize();
      } catch (e) {
        print('⚠️ Error inicializando NotificationService: $e');
      }

      // En iOS, verificar permisos antes de intentar obtener tokens
      if (Platform.isIOS) {
        try {
          final settings = await firebaseMessaging.getNotificationSettings();
          if (settings.authorizationStatus != AuthorizationStatus.authorized &&
              settings.authorizationStatus != AuthorizationStatus.provisional) {
            print(
              '⚠️ Permisos de notificación no concedidos. Estado: ${settings.authorizationStatus}',
            );
            print('ℹ️ Solicitando permisos...');
            final newSettings = await firebaseMessaging.requestPermission(
              alert: true,
              badge: true,
              sound: true,
              provisional: false,
            );
            if (newSettings.authorizationStatus !=
                    AuthorizationStatus.authorized &&
                newSettings.authorizationStatus !=
                    AuthorizationStatus.provisional) {
              print(
                '❌ Permisos de notificación denegados. El token FCM no estará disponible.',
              );
              return;
            }
            print('✅ Permisos de notificación concedidos');
          }
        } catch (e) {
          print('⚠️ Error verificando permisos: $e');
        }
      }

      // Intentar obtener el token inmediatamente desde el servicio
      String? fcmToken = notificationService.fcmToken;

      // En iOS, primero necesitamos asegurarnos de que el token APNS esté disponible
      if (Platform.isIOS && fcmToken == null) {
        print(
          '🍎 iOS detectado: esperando token APNS antes de obtener token FCM...',
        );
        String? apnsToken;

        // Intentar obtener el token APNS primero (con más intentos y delays más largos)
        for (int i = 0; i < 15; i++) {
          try {
            apnsToken = await firebaseMessaging.getAPNSToken();
            if (apnsToken != null) {
              print('✅ Token APNS obtenido después de ${i + 1} intento(s)');
              break;
            }
          } catch (e) {
            // El token APNS aún no está disponible, continuar esperando
            if (i % 3 == 0) {
              print('⏳ Esperando token APNS... (intento ${i + 1})');
            }
          }

          // Esperar antes del siguiente intento (delays más largos)
          if (i < 14) {
            final delaySeconds = i < 5 ? 2 : (i < 10 ? 3 : 5);
            await Future.delayed(Duration(seconds: delaySeconds));
          }
        }

        if (apnsToken == null) {
          print('⚠️ Token APNS no disponible después de 15 intentos');
          print(
            'ℹ️ Esto puede ser normal si la app acaba de iniciarse. El token se obtendrá más tarde.',
          );
        }
      }

      // Si no está disponible, intentar obtenerlo directamente desde FirebaseMessaging
      if (fcmToken == null) {
        try {
          fcmToken = await firebaseMessaging.getToken();
        } catch (e) {
          final errorMsg = e.toString();
          if (errorMsg.contains('apns-token-not-set')) {
            print(
              '⏳ Token APNS aún no configurado, continuando con reintentos...',
            );
          } else {
            print('⚠️ No se pudo obtener token FCM directamente: $e');
          }
        }
      }

      // Si aún no está disponible, intentar con delays (especialmente importante en iOS)
      // En iOS, el token FCM depende del token APNS que puede tardar en estar disponible
      if (fcmToken == null) {
        print('⏳ Token FCM no disponible aún, intentando con delays...');
        for (int i = 0; i < 10; i++) {
          // En iOS, esperar más tiempo entre intentos
          final delaySeconds = Platform.isIOS ? (i < 5 ? 3 : 5) : (i + 1);
          await Future.delayed(Duration(seconds: delaySeconds));

          // En iOS, verificar token APNS antes de cada intento
          if (Platform.isIOS) {
            try {
              final apnsToken = await firebaseMessaging.getAPNSToken();
              if (apnsToken == null) {
                if (i % 2 == 0) {
                  print('⏳ Esperando token APNS... (intento ${i + 1})');
                }
                continue; // Continuar esperando si el token APNS no está disponible
              } else {
                if (i > 0) {
                  print(
                    '✅ Token APNS disponible, intentando obtener token FCM...',
                  );
                }
              }
            } catch (e) {
              // Continuar esperando
              continue;
            }
          }

          try {
            fcmToken = await firebaseMessaging.getToken();
            if (fcmToken != null) {
              print('✅ Token FCM obtenido después de ${i + 1} intento(s)');
              break;
            }
          } catch (e) {
            final errorMsg = e.toString();
            if (errorMsg.contains('apns-token-not-set')) {
              if (i % 2 == 0) {
                print(
                  '⏳ Token APNS aún no configurado, esperando... (intento ${i + 1})',
                );
              }
            } else {
              print('⚠️ Intento ${i + 1} fallido: $e');
            }
          }
        }
      }

      if (fcmToken != null && _user != null) {
        await FirebaseService.saveFCMToken(_user!.uid, fcmToken);
        print('📱 FCM Token guardado para usuario ${_user!.email}');
      } else {
        print('⚠️ No se pudo obtener token FCM después de varios intentos');
        print(
          'ℹ️ El token se guardará automáticamente cuando esté disponible mediante el listener',
        );
        // Configurar listener para cuando el token esté disponible
        _setupFCMTokenListener();
      }
    } catch (e) {
      print('⚠️ Error guardando FCM token: $e');
      // Configurar listener para cuando el token esté disponible
      _setupFCMTokenListener();
    }
  }

  // Configurar listener para cuando el token FCM esté disponible
  void _setupFCMTokenListener() {
    // Solo configurar una vez
    if (_fcmTokenListenerSetup) return;

    // Escuchar cambios en el token FCM (se dispara cuando el token está disponible o se actualiza)
    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (_user != null && newToken.isNotEmpty) {
          try {
            await FirebaseService.saveFCMToken(_user!.uid, newToken);
            print(
              '📱 FCM Token guardado (desde listener) para usuario ${_user!.email}',
            );
          } catch (e) {
            print('⚠️ Error guardando FCM token desde listener: $e');
          }
        }
      });

      // También intentar obtener el token periódicamente si no está disponible (especialmente en iOS)
      if (Platform.isIOS) {
        _periodicallyCheckFCMToken();
      }

      _fcmTokenListenerSetup = true;
      print('✅ Listener de token FCM configurado');
    } catch (e) {
      print('⚠️ Error configurando listener de token FCM: $e');
    }
  }

  // Verificar periódicamente el token FCM en iOS (cuando el token APNS puede tardar en estar disponible)
  void _periodicallyCheckFCMToken() {
    if (_user == null) return;

    // Intentar obtener el token después de delays progresivos
    Future.delayed(Duration(seconds: 10), () async {
      if (_user == null) return;
      await _tryGetFCMTokenOnce();
    });

    Future.delayed(Duration(seconds: 30), () async {
      if (_user == null) return;
      await _tryGetFCMTokenOnce();
    });

    Future.delayed(Duration(seconds: 60), () async {
      if (_user == null) return;
      await _tryGetFCMTokenOnce();
    });
  }

  // Intentar obtener el token FCM una vez
  Future<void> _tryGetFCMTokenOnce() async {
    if (_user == null) return;

    try {
      final firebaseMessaging = FirebaseMessaging.instance;

      // En iOS, verificar token APNS primero
      if (Platform.isIOS) {
        try {
          final apnsToken = await firebaseMessaging.getAPNSToken();
          if (apnsToken == null) {
            return; // Token APNS aún no disponible
          }
        } catch (e) {
          return; // Error obteniendo token APNS
        }
      }

      // Intentar obtener token FCM
      final fcmToken = await firebaseMessaging.getToken();
      if (fcmToken != null && _user != null) {
        await FirebaseService.saveFCMToken(_user!.uid, fcmToken);
        print(
          '📱 FCM Token guardado (verificación periódica) para usuario ${_user!.email}',
        );
      }
    } catch (e) {
      // Silenciar errores en verificaciones periódicas
    }
  }

  // Recargar datos del usuario (útil después de modificar favoritos)
  Future<void> reloadUserData() async {
    print('🔄 Recargando datos del usuario...');
    await _loadUserData();
    if (_appUser != null) {
      print(
        '✅ Datos del usuario recargados. Favoritos: ${_appUser!.favoriteBeaches.length}',
      );
      print('📋 IDs de favoritos: ${_appUser!.favoriteBeaches}');
    } else {
      print('⚠️ No se pudieron cargar los datos del usuario');
    }
  }

  // Actualizar foto de perfil
  Future<bool> updateProfilePhoto(File imageFile) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final photoUrl = await FirebaseService.updateProfilePhoto(
        _user!.uid,
        imageFile,
      );
      if (photoUrl != null) {
        // Recargar datos del usuario para obtener la nueva foto
        await _loadUserData();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'Error al actualizar la foto de perfil';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar la foto de perfil: $e';
      notifyListeners();
      return false;
    }
  }

  // Registrar nuevo usuario
  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseService.signUpWithEmail(email, password, displayName);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al registrar usuario';
      notifyListeners();
      return false;
    }
  }

  // Iniciar sesión
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión';
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await FirebaseService.signOut();
    _user = null;
    _appUser = null;
    notifyListeners();
  }

  // Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al enviar email de restablecimiento';
      notifyListeners();
      return false;
    }
  }

  // Iniciar sesión con Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await FirebaseService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();

      // Si el resultado es null, el usuario canceló el proceso
      if (result == null) {
        _errorMessage = null; // No mostrar error si el usuario canceló
        return false;
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      print('❌ Error de Firebase Auth: ${e.code} - ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión con Google: ${e.toString()}';
      print('❌ Error en Google Sign-In: $e');
      notifyListeners();
      return false;
    }
  }

  // Iniciar sesión con Apple
  Future<bool> signInWithApple() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await FirebaseService.signInWithApple();
      _isLoading = false;
      notifyListeners();

      // Si el resultado es null, el usuario canceló el proceso
      if (result == null) {
        _errorMessage = null; // No mostrar error si el usuario canceló
        return false;
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      print('❌ Error de Firebase Auth: ${e.code} - ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión con Apple: ${e.toString()}';
      print('❌ Error en Apple Sign-In: $e');
      notifyListeners();
      return false;
    }
  }

  // Mensajes de error localizados
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      default:
        return 'Error de autenticación';
    }
  }

  // Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Eliminar cuenta temporalmente (desactivar)
  Future<bool> deleteAccountTemporary() async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await FirebaseService.deleteAccountTemporary(_user!.uid);
      if (success) {
        _user = null;
        _appUser = null;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al desactivar la cuenta: $e';
      notifyListeners();
      return false;
    }
  }

  // Eliminar cuenta permanentemente
  Future<bool> deleteAccountPermanent({String? password}) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _user!.uid;
      final success = await FirebaseService.deleteAccountPermanent(
        userId,
        password: password,
      );
      if (success) {
        _user = null;
        _appUser = null;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'requires-recent-login') {
        _errorMessage = 'requires-recent-login'; // Código especial para la UI
      } else {
        _errorMessage = 'Error al eliminar la cuenta: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar la cuenta: $e';
      notifyListeners();
      return false;
    }
  }
}

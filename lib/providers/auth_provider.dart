import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Escuchar cambios de autenticación
    FirebaseService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
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
    try {
      final fcmToken = await NotificationService().fcmToken;
      if (fcmToken != null && _user != null) {
        await FirebaseService.saveFCMToken(_user!.uid, fcmToken);
        print('📱 FCM Token guardado para usuario ${_user!.email}');
      }
    } catch (e) {
      print('⚠️ Error guardando FCM token: $e');
    }
  }
  
  // Recargar datos del usuario (útil después de modificar favoritos)
  Future<void> reloadUserData() async {
    print('🔄 Recargando datos del usuario...');
    await _loadUserData();
    if (_appUser != null) {
      print('✅ Datos del usuario recargados. Favoritos: ${_appUser!.favoriteBeaches.length}');
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
      final photoUrl = await FirebaseService.updateProfilePhoto(_user!.uid, imageFile);
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
}

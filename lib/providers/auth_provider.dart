import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        // Notificar que no hay favoritos
        onFavoritesChanged?.call([]);
      }
      notifyListeners();
    });
  }

  // Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    if (_user != null) {
      _appUser = await FirebaseService.getUserData(_user!.uid);
      // Notificar cambio en favoritos
      if (_appUser != null) {
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
    await _loadUserData();
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
      return result != null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión con Google';
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

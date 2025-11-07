import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';

/// Provider para manejar las configuraciones de la aplicación
class SettingsProvider extends ChangeNotifier {
  // Estado de las configuraciones
  String _themeMode = 'system';
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _temperatureUnit = 'celsius';
  String _language = 'es';
  bool _dataCollectionEnabled = true;
  bool _autoSyncEnabled = true;

  // Getters
  String get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationEnabled => _locationEnabled;
  String get temperatureUnit => _temperatureUnit;
  String get language => _language;
  bool get dataCollectionEnabled => _dataCollectionEnabled;
  bool get autoSyncEnabled => _autoSyncEnabled;

  // Getters para UI
  bool get isDarkMode => _themeMode == 'dark';
  bool get isLightMode => _themeMode == 'light';
  bool get isSystemMode => _themeMode == 'system';
  bool get isCelsius => _temperatureUnit == 'celsius';
  bool get isFahrenheit => _temperatureUnit == 'fahrenheit';

  /// Cargar configuraciones desde SharedPreferences
  Future<void> loadSettings() async {
    try {
      _themeMode = PreferencesService.getThemeMode();
      _notificationsEnabled = PreferencesService.getNotificationsEnabled();
      _locationEnabled = PreferencesService.getLocationEnabled();
      _temperatureUnit = PreferencesService.getTemperatureUnit();
      _language = PreferencesService.getLanguage();
      _dataCollectionEnabled = PreferencesService.getDataCollectionEnabled();
      _autoSyncEnabled = PreferencesService.getAutoSyncEnabled();
      
      notifyListeners();
    } catch (e) {
      print('⚠️ Error cargando configuraciones: $e');
    }
  }

  // =======================
  // SETTERS CON PERSISTENCIA
  // =======================

  /// Cambiar modo de tema
  Future<void> setThemeMode(String mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await PreferencesService.setThemeMode(mode);
      notifyListeners();
    }
  }

  /// Cambiar estado de notificaciones
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      await PreferencesService.setNotificationsEnabled(enabled);
      
      // Actualizar el servicio de notificaciones
      try {
        await NotificationService().setNotificationsEnabled(enabled);
        print('✅ Estado de notificaciones actualizado: $enabled');
      } catch (e) {
        print('⚠️ Error actualizando servicio de notificaciones: $e');
      }
      
      notifyListeners();
    }
  }

  /// Cambiar estado de ubicación
  Future<void> setLocationEnabled(bool enabled) async {
    if (_locationEnabled != enabled) {
      _locationEnabled = enabled;
      await PreferencesService.setLocationEnabled(enabled);
      notifyListeners();
    }
  }

  /// Cambiar unidad de temperatura
  Future<void> setTemperatureUnit(String unit) async {
    if (_temperatureUnit != unit) {
      _temperatureUnit = unit;
      await PreferencesService.setTemperatureUnit(unit);
      notifyListeners();
    }
  }

  /// Cambiar idioma
  Future<void> setLanguage(String lang) async {
    if (_language != lang) {
      _language = lang;
      await PreferencesService.setLanguage(lang);
      notifyListeners();
    }
  }

  /// Cambiar estado de recopilación de datos
  Future<void> setDataCollectionEnabled(bool enabled) async {
    if (_dataCollectionEnabled != enabled) {
      _dataCollectionEnabled = enabled;
      await PreferencesService.setDataCollectionEnabled(enabled);
      notifyListeners();
    }
  }

  /// Cambiar estado de sincronización automática
  Future<void> setAutoSyncEnabled(bool enabled) async {
    if (_autoSyncEnabled != enabled) {
      _autoSyncEnabled = enabled;
      await PreferencesService.setAutoSyncEnabled(enabled);
      notifyListeners();
    }
  }

  // =======================
  // UTILIDADES
  // =======================

  /// Restablecer todas las configuraciones a valores por defecto
  Future<void> resetToDefaults() async {
    await PreferencesService.resetToDefaults();
    await loadSettings();
  }

  /// Obtener el ThemeMode de Flutter
  ThemeMode getFlutterThemeMode() {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Obtener el Locale según el idioma configurado
  Locale getLocale() {
    return Locale(_language, '');
  }

  /// Convertir temperatura de Celsius a la unidad configurada
  double convertTemperature(double celsius) {
    if (_temperatureUnit == 'fahrenheit') {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  /// Obtener símbolo de temperatura
  String getTemperatureSymbol() {
    return _temperatureUnit == 'celsius' ? '°C' : '°F';
  }

  /// Formatear temperatura con la unidad configurada
  String formatTemperature(double celsius) {
    final temp = convertTemperature(celsius);
    return '${temp.round()}${getTemperatureSymbol()}';
  }
}


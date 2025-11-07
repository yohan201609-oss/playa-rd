import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar las preferencias compartidas de la aplicación
class PreferencesService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLocationEnabled = 'location_enabled';
  static const String _keyTemperatureUnit = 'temperature_unit';
  static const String _keyLanguage = 'language';
  static const String _keyDataCollection = 'data_collection';
  static const String _keyAutoSync = 'auto_sync';

  static SharedPreferences? _prefs;

  /// Inicializar el servicio
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesService no ha sido inicializado. Llama a init() primero.');
    }
    return _prefs!;
  }

  // =======================
  // TEMA
  // =======================

  /// Obtener el modo de tema guardado
  /// Valores posibles: 'system', 'light', 'dark'
  static String getThemeMode() {
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  /// Guardar el modo de tema
  static Future<bool> setThemeMode(String mode) {
    return prefs.setString(_keyThemeMode, mode);
  }

  // =======================
  // NOTIFICACIONES
  // =======================

  /// Obtener si las notificaciones están habilitadas
  static bool getNotificationsEnabled() {
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  /// Guardar estado de notificaciones
  static Future<bool> setNotificationsEnabled(bool enabled) {
    return prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  // =======================
  // UBICACIÓN
  // =======================

  /// Obtener si la ubicación está habilitada
  static bool getLocationEnabled() {
    return prefs.getBool(_keyLocationEnabled) ?? true;
  }

  /// Guardar estado de ubicación
  static Future<bool> setLocationEnabled(bool enabled) {
    return prefs.setBool(_keyLocationEnabled, enabled);
  }

  // =======================
  // UNIDADES DE TEMPERATURA
  // =======================

  /// Obtener unidad de temperatura
  /// Valores posibles: 'celsius', 'fahrenheit'
  static String getTemperatureUnit() {
    return prefs.getString(_keyTemperatureUnit) ?? 'celsius';
  }

  /// Guardar unidad de temperatura
  static Future<bool> setTemperatureUnit(String unit) {
    return prefs.setString(_keyTemperatureUnit, unit);
  }

  // =======================
  // IDIOMA
  // =======================

  /// Obtener idioma guardado
  /// Valores posibles: 'es', 'en'
  static String getLanguage() {
    return prefs.getString(_keyLanguage) ?? 'es';
  }

  /// Guardar idioma
  static Future<bool> setLanguage(String language) {
    return prefs.setString(_keyLanguage, language);
  }

  // =======================
  // PRIVACIDAD
  // =======================

  /// Obtener si la recopilación de datos está habilitada
  static bool getDataCollectionEnabled() {
    return prefs.getBool(_keyDataCollection) ?? true;
  }

  /// Guardar estado de recopilación de datos
  static Future<bool> setDataCollectionEnabled(bool enabled) {
    return prefs.setBool(_keyDataCollection, enabled);
  }

  // =======================
  // SINCRONIZACIÓN
  // =======================

  /// Obtener si la sincronización automática está habilitada
  static bool getAutoSyncEnabled() {
    return prefs.getBool(_keyAutoSync) ?? true;
  }

  /// Guardar estado de sincronización automática
  static Future<bool> setAutoSyncEnabled(bool enabled) {
    return prefs.setBool(_keyAutoSync, enabled);
  }

  // =======================
  // UTILIDADES
  // =======================

  /// Limpiar todas las preferencias
  static Future<bool> clearAll() {
    return prefs.clear();
  }

  /// Eliminar una preferencia específica
  static Future<bool> remove(String key) {
    return prefs.remove(key);
  }

  /// Restablecer configuración a valores por defecto
  static Future<void> resetToDefaults() async {
    await setThemeMode('system');
    await setNotificationsEnabled(true);
    await setLocationEnabled(true);
    await setTemperatureUnit('celsius');
    await setLanguage('es');
    await setDataCollectionEnabled(true);
    await setAutoSyncEnabled(true);
  }
}


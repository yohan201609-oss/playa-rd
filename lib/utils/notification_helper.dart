import '../services/notification_service.dart';
import '../services/preferences_service.dart';

/// Helper class para enviar notificaciones específicas de la app
class NotificationHelper {
  static final NotificationService _notificationService = NotificationService();

  /// Verificar si las notificaciones están habilitadas antes de enviar
  static bool _canSendNotification() {
    return PreferencesService.getNotificationsEnabled();
  }

  /// Notificación de bienvenida (al abrir la app por primera vez)
  static Future<void> sendWelcomeNotification() async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '🏖️ ¡Bienvenido a Playas RD!',
      body: 'Descubre las mejores playas de República Dominicana',
      payload: 'welcome',
    );
  }

  /// Notificación cuando se marca una playa como favorita
  static Future<void> sendFavoriteBeachNotification(String beachName) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.notifyFavoriteBeach(
      beachName: beachName,
      message: 'Has añadido esta playa a tus favoritos. Te notificaremos sobre condiciones especiales.',
    );
  }

  /// Notificación de condiciones climáticas favorables
  static Future<void> sendGoodWeatherNotification(String beachName) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.notifyWeatherChange(
      beachName: beachName,
      condition: '¡Condiciones perfectas para visitar! ☀️',
    );
  }

  /// Notificación de alerta climática
  static Future<void> sendWeatherAlertNotification(String beachName, String alert) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.notifyWeatherChange(
      beachName: beachName,
      condition: 'Alerta: $alert ⚠️',
    );
  }

  /// Notificación cuando alguien comenta en tu reporte
  static Future<void> sendCommentNotification(String beachName, String userName) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '💬 Nuevo comentario',
      body: '$userName comentó en tu reporte de $beachName',
      payload: 'new_comment',
    );
  }

  /// Notificación de nuevo reporte en playa favorita
  static Future<void> sendNewReportInFavoriteBeach(String beachName, String reportType) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.notifyNewReport(
      beachName: beachName,
      reportType: reportType,
    );
  }

  /// Notificación de recordatorio para actualizar reporte
  static Future<void> sendUpdateReportReminder(String beachName) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '📸 ¿Visitaste $beachName recientemente?',
      body: 'Comparte tu experiencia y ayuda a otros viajeros',
      payload: 'update_reminder',
    );
  }

  /// Notificación de playa cercana (usando geolocalización)
  static Future<void> sendNearbyBeachNotification(String beachName, double distance) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '🗺️ Playa cercana detectada',
      body: '$beachName está a solo ${distance.toStringAsFixed(1)} km de tu ubicación',
      payload: 'nearby_beach',
    );
  }

  /// Notificación de logro desbloqueado
  static Future<void> sendAchievementNotification(String achievement) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '🏆 ¡Logro desbloqueado!',
      body: achievement,
      payload: 'achievement',
    );
  }

  /// Notificación de recomendación de playa
  static Future<void> sendBeachRecommendation(String beachName, String reason) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '✨ Te podría gustar $beachName',
      body: reason,
      payload: 'recommendation',
    );
  }

  /// Notificación de evento especial en playa
  static Future<void> sendSpecialEventNotification(String beachName, String eventName) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '🎉 Evento especial en $beachName',
      body: eventName,
      payload: 'special_event',
    );
  }

  /// Notificación de temporada alta/baja
  static Future<void> sendSeasonalNotification(String season, String message) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '📅 Temporada $season',
      body: message,
      payload: 'seasonal',
    );
  }

  /// Notificación de seguridad (ej: oleaje fuerte)
  static Future<void> sendSafetyAlert(String beachName, String alertMessage) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '⚠️ Alerta de seguridad - $beachName',
      body: alertMessage,
      payload: 'safety_alert',
    );
  }

  /// Notificación de reporte aprobado/destacado
  static Future<void> sendReportApprovedNotification(String beachName) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.sendLocalNotification(
      title: '⭐ ¡Tu reporte fue destacado!',
      body: 'Tu reporte de $beachName ha sido marcado como útil por la comunidad',
      payload: 'report_approved',
    );
  }

  /// Suscribirse a notificaciones de una región específica
  static Future<void> subscribeToRegion(String region) async {
    if (!_canSendNotification()) return;
    
    await _notificationService.subscribeToTopic('region_$region');
    print('✅ Suscrito a notificaciones de la región: $region');
  }

  /// Desuscribirse de notificaciones de una región
  static Future<void> unsubscribeFromRegion(String region) async {
    await _notificationService.unsubscribeFromTopic('region_$region');
    print('✅ Desuscrito de notificaciones de la región: $region');
  }

  /// Suscribirse a alertas climáticas generales
  static Future<void> subscribeToWeatherAlerts() async {
    if (!_canSendNotification()) return;
    
    await _notificationService.subscribeToTopic('weather_alerts');
    print('✅ Suscrito a alertas climáticas');
  }

  /// Desuscribirse de alertas climáticas
  static Future<void> unsubscribeFromWeatherAlerts() async {
    await _notificationService.unsubscribeFromTopic('weather_alerts');
    print('✅ Desuscrito de alertas climáticas');
  }

  /// Limpiar todas las notificaciones
  static Future<void> clearAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
}


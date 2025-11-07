import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Manejador de mensajes en segundo plano (debe ser función de nivel superior)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Mensaje en segundo plano: ${message.messageId}');
  print('Título: ${message.notification?.title}');
  print('Cuerpo: ${message.notification?.body}');
}

/// Servicio para manejar notificaciones push y locales
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  /// Obtener el token FCM del dispositivo
  String? get fcmToken => _fcmToken;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) {
      print('✅ NotificationService ya está inicializado');
      return;
    }

    try {
      // 1. Solicitar permisos
      await _requestPermissions();

      // 2. Configurar notificaciones locales
      await _initializeLocalNotifications();

      // 3. Configurar Firebase Cloud Messaging
      await _initializeFirebaseMessaging();

      // 4. Configurar manejadores de mensajes
      _setupMessageHandlers();

      _initialized = true;
      print('✅ NotificationService inicializado correctamente');
    } catch (e) {
      print('⚠️ Error inicializando NotificationService: $e');
    }
  }

  /// Solicitar permisos de notificaciones
  Future<void> _requestPermissions() async {
    try {
      // Solicitar permisos en iOS y Android 13+
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permisos de notificación concedidos');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Permisos provisionales concedidos');
      } else {
        print('❌ Permisos de notificación denegados');
      }
    } catch (e) {
      print('⚠️ Error solicitando permisos: $e');
    }
  }

  /// Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    try {
      // Configuración para Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Crear canal de notificación para Android
      if (!kIsWeb && Platform.isAndroid) {
        await _createNotificationChannel();
      }

      print('✅ Notificaciones locales configuradas');
    } catch (e) {
      print('⚠️ Error configurando notificaciones locales: $e');
    }
  }

  /// Crear canal de notificación para Android
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'playas_rd_channel', // ID del canal
      'Notificaciones de Playas RD', // Nombre
      description: 'Notificaciones sobre playas, clima y condiciones',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Inicializar Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Obtener token FCM
      _fcmToken = await _firebaseMessaging.getToken();
      print('📱 Token FCM: $_fcmToken');

      // Escuchar cambios en el token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('🔄 Token FCM actualizado: $newToken');
        // Aquí podrías guardar el token en Firestore asociado al usuario
      });

      // Configurar manejador de mensajes en segundo plano
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      print('✅ Firebase Messaging configurado');
    } catch (e) {
      print('⚠️ Error configurando Firebase Messaging: $e');
    }
  }

  /// Configurar manejadores de mensajes
  void _setupMessageHandlers() {
    // Cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Mensaje recibido en primer plano');
      _handleMessage(message, foreground: true);
    });

    // Cuando el usuario toca una notificación (app en segundo plano)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📨 Notificación tocada (app en segundo plano)');
      _handleMessage(message, fromBackground: true);
    });

    // Verificar si la app se abrió desde una notificación
    _checkInitialMessage();
  }

  /// Verificar mensaje inicial (cuando la app se abre desde una notificación)
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('📨 App abierta desde notificación');
      _handleMessage(initialMessage, fromTerminated: true);
    }
  }

  /// Manejar mensaje recibido
  void _handleMessage(
    RemoteMessage message, {
    bool foreground = false,
    bool fromBackground = false,
    bool fromTerminated = false,
  }) {
    print('=== MENSAJE RECIBIDO ===');
    print('ID: ${message.messageId}');
    print('Título: ${message.notification?.title}');
    print('Cuerpo: ${message.notification?.body}');
    print('Datos: ${message.data}');
    print('Foreground: $foreground');
    print('=======================');

    // Si está en primer plano, mostrar notificación local
    if (foreground) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Playas RD',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
      );
    }

    // Aquí puedes agregar lógica para navegar a pantallas específicas
    // según el tipo de notificación (usando message.data)
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'playas_rd_channel',
        'Notificaciones de Playas RD',
        channelDescription: 'Notificaciones sobre playas, clima y condiciones',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond, // ID único
        title,
        body,
        details,
        payload: payload,
      );

      print('✅ Notificación local mostrada');
    } catch (e) {
      print('⚠️ Error mostrando notificación local: $e');
    }
  }

  /// Manejar cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 Notificación tocada');
    print('Payload: ${response.payload}');
    
    // Aquí puedes navegar a pantallas específicas según el payload
    // Por ejemplo, si el payload contiene el ID de una playa,
    // podrías navegar a la pantalla de detalle de esa playa
  }

  // ========================================
  // MÉTODOS PÚBLICOS PARA ENVIAR NOTIFICACIONES
  // ========================================

  /// Enviar notificación local simple
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Notificación de cambio climático en una playa
  Future<void> notifyWeatherChange({
    required String beachName,
    required String condition,
  }) async {
    await sendLocalNotification(
      title: '⛅ Cambio climático en $beachName',
      body: 'Las condiciones han cambiado: $condition',
      payload: 'weather_change',
    );
  }

  /// Notificación de playa favorita
  Future<void> notifyFavoriteBeach({
    required String beachName,
    required String message,
  }) async {
    await sendLocalNotification(
      title: '⭐ $beachName',
      body: message,
      payload: 'favorite_beach',
    );
  }

  /// Notificación de nuevo reporte o comentario
  Future<void> notifyNewReport({
    required String beachName,
    required String reportType,
  }) async {
    await sendLocalNotification(
      title: '📝 Nuevo reporte en $beachName',
      body: 'Se ha publicado un nuevo reporte: $reportType',
      payload: 'new_report',
    );
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('🗑️ Todas las notificaciones canceladas');
  }

  /// Cancelar notificación específica por ID
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    print('🗑️ Notificación $id cancelada');
  }

  /// Suscribirse a un tópico (para notificaciones masivas)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Suscrito al tópico: $topic');
    } catch (e) {
      print('⚠️ Error suscribiendo al tópico $topic: $e');
    }
  }

  /// Desuscribirse de un tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Desuscrito del tópico: $topic');
    } catch (e) {
      print('⚠️ Error desuscribiendo del tópico $topic: $e');
    }
  }

  /// Habilitar/deshabilitar notificaciones
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      // Reactivar permisos
      await _requestPermissions();
      print('✅ Notificaciones habilitadas');
    } else {
      // Cancelar todas las notificaciones pendientes
      await cancelAllNotifications();
      print('❌ Notificaciones deshabilitadas');
    }
  }

  /// Verificar si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}


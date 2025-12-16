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
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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
      // Firebase Messaging solo funciona en Android, iOS y Web
      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
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
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
          print('⚠️ Permisos provisionales concedidos');
        } else {
          print('❌ Permisos de notificación denegados');
        }
      } else {
        print(
          'ℹ️ Permisos de Firebase Messaging no requeridos en esta plataforma',
        );
        print('✅ Permisos de notificación concedidos (solo locales)');
      }
    } catch (e) {
      print('⚠️ Error solicitando permisos: $e');
    }
  }

  /// Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    try {
      // Configuración para Android
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

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
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Inicializar Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Firebase Messaging no está completamente soportado en Windows
      // Solo funciona en Android, iOS y Web
      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
        // En iOS, primero necesitamos obtener el token APNS
        if (Platform.isIOS) {
          try {
            final apnsToken = await _firebaseMessaging.getAPNSToken();
            if (apnsToken != null) {
              print('✅ Token APNS obtenido: $apnsToken');
            } else {
              print(
                '⚠️ Token APNS no disponible aún. Se intentará obtener más tarde.',
              );
              // Intentar obtener el token APNS después de un delay
              Future.delayed(const Duration(seconds: 2), () async {
                final delayedApnsToken = await _firebaseMessaging
                    .getAPNSToken();
                if (delayedApnsToken != null) {
                  print('✅ Token APNS obtenido (retrasado): $delayedApnsToken');
                }
              });
            }
          } catch (e) {
            print('⚠️ Error obteniendo token APNS: $e');
          }
        }

        // Obtener token FCM
        try {
          _fcmToken = await _firebaseMessaging.getToken();
          if (_fcmToken != null) {
            print('');
            print('📱 ==========================================');
            print('📱 TOKEN FCM PARA NOTIFICACIONES PUSH');
            print('📱 ==========================================');
            print('📱 PROPÓSITO: Enviar notificaciones push al dispositivo');
            print(
              '📱 DÓNDE USAR: Firebase Console → Cloud Messaging → Enviar mensaje de prueba',
            );
            print('📱 ==========================================');
            print('📱 TOKEN FCM (copia este para notificaciones):');
            print(_fcmToken);
            print('📱 ==========================================');
            print('✅ INSTRUCCIONES PARA PROBAR NOTIFICACIONES:');
            print('✅ 1. Copia el token FCM de arriba');
            print('✅ 2. Ve a Firebase Console → Cloud Messaging');
            print('✅ 3. Haz clic en "Enviar mensaje de prueba"');
            print('✅ 4. Pega el token FCM en el campo "Token FCM"');
            print('✅ 5. Escribe título y mensaje, luego "Probar"');
            print('');
            print(
              '❌ NO confundas este token con el token de App Check (emoji 🔑)',
            );
            print('');
          } else {
            print(
              '⚠️ Token FCM no disponible. Esto puede ser normal si el token APNS no está configurado.',
            );
          }
        } catch (e) {
          print('⚠️ Error obteniendo token FCM: $e');
          // Intentar de nuevo después de un delay
          Future.delayed(const Duration(seconds: 3), () async {
            try {
              _fcmToken = await _firebaseMessaging.getToken();
              if (_fcmToken != null) {
                print('');
                print('📱 ==========================================');
                print('📱 TOKEN FCM OBTENIDO (retrasado)');
                print('📱 ==========================================');
                print(
                  '📱 PROPÓSITO: Enviar notificaciones push al dispositivo',
                );
                print(
                  '📱 DÓNDE USAR: Firebase Console → Cloud Messaging → Enviar mensaje de prueba',
                );
                print('📱 ==========================================');
                print('📱 TOKEN FCM (copia este para notificaciones):');
                print(_fcmToken);
                print('📱 ==========================================');
                print(
                  '✅ Copia este token para probar notificaciones desde Firebase Console',
                );
                print('');
              }
            } catch (e2) {
              print('⚠️ Error obteniendo token FCM (intento retrasado): $e2');
            }
          });
        }

        // Escuchar cambios en el token
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          print('🔄 Token FCM actualizado: $newToken');
          // Aquí podrías guardar el token en Firestore asociado al usuario
        });

        // Configurar manejador de mensajes en segundo plano
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        print('✅ Firebase Messaging configurado');
      } else {
        print(
          'ℹ️ Firebase Messaging no está disponible en esta plataforma (Windows/Linux/Mac desktop)',
        );
        print('ℹ️ Solo las notificaciones locales estarán disponibles');
      }
    } catch (e) {
      print('⚠️ Error configurando Firebase Messaging: $e');
      // No lanzar el error, permitir que la app continúe con notificaciones locales
    }
  }

  /// Configurar manejadores de mensajes
  void _setupMessageHandlers() {
    // Firebase Messaging solo funciona en Android, iOS y Web
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
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
    } else {
      print(
        'ℹ️ Manejadores de Firebase Messaging no disponibles en esta plataforma',
      );
    }
  }

  /// Verificar mensaje inicial (cuando la app se abre desde una notificación)
  Future<void> _checkInitialMessage() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      try {
        RemoteMessage? initialMessage = await _firebaseMessaging
            .getInitialMessage();
        if (initialMessage != null) {
          print('📨 App abierta desde notificación');
          _handleMessage(initialMessage, fromTerminated: true);
        }
      } catch (e) {
        print('⚠️ Error verificando mensaje inicial: $e');
      }
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
    await _showLocalNotification(title: title, body: body, payload: payload);
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
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      try {
        await _firebaseMessaging.subscribeToTopic(topic);
        print('✅ Suscrito al tópico: $topic');
      } catch (e) {
        print('⚠️ Error suscribiendo al tópico $topic: $e');
      }
    } else {
      print('ℹ️ Suscripción a tópicos no disponible en esta plataforma');
    }
  }

  /// Desuscribirse de un tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      try {
        await _firebaseMessaging.unsubscribeFromTopic(topic);
        print('✅ Desuscrito del tópico: $topic');
      } catch (e) {
        print('⚠️ Error desuscribiendo del tópico $topic: $e');
      }
    } else {
      print('ℹ️ Desuscripción de tópicos no disponible en esta plataforma');
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
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      try {
        final settings = await _firebaseMessaging.getNotificationSettings();
        return settings.authorizationStatus == AuthorizationStatus.authorized;
      } catch (e) {
        print('⚠️ Error verificando estado de notificaciones: $e');
        return false;
      }
    } else {
      // En Windows/Linux/Mac, asumimos que las notificaciones locales están disponibles
      return true;
    }
  }

  // ========================================
  // MÉTODOS PARA OBTENER TOKEN FCM RÁPIDO
  // ========================================

  /// Obtener token FCM de forma rápida (especialmente útil en iOS)
  /// Intenta obtener el token de forma más agresiva con múltiples intentos
  /// Retorna el token si está disponible, o null si no se puede obtener
  Future<String?> getFCMTokenFast({int maxAttempts = 10}) async {
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      print('⚠️ FCM no disponible en esta plataforma');
      return null;
    }

    print('🚀 Intentando obtener token FCM rápidamente...');

    // Paso 1: Verificar permisos primero (especialmente importante en iOS)
    if (Platform.isIOS) {
      try {
        final settings = await _firebaseMessaging.getNotificationSettings();
        print('📋 Estado de permisos: ${settings.authorizationStatus}');

        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          print('⚠️ Permisos de notificación no concedidos');
          print('💡 Solicitando permisos...');

          final newSettings = await _firebaseMessaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

          if (newSettings.authorizationStatus !=
                  AuthorizationStatus.authorized &&
              newSettings.authorizationStatus !=
                  AuthorizationStatus.provisional) {
            print(
              '❌ Permisos denegados. No se puede obtener token FCM sin permisos.',
            );
            return null;
          }

          print(
            '✅ Permisos concedidos, esperando un momento para que el sistema procese...',
          );
          await Future.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        print('⚠️ Error verificando permisos: $e');
      }
    }

    // Paso 2: En iOS, obtener el token APNS primero (con más paciencia)
    if (Platform.isIOS) {
      String? apnsToken;
      print('🍎 iOS detectado: obteniendo token APNS primero...');

      // Intentar más veces con delays progresivamente más largos
      for (int i = 0; i < maxAttempts; i++) {
        try {
          apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken != null) {
            print('✅ Token APNS obtenido en intento ${i + 1}: $apnsToken');
            break;
          }

          // Esperar con delays progresivos: 0.5s, 1s, 1.5s, 2s, etc.
          if (i < maxAttempts - 1) {
            final delayMs = 500 + (i * 500); // 500ms, 1000ms, 1500ms...
            print(
              '⏳ Esperando token APNS... (intento ${i + 2}/${maxAttempts})',
            );
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        } catch (e) {
          print('⚠️ Error obteniendo token APNS (intento ${i + 1}): $e');
          if (i < maxAttempts - 1) {
            final delayMs = 500 + (i * 500);
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        }
      }

      if (apnsToken == null) {
        print('');
        print('⚠️ ==========================================');
        print('⚠️ NO SE PUDO OBTENER TOKEN APNS');
        print('⚠️ ==========================================');
        print('⚠️ Posibles causas:');
        print('⚠️ 1. Permisos de notificación no concedidos');
        print('⚠️ 2. App acaba de iniciar (espera unos segundos)');
        print('⚠️ 3. Problema con configuración APNS en Firebase');
        print('⚠️ 4. Entitlement "aps-environment" no configurado en Xcode');
        print('⚠️ ==========================================');
        print('💡 Intenta:');
        print('💡 - Verificar permisos en Configuración del dispositivo');
        print('💡 - Esperar 10-15 segundos después de iniciar la app');
        print('💡 - Verificar configuración APNS en Firebase Console');
        print('💡 - Revisar Runner.entitlements en Xcode');
        print('');

        // Aún así intentar obtener FCM, a veces funciona sin APNS visible
        print('💡 Intentando obtener token FCM de todas formas...');
      } else {
        // Esperar un momento después de obtener APNS antes de intentar FCM
        print('⏳ Esperando un momento para que FCM procese el token APNS...');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Paso 3: Intentar obtener el token FCM (con más paciencia también)
    print('📱 Intentando obtener token FCM...');
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          _fcmToken = token;
          print('');
          print('✅ ==========================================');
          print('✅ TOKEN FCM OBTENIDO RÁPIDAMENTE');
          print('✅ ==========================================');
          print('✅ Token: $token');
          print('✅ Intentos: ${i + 1}');
          print('✅ ==========================================');
          print('');
          return token;
        }

        // Esperar con delays progresivos
        if (i < maxAttempts - 1) {
          final delayMs = 500 + (i * 500);
          print('⏳ Esperando token FCM... (intento ${i + 2}/${maxAttempts})');
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      } catch (e) {
        final errorMsg = e.toString();
        print('⚠️ Error obteniendo token FCM (intento ${i + 1}): $errorMsg');

        // Si el error es específico de APNS, dar más tiempo
        if (errorMsg.contains('apns-token-not-set') && i < maxAttempts - 1) {
          print('💡 Token APNS aún no disponible, esperando más tiempo...');
          final delayMs = 1000 + (i * 500); // Delays más largos para este caso
          await Future.delayed(Duration(milliseconds: delayMs));
        } else if (i < maxAttempts - 1) {
          final delayMs = 500 + (i * 500);
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      }
    }

    print('');
    print('❌ ==========================================');
    print('❌ NO SE PUDO OBTENER TOKEN FCM');
    print('❌ ==========================================');
    print('❌ Se intentó $maxAttempts veces sin éxito');
    print('');
    print('💡 Soluciones sugeridas:');
    print('💡 1. Verifica que los permisos de notificación estén concedidos');
    print(
      '💡 2. Espera 15-20 segundos después de iniciar la app y vuelve a intentar',
    );
    print('💡 3. Verifica la configuración APNS en Firebase Console');
    print(
      '💡 4. Revisa que Runner.entitlements tenga "aps-environment" configurado',
    );
    print('💡 5. El token se obtendrá automáticamente cuando esté disponible');
    print('');
    return null;
  }

  // ========================================
  // MÉTODOS PARA PROBAR NOTIFICACIONES EN BACKGROUND/KILLED
  // ========================================

  /// Obtener instrucciones para probar notificaciones en background o app muerta
  /// Retorna un mensaje con instrucciones detalladas
  String getBackgroundTestInstructions() {
    return '''
📋 INSTRUCCIONES PARA PROBAR NOTIFICACIONES EN BACKGROUND/APP MUERTA:

1️⃣ OBTENER TOKEN FCM:
   - Usa el botón "Obtener Token FCM Rápido" arriba
   - O copia el token que aparece en los logs

2️⃣ ENVIAR NOTIFICACIÓN DESDE FIREBASE CONSOLE:
   - Ve a Firebase Console → Cloud Messaging
   - Haz clic en "Enviar mensaje de prueba"
   - Pega el token FCM
   - Título: "Prueba Background"
   - Texto: "Esta es una prueba de notificación"
   - Haz clic en "Probar"

3️⃣ PROBAR EN DIFERENTES ESTADOS:

   📱 APP EN PRIMER PLANO:
   - Deberías ver la notificación en la app
   - Revisa los logs: "📨 Mensaje recibido en primer plano"

   📱 APP EN SEGUNDO PLANO:
   - Minimiza la app (no la cierres)
   - Envía la notificación
   - Deberías ver la notificación en el centro de notificaciones
   - Al tocar, la app se abre
   - Revisa los logs: "📨 Notificación tocada (app en segundo plano)"

   📱 APP CERRADA/MUERTA:
   - Cierra completamente la app (swipe up en iOS)
   - Envía la notificación
   - Deberías ver la notificación en el centro de notificaciones
   - Al tocar, la app se abre
   - Revisa los logs: "📨 App abierta desde notificación"

4️⃣ VERIFICAR LOGS:
   - Abre Xcode → Window → Devices and Simulators
   - Selecciona tu dispositivo
   - Revisa los logs para ver qué estado detectó la app

⚠️ IMPORTANTE:
   - Las notificaciones NO funcionan en el simulador iOS
   - Debes usar un dispositivo físico
   - Asegúrate de tener permisos de notificación concedidos
''';
  }

  /// Probar notificación simulada para background/killed state
  /// Muestra instrucciones y el token FCM para usar en Firebase Console
  Future<Map<String, dynamic>> prepareBackgroundTest() async {
    final token = await getFCMTokenFast();
    final enabled = await areNotificationsEnabled();

    return {
      'token': token,
      'notificationsEnabled': enabled,
      'instructions': getBackgroundTestInstructions(),
      'ready': token != null && enabled,
    };
  }

  /// Verificar estado de la app para debugging de notificaciones
  Future<Map<String, dynamic>> getNotificationDebugInfo() async {
    final token = _fcmToken ?? await getFCMTokenFast();
    final enabled = await areNotificationsEnabled();

    String? apnsToken;
    if (Platform.isIOS) {
      try {
        apnsToken = await _firebaseMessaging.getAPNSToken();
      } catch (e) {
        print('⚠️ Error obteniendo token APNS para debug: $e');
      }
    }

    return {
      'fcmToken': token,
      'apnsToken': apnsToken,
      'notificationsEnabled': enabled,
      'platform': Platform.isIOS
          ? 'iOS'
          : (Platform.isAndroid ? 'Android' : 'Other'),
      'initialized': _initialized,
    };
  }
}

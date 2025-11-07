# 📱 Sistema de Notificaciones - Playas RD

## Descripción General

La aplicación Playas RD ahora cuenta con un sistema completo de notificaciones que incluye:
- ✅ **Notificaciones Push** (Firebase Cloud Messaging)
- ✅ **Notificaciones Locales** (Flutter Local Notifications)
- ✅ **Configuración por usuario** (habilitar/deshabilitar desde ajustes)
- ✅ **Múltiples tipos de notificaciones** para diferentes eventos

---

## 🎯 Tipos de Notificaciones Implementadas

### 1. **Notificaciones de Clima**
- Cambios climáticos en playas favoritas
- Alertas de condiciones favorables
- Avisos de mal tiempo o condiciones peligrosas

**Ejemplo de uso:**
```dart
await NotificationHelper.sendGoodWeatherNotification('Playa Bávaro');
await NotificationHelper.sendWeatherAlertNotification('Playa Cabarete', 'Oleaje fuerte');
```

### 2. **Notificaciones de Favoritos**
- Confirmación al añadir playa a favoritos
- Actualizaciones sobre playas favoritas

**Ejemplo de uso:**
```dart
await NotificationHelper.sendFavoriteBeachNotification('Playa Rincón');
```

### 3. **Notificaciones de Reportes**
- Nuevos reportes en playas favoritas
- Comentarios en tus reportes
- Reportes destacados

**Ejemplo de uso:**
```dart
await NotificationHelper.sendNewReportInFavoriteBeach('Punta Cana', 'Condiciones excelentes');
await NotificationHelper.sendCommentNotification('Playa Bávaro', 'Juan Pérez');
await NotificationHelper.sendReportApprovedNotification('Playa Macao');
```

### 4. **Notificaciones de Ubicación**
- Detección de playas cercanas
- Sugerencias basadas en ubicación

**Ejemplo de uso:**
```dart
await NotificationHelper.sendNearbyBeachNotification('Playa Sosúa', 2.5);
```

### 5. **Notificaciones de Eventos**
- Eventos especiales en playas
- Temporadas altas/bajas
- Promociones

**Ejemplo de uso:**
```dart
await NotificationHelper.sendSpecialEventNotification('Playa Bávaro', 'Festival de Jazz');
await NotificationHelper.sendSeasonalNotification('alta', 'La mejor época para visitar las playas');
```

### 6. **Notificaciones de Seguridad**
- Alertas de seguridad
- Avisos de rescate
- Condiciones peligrosas

**Ejemplo de uso:**
```dart
await NotificationHelper.sendSafetyAlert('Playa Cabarete', 'Corrientes fuertes detectadas');
```

### 7. **Notificaciones de Logros**
- Logros desbloqueados
- Hitos alcanzados

**Ejemplo de uso:**
```dart
await NotificationHelper.sendAchievementNotification('Has visitado 10 playas diferentes');
```

---

## 🔧 Configuración

### Permisos Android (AndroidManifest.xml)
✅ Ya configurado con:
- `POST_NOTIFICATIONS` (Android 13+)
- `VIBRATE`
- `RECEIVE_BOOT_COMPLETED`
- `WAKE_LOCK`

### Permisos iOS (Info.plist)
✅ Ya configurado con:
- `UIBackgroundModes` (fetch, remote-notification)
- Configuración de notificaciones de usuario

---

## 💻 Uso en el Código

### Importar el Helper
```dart
import 'package:playas_rd_flutter/utils/notification_helper.dart';
```

### Enviar Notificación Simple
```dart
await NotificationHelper.sendLocalNotification(
  title: 'Título de la notificación',
  body: 'Contenido del mensaje',
  payload: 'identificador',
);
```

### Verificar si las Notificaciones están Habilitadas
Las notificaciones respetan automáticamente la configuración del usuario. El `NotificationHelper` verifica si están habilitadas antes de enviar.

### Suscribirse a Tópicos (Notificaciones Push)
```dart
// Suscribirse a notificaciones de una región
await NotificationHelper.subscribeToRegion('norte');
await NotificationHelper.subscribeToRegion('este');
await NotificationHelper.subscribeToRegion('sur');

// Suscribirse a alertas climáticas
await NotificationHelper.subscribeToWeatherAlerts();

// Desuscribirse
await NotificationHelper.unsubscribeFromRegion('norte');
await NotificationHelper.unsubscribeFromWeatherAlerts();
```

---

## 🎨 Personalización de Notificaciones

### Canal de Notificaciones Android
- **ID**: `playas_rd_channel`
- **Nombre**: Notificaciones de Playas RD
- **Importancia**: Alta
- **Sonido**: ✅ Habilitado
- **Vibración**: ✅ Habilitada

### Iconos
- Android: Usa `@mipmap/ic_launcher`
- iOS: Usa el icono de la app

---

## 🚀 Integración con Firebase Cloud Messaging

### Obtener Token FCM
```dart
final token = NotificationService().fcmToken;
print('Token FCM: $token');
```

Este token puede guardarse en Firestore asociado al usuario para enviar notificaciones push personalizadas desde el servidor.

### Estructura de Mensaje Push (desde servidor)
```json
{
  "to": "TOKEN_FCM_DEL_USUARIO",
  "notification": {
    "title": "Título de la notificación",
    "body": "Mensaje de la notificación"
  },
  "data": {
    "type": "beach_alert",
    "beach_id": "123",
    "beach_name": "Playa Bávaro"
  }
}
```

### Enviar a Tópico (Broadcasting)
```json
{
  "to": "/topics/region_norte",
  "notification": {
    "title": "Alerta Climática",
    "body": "Tormenta tropical aproximándose a la región norte"
  },
  "data": {
    "type": "weather_alert",
    "region": "norte",
    "severity": "high"
  }
}
```

---

## 📊 Casos de Uso Recomendados

### 1. Al Marcar una Playa como Favorita
```dart
// En el BeachProvider o donde se gestionen los favoritos
Future<void> addToFavorites(Beach beach) async {
  // ... lógica para añadir a favoritos ...
  
  await NotificationHelper.sendFavoriteBeachNotification(beach.name);
  await NotificationHelper.subscribeToRegion(beach.region);
}
```

### 2. Al Detectar Cambios Climáticos
```dart
// En el WeatherProvider
Future<void> checkWeatherUpdates() async {
  // ... obtener datos del clima ...
  
  if (conditionsAreGood) {
    await NotificationHelper.sendGoodWeatherNotification(beachName);
  } else if (hasAlert) {
    await NotificationHelper.sendWeatherAlertNotification(beachName, alertMessage);
  }
}
```

### 3. Al Recibir un Nuevo Comentario
```dart
// En el sistema de reportes
Future<void> onCommentAdded(Comment comment, Report report) async {
  if (report.userId == currentUser.id) {
    await NotificationHelper.sendCommentNotification(
      report.beachName,
      comment.userName,
    );
  }
}
```

### 4. Al Detectar Ubicación Cercana a Playa
```dart
// En el LocationService
Future<void> checkNearbyBeaches(Position currentPosition) async {
  final nearbyBeaches = await findBeachesNear(currentPosition);
  
  for (var beach in nearbyBeaches) {
    if (beach.distance < 5.0) { // menos de 5 km
      await NotificationHelper.sendNearbyBeachNotification(
        beach.name,
        beach.distance,
      );
    }
  }
}
```

---

## ⚙️ Configuración del Usuario

Los usuarios pueden habilitar/deshabilitar las notificaciones desde:
**Configuración → Notificaciones y Permisos → Habilitar notificaciones**

Esta configuración afecta a:
- ✅ Notificaciones locales
- ✅ Notificaciones push
- ✅ Todas las funcionalidades del `NotificationHelper`

---

## 🧪 Testing

### Probar Notificación Local
```dart
// En cualquier parte de la app (para testing)
await NotificationHelper.sendWelcomeNotification();
```

### Limpiar Todas las Notificaciones
```dart
await NotificationHelper.clearAllNotifications();
```

---

## 📝 Notas Importantes

1. **Firebase debe estar configurado** correctamente para que las notificaciones push funcionen
2. **Los permisos son solicitados automáticamente** al inicializar la app
3. **Las notificaciones respetan la configuración del usuario** automáticamente
4. **En iOS**, las notificaciones requieren certificados APNs configurados en Firebase Console
5. **En Android 13+**, los permisos de notificación deben ser aceptados por el usuario

---

## 🔍 Debugging

Para ver logs de notificaciones, busca en la consola:
- `✅ NotificationService inicializado`
- `📱 Token FCM: ...`
- `📨 Mensaje recibido en primer plano`
- `✅ Notificación local mostrada`

---

## 🎯 Próximas Mejoras

- [ ] Panel de control de notificaciones en ajustes
- [ ] Notificaciones programadas (ej: recordatorios)
- [ ] Notificaciones personalizadas por preferencias
- [ ] Analytics de notificaciones
- [ ] Notificaciones agrupadas por categoría
- [ ] Acciones rápidas en notificaciones (responder, marcar como leída)

---

## 📞 Soporte

Si tienes problemas con las notificaciones, verifica:
1. ✅ Permisos de notificaciones habilitados en el dispositivo
2. ✅ Firebase correctamente configurado
3. ✅ Internet disponible para notificaciones push
4. ✅ Configuración de la app permite notificaciones

**¡Disfruta del nuevo sistema de notificaciones de Playas RD!** 🏖️📱


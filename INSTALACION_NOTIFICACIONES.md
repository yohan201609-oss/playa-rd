# 🚀 Instalación del Sistema de Notificaciones

## Pasos para activar las notificaciones en Playas RD

### 1️⃣ Instalar Dependencias

Ejecuta el siguiente comando en la terminal para instalar las nuevas dependencias:

```bash
flutter pub get
```

Esto instalará:
- `firebase_messaging: ^15.1.3` - Para notificaciones push
- `flutter_local_notifications: ^18.0.1` - Para notificaciones locales

---

### 2️⃣ Configuración de Android

#### ✅ Ya configurado automáticamente:
- Permisos en `AndroidManifest.xml`
- Canal de notificaciones
- Servicio de Firebase Cloud Messaging
- Icono de notificación

**No necesitas hacer nada adicional para Android** ✅

---

### 3️⃣ Configuración de iOS

#### Permisos (✅ Ya configurado en Info.plist)

Para que funcione en iOS necesitas:

1. **Configurar APNs (Apple Push Notification service) en Firebase Console:**
   - Ve a Firebase Console → Tu proyecto → Project Settings
   - Pestaña "Cloud Messaging"
   - En la sección iOS, sube tu certificado APNs (.p8 key)
   
2. **Firma el proyecto en Xcode:**
   ```bash
   cd ios
   pod install
   open Runner.xcworkspace
   ```
   - En Xcode, selecciona tu Team
   - Habilita "Push Notifications" en Capabilities
   - Habilita "Background Modes" → marca "Remote notifications"

---

### 4️⃣ Probar las Notificaciones

#### Opción A: Ejecutar la app

```bash
flutter run
```

Al iniciar la app:
1. Se solicitarán permisos de notificaciones automáticamente
2. Se mostrará el token FCM en la consola
3. El servicio estará listo para enviar notificaciones

#### Opción B: Probar notificación local

Agrega este código temporal en cualquier botón para probar:

```dart
import 'package:playas_rd_flutter/utils/notification_helper.dart';

// En el onPressed de un botón:
await NotificationHelper.sendLocalNotification(
  title: '🏖️ Prueba de Notificación',
  body: 'El sistema de notificaciones funciona correctamente!',
  payload: 'test',
);
```

---

### 5️⃣ Enviar Notificación Push desde Firebase Console

1. Ve a Firebase Console → Cloud Messaging → Send your first message
2. Escribe tu mensaje
3. Selecciona tu app
4. Haz clic en "Send"

O usa el token FCM específico del dispositivo (se muestra en la consola al iniciar la app):

```
📱 Token FCM: dF7x_abc123...
```

---

### 6️⃣ Integración con Eventos de la App

#### Ejemplo 1: Al marcar playa como favorita

Ya está integrado en `BeachProvider`. Cuando un usuario marca una playa como favorita, recibirá una notificación automáticamente.

```dart
// Ya implementado en lib/providers/beach_provider.dart
await NotificationHelper.sendFavoriteBeachNotification(beach.name);
```

#### Ejemplo 2: Alerta climática

Puedes agregar en el `WeatherProvider`:

```dart
import '../utils/notification_helper.dart';

// Cuando detectes cambio climático importante:
await NotificationHelper.sendWeatherAlertNotification(
  'Playa Bávaro',
  'Oleaje fuerte - precaución al nadar',
);
```

#### Ejemplo 3: Notificación de playa cercana

En el servicio de ubicación:

```dart
import '../utils/notification_helper.dart';

// Cuando el usuario esté cerca de una playa:
await NotificationHelper.sendNearbyBeachNotification(
  beach.name,
  distance, // en kilómetros
);
```

---

### 7️⃣ Verificar que Todo Funciona

Al ejecutar la app, deberías ver en la consola:

```
✅ Preferencias inicializadas
✅ Variables de entorno cargadas
✅ Firebase inicializado correctamente
✅ Servicio de notificaciones inicializado
✅ Permisos de notificación concedidos
📱 Token FCM: [tu-token-aquí]
✅ Firebase Messaging configurado
✅ Notificaciones locales configuradas
✅ NotificationService inicializado correctamente
```

---

### 8️⃣ Configuración del Usuario

Los usuarios pueden habilitar/deshabilitar notificaciones desde:

**Perfil → Configuración → Notificaciones y Permisos → Habilitar notificaciones**

Esta configuración se guarda y se respeta en todas las notificaciones enviadas por la app.

---

## 🔧 Troubleshooting

### Problema: No se muestran las notificaciones

**Solución:**
1. Verifica que los permisos estén concedidos en el dispositivo
2. Revisa que Firebase esté correctamente inicializado
3. Comprueba que la configuración de notificaciones esté habilitada en la app

### Problema: Error al compilar en iOS

**Solución:**
```bash
cd ios
pod deintegrate
pod install
flutter clean
flutter pub get
flutter run
```

### Problema: No se reciben notificaciones push

**Solución:**
1. Verifica la configuración de Firebase Cloud Messaging
2. Confirma que el token FCM esté siendo generado
3. En iOS, verifica la configuración de APNs en Firebase Console
4. Asegúrate de que la app tenga conexión a internet

---

## 📚 Documentación Adicional

- [Documentación completa de notificaciones](./NOTIFICACIONES.md)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

## ✅ Checklist de Verificación

- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] App compilando sin errores
- [ ] Permisos de notificaciones solicitados al abrir la app
- [ ] Token FCM generado y visible en consola
- [ ] Notificaciones locales funcionando
- [ ] Configuración de notificaciones visible en ajustes
- [ ] Notificación enviada al marcar favorito

---

## 🎉 ¡Listo!

Tu app ahora tiene un sistema completo de notificaciones. Los usuarios recibirán notificaciones sobre:
- ✅ Playas favoritas
- ✅ Cambios climáticos
- ✅ Nuevos reportes
- ✅ Comentarios en sus reportes
- ✅ Playas cercanas
- ✅ Alertas de seguridad
- ✅ Eventos especiales

**¡Disfruta de tu nueva funcionalidad! 🏖️📱**


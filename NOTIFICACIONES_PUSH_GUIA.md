# 📱 Guía de Notificaciones Push - Playas RD

## ✅ Estado de Implementación

¡Las notificaciones push ya están completamente implementadas en tu app!

### Componentes Integrados:

1. **✅ Firebase Cloud Functions** - Desplegadas y activas
2. **✅ NotificationService** - Configurado y listo
3. **✅ AuthProvider** - Guarda FCM token automáticamente
4. **✅ FirebaseService** - Sincroniza tokens con Firestore
5. **✅ Main.dart** - Inicializa notificaciones al arrancar

## 🎯 Cómo Funcionan

### Flujo Automático:

```
1. Usuario abre la app
   ↓
2. NotificationService se inicializa
   ↓
3. Se solicitan permisos de notificación
   ↓
4. Se obtiene el FCM Token del dispositivo
   ↓
5. Usuario inicia sesión
   ↓
6. AuthProvider guarda el token en Firestore
   ↓
7. Cloud Functions detectan cambios
   ↓
8. Se envían notificaciones automáticamente
```

## 🔔 Tipos de Notificaciones Implementadas

### 1. Cambio de Condición de Playa
**Trigger:** Cuando actualizas `condition` en Firestore
```dart
// En tu app:
await FirebaseFirestore.instance
    .collection('beaches')
    .doc(beachId)
    .update({'condition': 'Excelente'});

// Resultado:
// → Los usuarios con esta playa en favoritos reciben:
// "🏖️ Actualización de Playa Rincón"
// "La condición cambió de Moderado a Excelente"
```

### 2. Nuevo Reporte de Playa
**Trigger:** Cuando se crea un documento en `reports/`
```dart
// En tu ReportScreen:
await FirebaseFirestore.instance
    .collection('reports')
    .add({
      'beachId': beachId,
      'userId': userId,
      'condition': 'Excelente',
      'comment': 'Playa hermosa hoy',
      'createdAt': FieldValue.serverTimestamp(),
    });

// Resultado:
// → Usuarios interesados reciben:
// "📢 Nuevo reporte en Playa Rincón"
// "Playa hermosa hoy"
```

### 3. Actualización de Clima (Automático)
**Trigger:** Cada 6 horas automáticamente
- Se ejecuta en segundo plano
- Actualiza `weather` en cada playa
- No envía notificación, pero los datos están listos para mostrar

### 4. Limpieza de Reportes (Automático)
**Trigger:** Diariamente a las 2:00 AM
- Elimina reportes antiguos
- Mantiene la base de datos limpia
- Sin notificaciones al usuario

## 🧪 Cómo Probar las Notificaciones

### Opción 1: Probar desde Firebase Console (Más Fácil)

#### A. Probar Cambio de Condición:

1. Abre Firebase Console:
   ```
   https://console.firebase.google.com/project/playas-rd-2b475/firestore
   ```

2. Ve a la colección `beaches`

3. Selecciona cualquier playa

4. Edita el campo `condition` y cámbialo a un valor diferente

5. Guarda los cambios

6. **Resultado:** Los usuarios con esa playa en favoritos recibirán una notificación

#### B. Probar Nuevo Reporte:

1. En Firebase Console, ve a la colección `reports`

2. Haz clic en "Agregar documento"

3. Agrega estos campos:
   ```json
   {
     "beachId": "ID_DE_UNA_PLAYA",
     "userId": "TU_USER_ID",
     "condition": "Excelente",
     "comment": "Prueba de notificación",
     "createdAt": "timestamp (auto)"
   }
   ```

4. **Resultado:** Usuarios con esa playa en favoritos recibirán notificación

### Opción 2: Probar desde la App

#### A. Preparación:

1. **Instala la app en un dispositivo físico** (recomendado)
   - Las notificaciones funcionan mejor en dispositivos reales
   - Los emuladores pueden tener problemas con FCM

2. **Verifica permisos:**
   - La app debe solicitar permisos de notificación al abrir
   - Acepta los permisos

3. **Inicia sesión:**
   - El token FCM se guardará automáticamente

4. **Verifica en logs:**
   ```
   ✅ NotificationService inicializado correctamente
   📱 Token FCM: [tu_token_aqui]
   📱 FCM Token guardado para usuario [email]
   ```

#### B. Prueba Manual:

1. **Agrega una playa a favoritos** en la app

2. **Desde otra cuenta o Firebase Console:**
   - Cambia la condición de esa playa
   
3. **Deberías recibir la notificación** inmediatamente

### Opción 3: Probar con Firebase Console Cloud Messaging

1. Ve a Firebase Console → Cloud Messaging:
   ```
   https://console.firebase.google.com/project/playas-rd-2b475/notification
   ```

2. Haz clic en "Send your first message"

3. Completa:
   - **Título:** "Prueba de Notificación"
   - **Texto:** "Esta es una prueba"
   - **Target:** Selecciona tu app

4. Envía la notificación

## 📊 Monitoreo en Tiempo Real

### Ver Logs de Cloud Functions:

```powershell
# Ver todos los logs
firebase functions:log

# Ver logs de una función específica
firebase functions:log --only notifyBeachConditionChange

# Ver logs en tiempo real
firebase functions:log --follow
```

### Ver en Firebase Console:

1. **Functions:**
   ```
   https://console.firebase.google.com/project/playas-rd-2b475/functions
   ```

2. **Firestore (verificar tokens):**
   ```
   https://console.firebase.google.com/project/playas-rd-2b475/firestore
   ```
   - Ve a la colección `users`
   - Verifica que cada usuario tenga un `fcmToken`

## 🔧 Verificación de la Implementación

### Checklist de Verificación:

- [✅] `firebase_messaging` instalado en pubspec.yaml
- [✅] `flutter_local_notifications` instalado
- [✅] NotificationService creado y configurado
- [✅] AuthProvider guarda FCM token en login
- [✅] FirebaseService tiene método saveFCMToken
- [✅] Main.dart inicializa NotificationService
- [✅] Cloud Functions desplegadas (5 funciones activas)
- [✅] Permisos de notificación en AndroidManifest.xml / Info.plist

### Verificar en el Código:

```dart
// En lib/main.dart - líneas 59-66
try {
  await NotificationService().initialize();
  print('✅ Servicio de notificaciones inicializado');
} catch (e) {
  print('⚠️ Error inicializando notificaciones: $e');
  print('Las notificaciones no estarán disponibles');
}

// En lib/providers/auth_provider.dart - líneas 51-62
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
```

## 🐛 Troubleshooting

### Problema: No recibo notificaciones

**Solución 1: Verificar permisos**
```dart
// Agregar código temporal para verificar:
final notifService = NotificationService();
final enabled = await notifService.areNotificationsEnabled();
print('Notificaciones habilitadas: $enabled');
```

**Solución 2: Verificar token en Firestore**
1. Abre Firebase Console → Firestore
2. Ve a `users` → [tu usuario]
3. Verifica que `fcmToken` tenga un valor
4. Si es `null`, cierra sesión y vuelve a entrar

**Solución 3: Verificar Cloud Functions**
```powershell
firebase functions:log --only notifyBeachConditionChange
```
- Debe mostrar logs cuando cambies una condición

### Problema: Token no se guarda

**Causa común:** NotificationService no terminó de inicializar

**Solución:**
```dart
// Agregar delay antes de guardar token
await Future.delayed(Duration(seconds: 2));
await _saveFCMToken();
```

### Problema: Notificaciones solo funcionan en primer plano

**Causa:** Falta configuración de notificaciones en segundo plano

**Solución para Android:**
Verifica que en `AndroidManifest.xml` tengas:
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="playas_rd_channel" />
```

**Solución para iOS:**
Verifica que en `AppDelegate.swift` tengas la configuración de notificaciones.

### Problema: "Permission denied" en Cloud Functions

**Causa:** Permisos de Eventarc no propagados completamente

**Solución:** Ya se resolvió automáticamente en el último deploy, pero si persiste:
```powershell
# Esperar 5 minutos y reintentar
firebase deploy --only functions --force
```

## 📱 Configuración por Plataforma

### Android (Ya configurado ✅)

El `AndroidManifest.xml` debe tener:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### iOS (Requiere configuración adicional)

Si vas a desplegar en iOS, necesitas:

1. **Habilitar Push Notifications en Xcode:**
   - Abre `ios/Runner.xcworkspace` en Xcode
   - Ve a Signing & Capabilities
   - Agrega "Push Notifications"
   - Agrega "Background Modes" → Remote notifications

2. **Configurar APN:**
   - Necesitas un certificado APN de Apple Developer
   - Súbelo a Firebase Console → Project Settings → Cloud Messaging

## 🎨 Personalización de Notificaciones

### Cambiar Icono de Notificación (Android):

1. Crea un icono en `android/app/src/main/res/drawable/notification_icon.png`
2. En NotificationService, cambia:
```dart
icon: '@drawable/notification_icon', // En lugar de @mipmap/ic_launcher
```

### Cambiar Sonido:

1. Agrega un archivo de sonido a `android/app/src/main/res/raw/notification_sound.mp3`
2. En el canal de notificación:
```dart
sound: RawResourceAndroidNotificationSound('notification_sound'),
```

### Agrupar Notificaciones:

```dart
// En AndroidNotificationDetails
groupKey: 'playas_rd_group',
setAsGroupSummary: true,
```

## 📚 Recursos Adicionales

- **Firebase Cloud Messaging:** https://firebase.google.com/docs/cloud-messaging
- **Flutter Local Notifications:** https://pub.dev/packages/flutter_local_notifications
- **Firebase Functions:** https://firebase.google.com/docs/functions

## ✨ Próximas Mejoras Sugeridas

1. **Notificaciones programadas:**
   - Recordatorios para revisar playas favoritas
   - Alertas de clima ideal para visitar

2. **Notificaciones con imágenes:**
   - Incluir imagen de la playa en la notificación
   - Usar BigPictureStyle en Android

3. **Actions en notificaciones:**
   - Botones "Ver playa" o "Descartar"
   - Respuestas rápidas

4. **Personalización por usuario:**
   - Configuración de tipos de notificaciones
   - Horarios preferidos para notificar

## 🎉 ¡Listo!

Tus notificaciones push están completamente configuradas y funcionando. 

**Para empezar a probar:**
1. Abre la app en un dispositivo físico
2. Inicia sesión
3. Agrega una playa a favoritos
4. Cambia la condición de esa playa en Firebase Console
5. ¡Deberías recibir la notificación!

---

Desarrollado con ❤️ para Playas RD 🇩🇴


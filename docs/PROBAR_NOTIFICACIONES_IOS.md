# Guía: Probar Notificaciones Push en Dispositivo iOS Físico

## ✅ Requisitos Completados
- ✅ Clave de autenticación de APNS de desarrollo configurada en Firebase
- ✅ Firebase Cloud Messaging configurado en la app
- ✅ Permisos de notificaciones configurados en `Info.plist`
- ✅ Servicio de notificaciones implementado

## Pasos para Probar

### 1. Compilar y Ejecutar en Dispositivo Físico

```bash
# Conecta tu iPhone/iPad al Mac
# Asegúrate de que el dispositivo esté registrado en Apple Developer Portal

# Compilar y ejecutar en modo debug (desarrollo)
flutter run --release
# O desde Xcode, selecciona tu dispositivo y ejecuta
```

**Importante:**
- El dispositivo debe estar conectado por USB o en la misma red WiFi
- Debes tener un perfil de desarrollo válido configurado
- El Bundle ID debe coincidir: `com.playasrd.playasrd`

### 2. Obtener el Token FCM del Dispositivo

Una vez que la app se ejecute en tu dispositivo:

1. **Abre la app** en tu iPhone/iPad
2. **Acepta los permisos** de notificaciones cuando se soliciten
3. **Revisa la consola** de Flutter/Xcode para ver el token FCM

El token aparecerá en la consola con este formato:
```
📱 Token FCM: [un token largo aquí]
```

**Alternativa:** Puedes agregar un botón temporal en la app para mostrar el token:

```dart
// En cualquier pantalla, agrega esto temporalmente:
ElevatedButton(
  onPressed: () {
    final token = NotificationService().fcmToken;
    print('Token FCM: $token');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token: ${token ?? "No disponible"}')),
    );
  },
  child: Text('Mostrar Token FCM'),
)
```

### 3. Enviar Notificación de Prueba desde Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto: **playas-rd-2b475**
3. En el menú lateral, ve a **"Cloud Messaging"** (o "Mensajería en la nube")
4. Haz clic en **"Enviar tu primer mensaje"** o **"Nuevo mensaje"**
5. Completa el formulario:
   - **Título de notificación**: Ejemplo: "Prueba de Notificación"
   - **Texto de notificación**: Ejemplo: "¡Hola desde Firebase!"
6. Haz clic en **"Siguiente"**
7. En **"Destinatarios"**, selecciona **"Token FCM"**
8. Pega el **Token FCM** que obtuviste del dispositivo
9. Haz clic en **"Siguiente"** y luego en **"Revisar"**
10. Haz clic en **"Publicar"**

### 4. Verificar la Recepción

**Si la app está en primer plano:**
- Deberías ver la notificación en la consola:
  ```
  📨 Mensaje recibido en primer plano
  === MENSAJE RECIBIDO ===
  Título: Prueba de Notificación
  Cuerpo: ¡Hola desde Firebase!
  ```
- También deberías ver una notificación local en el dispositivo

**Si la app está en segundo plano:**
- Deberías recibir la notificación en la barra de notificaciones del iOS
- Al tocar la notificación, la app se abrirá

**Si la app está cerrada:**
- Deberías recibir la notificación en la barra de notificaciones
- Al tocar la notificación, la app se abrirá

### 5. Verificar Logs en Consola

Revisa los logs de Flutter/Xcode para confirmar:
- ✅ `✅ Permisos de notificación concedidos`
- ✅ `📱 Token FCM: [token]`
- ✅ `✅ Firebase Messaging configurado`
- ✅ `📨 Mensaje recibido...` (cuando llegue la notificación)

## Solución de Problemas

### No se recibe el token FCM
- Verifica que Firebase esté inicializado correctamente
- Asegúrate de que el dispositivo tenga conexión a internet
- Revisa que los permisos de notificaciones estén concedidos

### No se reciben notificaciones
1. **Verifica la clave APNS:**
   - Ve a Firebase Console → Configuración → Apps de Apple
   - Confirma que la clave de desarrollo esté configurada

2. **Verifica el token:**
   - Asegúrate de usar el token correcto del dispositivo
   - Los tokens pueden cambiar, obtén uno nuevo si es necesario

3. **Verifica los permisos:**
   - Ve a Configuración → Notificaciones en tu iPhone
   - Confirma que "Playas RD" tenga permisos habilitados

4. **Verifica la conexión:**
   - El dispositivo debe tener conexión a internet
   - Firebase debe poder conectarse a los servidores de Apple

### Error: "Invalid APNs credentials"
- Verifica que la clave `.p8` esté correctamente subida en Firebase
- Confirma que el Key ID y Team ID sean correctos
- Asegúrate de estar usando la clave de **desarrollo** (no producción)

### La app no solicita permisos
- Verifica que `Info.plist` tenga configurado `UIBackgroundModes` con `remote-notification`
- Asegúrate de que el código de solicitud de permisos se ejecute (revisa `NotificationService`)

## Pruebas Adicionales

### Probar desde Terminal con cURL

Una vez que tengas el token FCM, puedes probar enviando una notificación directamente:

```bash
# Reemplaza YOUR_FCM_TOKEN con el token real
curl -X POST https://fcm.googleapis.com/v1/projects/playas-rd-2b475/messages:send \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "YOUR_FCM_TOKEN",
      "notification": {
        "title": "Prueba desde Terminal",
        "body": "Esta es una notificación de prueba"
      }
    }
  }'
```

**Nota:** Esto requiere tener `gcloud` CLI configurado con las credenciales correctas.

## Próximos Pasos

Una vez que las notificaciones funcionen en desarrollo:
- ✅ Puedes configurar la clave de producción cuando estés listo para publicar
- ✅ Implementar lógica de negocio para enviar notificaciones automáticas
- ✅ Guardar tokens FCM en Firestore asociados a usuarios
- ✅ Implementar tópicos para notificaciones masivas

## Referencias
- [Firebase Cloud Messaging - iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Apple Push Notification Service](https://developer.apple.com/documentation/usernotifications)


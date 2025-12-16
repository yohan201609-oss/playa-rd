# Guía: Probar Notificaciones Push en Dispositivo Físico iOS desde Firebase Console

Esta guía te ayudará a probar las notificaciones push en un dispositivo físico iOS usando Firebase Console.

## 📋 Requisitos Previos

1. ✅ Dispositivo iOS físico conectado y con la app instalada
2. ✅ App compilada en modo Debug o Release (no funciona en simulador)
3. ✅ Permisos de notificaciones concedidos en el dispositivo
4. ✅ Clave APNS configurada en Firebase (desarrollo o producción según corresponda)

## 🔍 Paso 1: Verificar Configuración de APNS en Firebase

Según la imagen que compartiste, veo que:
- ✅ Tienes una **clave APNS de desarrollo** configurada (ID: MIGTAGEAMB)
- ❌ **NO tienes una clave APNS de producción** configurada

### Para Dispositivos Físicos:

- **Si estás usando un build de desarrollo**: La clave de desarrollo debería funcionar
- **Si estás usando un build de producción/TestFlight**: Necesitas subir una clave APNS de producción

### Cómo Subir Clave APNS de Producción:

1. Ve a [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
2. Crea una nueva clave de autenticación APNS (si no tienes una)
3. Descarga el archivo `.p8`
4. En Firebase Console → Configuración del proyecto → Cloud Messaging
5. En la sección "Clave de autenticación de APNS de producción", haz clic en **"Subir"**
6. Sube el archivo `.p8` y proporciona el **Key ID** y **Team ID**

## 📱 Paso 2: Obtener el Token FCM del Dispositivo

El token FCM es único para cada dispositivo y es necesario para enviar notificaciones específicas.

### Opción A: Desde los Logs de la App (Recomendado)

1. Abre la app en tu dispositivo físico iOS
2. Conecta el dispositivo a tu Mac
3. Abre **Xcode** → **Window** → **Devices and Simulators**
4. Selecciona tu dispositivo
5. Abre la consola de logs
6. Busca en los logs el mensaje: `📱 Token FCM: [tu-token-aqui]`

El token se imprime automáticamente cuando la app se inicia (ver `lib/services/notification_service.dart` línea 154).

### Opción B: Desde la Pantalla de Pruebas (Si está disponible)

Si tienes acceso a la pantalla de pruebas de notificaciones en la app, el token FCM se mostrará allí.

### Opción C: Desde Firestore (Si el usuario está autenticado)

1. Ve a Firebase Console → Firestore Database
2. Busca la colección `users`
3. Encuentra el documento del usuario autenticado
4. El campo `fcmToken` contiene el token FCM

## 🚀 Paso 3: Enviar Notificación desde Firebase Console

### Método 1: Enviar a un Token Específico (Recomendado para Pruebas)

1. Ve a Firebase Console → **Cloud Messaging**
2. Haz clic en **"Enviar tu primer mensaje"** o **"Nueva campaña"**
3. Selecciona **"Notificación"**
4. Completa los campos:
   - **Título**: Ej: "Prueba de Notificación"
   - **Texto**: Ej: "Esta es una notificación de prueba desde Firebase Console"
5. Haz clic en **"Siguiente"**
6. En **"Audiencia"**, selecciona **"Token único de FCM"**
7. Pega el token FCM que obtuviste en el Paso 2
8. Haz clic en **"Siguiente"**
9. Revisa la configuración y haz clic en **"Revisar"**
10. Haz clic en **"Publicar"**

### Método 2: Enviar a la App Completa

1. Ve a Firebase Console → **Cloud Messaging**
2. Haz clic en **"Nueva campaña"** → **"Notificación"**
3. Completa título y texto
4. En **"Audiencia"**, selecciona **"App iOS"**
5. Selecciona tu app iOS: **"Playas RD iOS"**
6. Continúa con los pasos siguientes

### Método 3: Usar la API de Prueba (Más Avanzado)

Puedes usar la herramienta de prueba de Firebase directamente:

1. Ve a Firebase Console → **Cloud Messaging**
2. En la parte superior, busca la sección **"Enviar mensaje de prueba"**
3. Pega el token FCM
4. Completa título y texto
5. Haz clic en **"Probar"**

## ✅ Paso 4: Verificar que la Notificación Llegue

### Escenarios de Prueba:

#### 1. App en Primer Plano (Abierta y Visible)
- La notificación debería aparecer como una notificación local
- Revisa los logs de la app para ver: `📨 Mensaje recibido en primer plano`

#### 2. App en Segundo Plano (Minimizada)
- La notificación debería aparecer en el centro de notificaciones de iOS
- Al tocar la notificación, la app debería abrirse
- Revisa los logs para ver: `📨 Notificación tocada (app en segundo plano)`

#### 3. App Cerrada (Terminada)
- La notificación debería aparecer en el centro de notificaciones
- Al tocar la notificación, la app debería abrirse
- Revisa los logs para ver: `📨 App abierta desde notificación`

## 🔧 Solución de Problemas

### Problema 0: Error de Firebase App Check (MUY COMÚN)

**Síntoma**: Ves este error en los logs de Xcode:
```
AppCheck failed: App not registered: 1:360714035813:ios:e7b023b9692d3d09629c8c
```

**Solución**: 
1. Ve a Firebase Console → **App Check**
2. Registra tu app iOS si no está registrada
3. Configura **DeviceCheck** como proveedor
4. Recompila la app

**Guía completa**: Ver `SOLUCION_ERROR_APP_CHECK.md`

---

### Problema 1: No Recibo Notificaciones

**Posibles Causas y Soluciones:**

1. **Permisos no concedidos**
   - Ve a Configuración de iOS → Playas RD → Notificaciones
   - Asegúrate de que las notificaciones estén habilitadas

2. **Token FCM incorrecto o expirado**
   - Obtén un nuevo token FCM del dispositivo
   - Los tokens pueden cambiar si reinstalas la app o restauras el dispositivo

3. **Clave APNS incorrecta**
   - Verifica que la clave APNS en Firebase corresponda al tipo de build (desarrollo/producción)
   - Para builds de producción, necesitas la clave de producción

4. **App no está registrada correctamente**
   - Verifica que el `Bundle ID` en Firebase coincida con el de tu app
   - Debe ser: `com.playasrd.playasrd`

5. **Problemas de red**
   - Asegúrate de que el dispositivo tenga conexión a internet
   - Verifica que no haya firewall bloqueando las conexiones a Firebase

### Problema 2: Veo el Token pero las Notificaciones No Llegan

1. **Verifica los logs de Firebase Console**
   - Ve a Cloud Messaging → Ver historial de envíos
   - Revisa si hay errores en el envío

2. **Verifica los logs del dispositivo**
   - Revisa la consola de Xcode para ver si hay errores relacionados con FCM

3. **Prueba con un token de otro dispositivo**
   - Si funciona en otro dispositivo, el problema puede ser específico del dispositivo

### Problema 3: "API de Cloud Messaging (heredada) Inhabilitado"

Esta advertencia indica que estás usando una API antigua. Para solucionarlo:

1. **No es crítico para pruebas básicas**: La API heredada aún funciona hasta junio 2024
2. **Para migrar a la nueva API**:
   - Usa la API HTTP v1 de Firebase Cloud Messaging
   - Esto requiere cambios en el código si estás enviando notificaciones desde tu backend
   - Para pruebas desde Firebase Console, no es necesario migrar

## 📝 Verificación de Configuración

### Checklist Pre-Prueba:

- [ ] Clave APNS configurada en Firebase (desarrollo o producción según corresponda)
- [ ] App instalada en dispositivo físico iOS
- [ ] Permisos de notificaciones concedidos en el dispositivo
- [ ] Token FCM obtenido del dispositivo
- [ ] App abierta al menos una vez para inicializar FCM
- [ ] Conexión a internet activa en el dispositivo

### Verificar en Firebase Console:

1. **Configuración del Proyecto** → **Cloud Messaging**
   - ✅ Clave APNS de desarrollo configurada
   - ✅ (Opcional) Clave APNS de producción configurada
   - ✅ App iOS registrada: "Playas RD iOS"

2. **Cloud Messaging** → **Historial**
   - Revisa si hay intentos de envío anteriores
   - Verifica si hay errores reportados

## 🎯 Ejemplo de Prueba Completa

1. **Preparación:**
   ```
   - Abre la app en tu iPhone
   - Concede permisos de notificaciones cuando se soliciten
   - Espera a que se inicialice el servicio de notificaciones
   ```

2. **Obtener Token:**
   ```
   - Abre Xcode → Devices and Simulators
   - Selecciona tu dispositivo
   - Busca en los logs: "📱 Token FCM: [token]"
   - Copia el token completo
   ```

3. **Enviar Notificación:**
   ```
   - Ve a Firebase Console → Cloud Messaging
   - Nueva campaña → Notificación
   - Título: "Prueba desde Firebase"
   - Texto: "Esta es una notificación de prueba"
   - Audiencia: Token único de FCM
   - Pega el token
   - Publicar
   ```

4. **Verificar:**
   ```
   - Si la app está abierta: deberías ver la notificación en la app
   - Si la app está en segundo plano: deberías ver la notificación en el centro de notificaciones
   - Si la app está cerrada: deberías ver la notificación y al tocarla se abre la app
   ```

## 📚 Recursos Adicionales

- [Documentación oficial de Firebase Cloud Messaging para iOS](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Guía de configuración de APNS](https://firebase.google.com/docs/cloud-messaging/ios/cert)
- [Solución de problemas comunes de FCM](https://firebase.google.com/docs/cloud-messaging/ios/troubleshooting)

## ⚠️ Notas Importantes

1. **Simulador iOS**: Las notificaciones push NO funcionan en el simulador de iOS. Debes usar un dispositivo físico.

2. **Tokens FCM**: Los tokens pueden cambiar. Si reinstalas la app o restauras el dispositivo, necesitarás obtener un nuevo token.

3. **Claves APNS**: 
   - Desarrollo: Para builds de desarrollo y TestFlight (con builds de desarrollo)
   - Producción: Para builds de producción y TestFlight (con builds de producción)

4. **Límites**: Firebase Console tiene límites en la cantidad de notificaciones que puedes enviar. Para pruebas masivas, considera usar la API directamente.

---

**¿Necesitas ayuda?** Revisa los logs de la app y de Firebase Console para identificar el problema específico.

# Guía: Cómo Verificar la Configuración APNS en Firebase

Esta guía te explica paso a paso cómo verificar que la configuración de APNS (Apple Push Notification Service) esté correctamente configurada en Firebase Console.

---

## 📍 Paso 1: Acceder a Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Inicia sesión con tu cuenta de Google
3. Selecciona tu proyecto: **playas-rd-2b475**

---

## 🔍 Paso 2: Verificar Configuración de APNS

### Opción A: Desde Configuración del Proyecto

1. En Firebase Console, haz clic en el **ícono de engranaje (⚙️)** en la parte superior izquierda
2. Selecciona **"Configuración del proyecto"** (Project Settings)
3. Ve a la pestaña **"Cloud Messaging"** (Cloud Messaging)
4. Desplázate hacia abajo hasta la sección **"Configuración de app de Apple"** (Apple app configuration)

### Opción B: Desde Cloud Messaging

1. En el menú lateral izquierdo, haz clic en **"Cloud Messaging"** (o "Mensajería en la nube")
2. En la parte superior de la página, haz clic en la pestaña **"Cloud Messaging API (legacy)"** o busca la sección de configuración
3. Alternativamente, ve a **"Configuración"** dentro de Cloud Messaging

---

## ✅ Paso 3: Verificar Claves APNS Configuradas

En la sección **"Configuración de app de Apple"**, deberías ver:

### 3.1 Clave de Autenticación APNS de Desarrollo (Development)

**Estado esperado:**
- ✅ **Clave configurada**: Debería mostrar:
  - **ID de clave** (Key ID): Ej: `MIGTAGEAMB` o similar
  - **Team ID**: Tu ID de equipo de Apple Developer
  - **Fecha de creación**: Fecha cuando se subió la clave
  - **Estado**: "Configurado" o "Active"

**Si NO está configurada:**
- ❌ Verás un botón **"Subir"** (Upload) o **"Cargar clave"** (Upload key)
- Esto significa que falta la clave de desarrollo

### 3.2 Clave de Autenticación APNS de Producción (Production)

**Estado esperado:**
- ✅ **Clave configurada**: Similar a la de desarrollo
- ❌ **Opcional para desarrollo**: Si solo estás en desarrollo, puede estar vacía

**Importante:**
- Para builds de **desarrollo** y **TestFlight (desarrollo)**: Solo necesitas la clave de desarrollo
- Para builds de **producción** y **TestFlight (producción)**: Necesitas la clave de producción

---

## 🔧 Paso 4: Verificar Qué Tipo de Clave Necesitas

### Para Verificar el Tipo de Build que Estás Usando:

1. Abre tu proyecto en **Xcode**
2. Selecciona el target **Runner**
3. Ve a **Signing & Capabilities**
4. Verifica el **Bundle Identifier**: `com.playasrd.playasrd`
5. Ve a **Product** → **Scheme** → **Edit Scheme**
6. En **Run** → **Info** → **Build Configuration**:
   - **Debug** = Necesitas clave de desarrollo
   - **Release** = Necesitas clave de producción

### También puedes verificar en `Runner.entitlements`:

Abre `ios/Runner/Runner.entitlements` (o crea uno si no existe) y busca:

```xml
<key>aps-environment</key>
<string>development</string>  <!-- Necesitas clave de desarrollo -->
```

O:

```xml
<key>aps-environment</key>
<string>production</string>  <!-- Necesitas clave de producción -->
```

---

## 📋 Paso 5: Checklist de Verificación Completa

Usa esta lista para verificar todo:

### En Firebase Console:

- [ ] **Proyecto correcto seleccionado**: playas-rd-2b475
- [ ] **App iOS registrada**: Debe aparecer "Playas RD iOS" con Bundle ID `com.playasrd.playasrd`
- [ ] **Clave APNS de desarrollo configurada**: Tiene Key ID y Team ID
- [ ] **Clave APNS de producción configurada** (si usas builds de producción): Tiene Key ID y Team ID
- [ ] **GoogleService-Info.plist descargado**: El archivo está en `ios/Runner/GoogleService-Info.plist`

### En Xcode:

- [ ] **Push Notifications capability agregada**: En Signing & Capabilities
- [ ] **Background Modes habilitado**: Con "Remote notifications" marcado
- [ ] **Runner.entitlements existe**: Y contiene `aps-environment`
- [ ] **aps-environment configurado**: `development` o `production` según corresponda
- [ ] **GoogleService-Info.plist en el proyecto**: Y agregado al target "Runner"

### En el Código:

- [ ] **Permisos solicitados**: El código solicita permisos de notificaciones
- [ ] **Token APNS obtenido**: Los logs muestran `✅ Token APNS obtenido: [token]`
- [ ] **Token FCM obtenido**: Los logs muestran `📱 Token FCM: [token]`

---

## ❌ Problemas Comunes y Soluciones

### Problema 1: "No hay clave APNS configurada"

**Síntomas:**
- En Firebase Console no ves ninguna clave configurada
- En los logs de la app ves: `⚠️ Token APNS no disponible`
- No puedes obtener el token FCM

**Solución:**
1. Ve a [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
2. Crea una nueva **APNs Auth Key**:
   - Haz clic en **"+"** o **"Generate new key"**
   - Nombre: Ej: "APNs Development Key"
   - Marca **"Apple Push Notifications service (APNs)"**
   - Haz clic en **"Continue"** → **"Register"**
3. Descarga el archivo `.p8` (solo se puede descargar una vez)
4. Anota el **Key ID** y tu **Team ID**
5. En Firebase Console → Cloud Messaging → Apple app configuration:
   - Haz clic en **"Subir"** (Upload)
   - Sube el archivo `.p8`
   - Ingresa el **Key ID**
   - Ingresa el **Team ID**
   - Haz clic en **"Subir"** o **"Upload"**

---

### Problema 2: "Clave APNS incorrecta (desarrollo vs producción)"

**Síntomas:**
- Tienes una clave configurada pero las notificaciones no llegan
- El tipo de clave no coincide con tu build (desarrollo vs producción)

**Solución:**
- Si usas build de **desarrollo**: Configura la clave de **desarrollo** en Firebase
- Si usas build de **producción**: Configura la clave de **producción** en Firebase
- Puedes tener ambas configuradas a la vez (recomendado)

---

### Problema 3: "Clave APNS expirada o inválida"

**Síntomas:**
- La clave está configurada en Firebase pero no funciona
- Recibes errores al enviar notificaciones desde Firebase Console

**Solución:**
1. Ve a [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
2. Verifica el estado de tus claves APNs
3. Si alguna está revocada o expirada, crea una nueva
4. Sube la nueva clave en Firebase Console (reemplaza la anterior si es necesario)

---

### Problema 4: "Bundle ID no coincide"

**Síntomas:**
- La clave APNS está configurada pero las notificaciones no funcionan
- El Bundle ID en Firebase no coincide con el de tu app

**Solución:**
1. Verifica el Bundle ID en Firebase Console:
   - Debe ser: `com.playasrd.playasrd`
2. Verifica el Bundle ID en Xcode:
   - Signing & Capabilities → Bundle Identifier
   - Debe coincidir exactamente: `com.playasrd.playasrd`
3. Si no coincide, actualiza uno de ellos para que coincidan

---

## 🧪 Paso 6: Probar la Configuración

### Test 1: Verificar Token APNS en la App

1. Ejecuta la app en un dispositivo físico iOS:
   ```bash
   flutter run
   ```

2. Conecta el dispositivo a tu Mac y abre **Xcode** → **Window** → **Devices and Simulators**

3. Selecciona tu dispositivo y abre la consola de logs

4. Busca en los logs:
   - ✅ `✅ Token APNS obtenido: [token]` = Configuración correcta
   - ❌ `⚠️ Token APNS no disponible` = Hay un problema

### Test 2: Verificar Token FCM

1. En los logs de la app, busca:
   - ✅ `📱 Token FCM: [token]` = Todo está funcionando
   - ❌ `⚠️ Token FCM no disponible` = Hay un problema con APNS

2. Si obtienes el token FCM, cópialo

### Test 3: Enviar Notificación de Prueba

1. Ve a Firebase Console → **Cloud Messaging**
2. Haz clic en **"Enviar mensaje de prueba"** (Send test message)
3. Pega el **Token FCM** que obtuviste
4. Escribe un título y mensaje
5. Haz clic en **"Probar"** (Test)

**Resultado esperado:**
- ✅ La notificación llega al dispositivo = Configuración correcta
- ❌ No llega la notificación = Hay un problema (revisa los pasos anteriores)

---

## 📊 Paso 7: Verificar en los Logs de Firebase

1. En Firebase Console → **Cloud Messaging** → **Historial** (History)
2. Verifica si hay intentos de envío anteriores
3. Si hay errores, Firebase te indicará el problema específico:
   - **"Invalid APNs credentials"** = Clave APNS incorrecta o expirada
   - **"Invalid registration token"** = Token FCM incorrecto o expirado
   - **"MismatchSenderId"** = Bundle ID no coincide

---

## 🔄 Paso 8: Actualizar Configuración si es Necesario

### Si Necesitas Subir una Nueva Clave APNS:

1. **Crear la clave en Apple Developer Portal** (ver Problema 1)
2. **Subir en Firebase Console**:
   - Ve a Firebase Console → Project Settings → Cloud Messaging
   - En "Apple app configuration", haz clic en **"Subir"** (Upload)
   - Selecciona el archivo `.p8`
   - Ingresa **Key ID** y **Team ID**
   - Haz clic en **"Subir"**
3. **Esperar unos minutos**: Firebase puede tardar 1-2 minutos en procesar la nueva clave
4. **Recompilar la app**:
   ```bash
   flutter clean
   cd ios
   pod install
   cd ..
   flutter run
   ```

---

## 📝 Resumen de Ubicaciones Importantes

### En Firebase Console:
- **Configuración APNS**: ⚙️ → Project Settings → Cloud Messaging → Apple app configuration
- **Probar notificaciones**: Cloud Messaging → Send test message
- **Historial de envíos**: Cloud Messaging → History

### En Apple Developer Portal:
- **Claves APNS**: https://developer.apple.com/account/resources/authkeys/list
- **Team ID**: https://developer.apple.com/account → En la esquina superior derecha

### En tu Proyecto:
- **Bundle ID**: Xcode → Runner → Signing & Capabilities → Bundle Identifier
- **Entitlements**: `ios/Runner/Runner.entitlements`
- **GoogleService-Info.plist**: `ios/Runner/GoogleService-Info.plist`

---

## ✅ Estado Final Esperado

Cuando todo esté configurado correctamente, deberías ver:

### En Firebase Console:
- ✅ Clave APNS de desarrollo configurada (con Key ID y Team ID)
- ✅ Clave APNS de producción configurada (opcional, si usas producción)

### En los Logs de la App:
```
✅ Token APNS obtenido: [token_apns_aqui]
📱 Token FCM: [token_fcm_aqui]
✅ NotificationService inicializado correctamente
```

### Al Enviar Notificación desde Firebase Console:
- ✅ La notificación llega al dispositivo
- ✅ La notificación aparece en el centro de notificaciones
- ✅ Al tocar, la app se abre correctamente

---

## 🆘 Si Aún Tienes Problemas

1. **Revisa los logs completos** de la app para ver errores específicos
2. **Verifica cada paso** de esta guía uno por uno
3. **Consulta las otras guías**:
   - `SOLUCION_ERROR_APNS_TOKEN.md`
   - `SOLUCION_TOKEN_APNS_FALTANTE.md`
   - `GUIA_OBTENER_CERTIFICADO_P12_APNS.md`
   - `GUIA_PROBAR_NOTIFICACIONES_IOS.md`

---

## 📱 Paso 9: Información para App Store Review (App Store Connect)

Cuando envíes tu app a la App Store, los revisores de Apple pueden necesitar probar las notificaciones push. En la sección **"App Review Information"**, puedes proporcionar información útil:

### Información de Inicio de Sesión (Sign-In Information)

Si tu app requiere autenticación:

- **Sign-in required**: Marca esta casilla si la app requiere login
- **User name**: Proporciona una cuenta de prueba (ej: `reviewer@test.com`)
- **Password**: Proporciona la contraseña de la cuenta de prueba

**Nota:** Solo proporciona credenciales si es necesario. Si las notificaciones funcionan sin login, no necesitas marcar "Sign-in required".

### Información de Contacto (Contact Information)

Completa con tu información real:
- **First name**: Tu nombre
- **Last name**: Tu apellido  
- **Phone number**: Tu número de teléfono
- **Email**: Tu correo electrónico

Los revisores de Apple pueden contactarte si tienen preguntas sobre tu app.

### Notas para los Revisores (Notes)

En el campo **"Notes"**, puedes incluir información específica sobre las notificaciones push:

**Ejemplo de notas recomendadas:**

```
INFORMACIÓN SOBRE NOTIFICACIONES PUSH:

Esta app utiliza Firebase Cloud Messaging (FCM) para enviar notificaciones push a los usuarios.

Para probar las notificaciones:
1. Acepta los permisos de notificación cuando la app los solicite
2. Las notificaciones se enviarán automáticamente cuando:
   - Haya cambios en las condiciones de playas favoritas
   - Se publiquen nuevos reportes de playas
   - Haya actualizaciones importantes del clima

Las notificaciones push requieren conexión a internet y permisos de notificación habilitados.

CONFIGURACIÓN TÉCNICA:
- APNS Authentication Key configurada en Firebase
- Bundle ID: com.playasrd.playasrd
- Push Notifications capability habilitada
- Background Modes (Remote notifications) configurado

Si tienes problemas probando las notificaciones, por favor contacta al desarrollador usando la información de contacto proporcionada.
```

**Versión más corta (si prefieres):**

```
NOTIFICACIONES PUSH:
Esta app envía notificaciones push usando Firebase Cloud Messaging. 
Las notificaciones se activan automáticamente cuando hay cambios en las condiciones 
de playas favoritas o nuevos reportes. Los usuarios deben aceptar permisos de notificación 
cuando la app los solicite.

Si necesita probar las notificaciones y encuentra algún problema, 
por favor contácteme usando la información de contacto proporcionada.
```

### ¿Por Qué Es Importante?

Incluir esta información en las notas ayuda a:
- ✅ Explicar a los revisores cómo funcionan las notificaciones
- ✅ Reducir la posibilidad de rechazo por no poder probar la funcionalidad
- ✅ Facilitar la comunicación si hay problemas
- ✅ Demostrar que la funcionalidad está correctamente implementada

---

**Nota importante:** La configuración de APNS es crítica para que las notificaciones push funcionen en iOS. Sin una clave APNS válida en Firebase, las notificaciones NO funcionarán, incluso si todo lo demás está correcto.


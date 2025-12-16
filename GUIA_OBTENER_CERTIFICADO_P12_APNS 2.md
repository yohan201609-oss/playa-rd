# Guía: Cómo Obtener el Certificado P12 para APNS

## 📋 Requisitos Previos

- Tener una cuenta de Apple Developer (gratuita o de pago)
- Tener acceso a Keychain Access en macOS
- Tener el certificado de desarrollo de iOS instalado

---

## 🔄 Método 1: Usar Certificado Existente (Recomendado)

Si ya tienes un certificado de desarrollo de iOS instalado en tu Mac:

### Paso 1: Abrir Keychain Access

1. Abre **Keychain Access** (Acceso a Llaveros) en tu Mac
   - Presiona `Cmd + Espacio` y busca "Keychain Access"
   - O ve a: Aplicaciones → Utilidades → Keychain Access

### Paso 2: Encontrar el Certificado

1. En el panel izquierdo, selecciona **"login"** (o "Inicio de sesión")
2. En la categoría, selecciona **"My Certificates"** (Mis certificados)
3. Busca un certificado que diga algo como:
   - `Apple Development: [tu nombre]`
   - `iPhone Developer: [tu nombre]`
   - O cualquier certificado relacionado con desarrollo de iOS

### Paso 3: Exportar como P12

1. **Haz clic derecho** en el certificado
2. Selecciona **"Export [nombre del certificado]"** (Exportar)
3. Elige un nombre para el archivo (ej: `apns_development.p12`)
4. Elige una ubicación (ej: Escritorio)
5. Haz clic en **"Save"** (Guardar)

### Paso 4: Crear Contraseña

1. Te pedirá crear una **contraseña** para el archivo P12
2. **Anota esta contraseña** - la necesitarás al subir el archivo a Firebase
3. Opcionalmente, puedes dejar la contraseña vacía (no recomendado por seguridad)
4. Haz clic en **"OK"**

### Paso 5: Confirmar Exportación

1. Te pedirá tu contraseña de administrador de Mac
2. Ingresa tu contraseña y haz clic en **"Allow"** (Permitir)

✅ **Listo!** Ahora tienes el archivo `.p12` listo para subir a Firebase.

---

## 📱 Paso 0: Crear App ID (Si no lo tienes)

Antes de crear el certificado APNS, necesitas tener un **App ID** registrado en Apple Developer. Si ya lo tienes, puedes saltar este paso.

### Paso 1: Ir a Identifiers

1. Ve a [Apple Developer Portal](https://developer.apple.com/account)
2. Inicia sesión con tu cuenta de Apple Developer
3. Ve a **Certificates, Identifiers & Profiles**
4. En el menú lateral, selecciona **"Identifiers"**
5. Haz clic en el botón **"+"** (agregar) en la esquina superior derecha

### Paso 2: Completar el Formulario de App ID

1. **Platform:** Selecciona **"iOS, iPadOS, macOS, tvOS, watchOS, visionOS"** (o solo iOS si prefieres)

2. **Description:** Ingresa **"Playas RD"** (o el nombre que prefieras)
   - ⚠️ No uses caracteres especiales como @, &, *, "

3. **App ID Prefix:** Se mostrará automáticamente tu Team ID (ej: `C3TZFSL98Z`)

4. **Bundle ID:** 
   - Selecciona **"Explicit"** (Explícito)
   - Ingresa: **`com.playasrd.playasrd`**
   - Este debe coincidir exactamente con el Bundle ID de tu proyecto Xcode

5. Haz clic en **"Continue"**

### Paso 3: Seleccionar Capacidades (Capabilities)

#### ¿Qué son las Capabilities?

Las **Capabilities** (Capacidades) son permisos y funcionalidades especiales que tu app necesita para acceder a características específicas del sistema iOS. Cada capability debe estar habilitada tanto en el **App ID** (en Apple Developer) como configurada en tu proyecto Xcode.

#### Capabilities que NECESITAS habilitar para tu app "Playas RD":

Basándome en tu `Info.plist` y código, estas son las capabilities que debes habilitar:

**🔴 OBLIGATORIAS:**

1. **✅ Push Notifications** 
   - **Por qué:** Necesario para recibir notificaciones push desde Firebase
   - **Evidencia en tu código:** `UIBackgroundModes` incluye `remote-notification`
   - **Sin esto:** Las notificaciones push NO funcionarán

2. **✅ Background Modes**
   - **Por qué:** Permite que la app funcione en segundo plano
   - **Evidencia en tu código:** `UIBackgroundModes` con `fetch`, `remote-notification`, `audio`
   - **Sin esto:** La app no puede recibir notificaciones cuando está cerrada

**🟡 RECOMENDADAS (según tu app):**

3. **✅ Maps**
   - **Por qué:** Usas Google Maps (`google_maps_flutter`)
   - **Evidencia:** Tienes `MBXAccessToken` (Mapbox) y usas mapas en `MapScreen`
   - **Sin esto:** Los mapas pueden no funcionar correctamente

4. **✅ Location Services** (o "Location" en algunas versiones)
   - **Por qué:** Usas `geolocator` y `geocoding` para ubicación
   - **Evidencia:** `NSLocationWhenInUseUsageDescription` y `NSLocationAlwaysUsageDescription`
   - **Sin esto:** No podrás obtener la ubicación del usuario

5. **✅ Sign in with Apple** (si usas autenticación con Apple)
   - **Por qué:** Si tienes opción de login con Apple
   - **Evidencia:** Tienes `GIDClientID` (Google Sign-In), pero no veo Apple Sign-In
   - **Solo si:** Implementas autenticación con Apple

**🟢 OPCIONALES (si las necesitas en el futuro):**

6. **Associated Domains**
   - **Para:** Enlaces universales (deep links)
   - **Ejemplo:** `playasrd.com/beach/123` abre directamente la app

7. **In-App Purchase**
   - **Para:** Vender contenido dentro de la app
   - **Ejemplo:** Versión premium, playas destacadas, etc.

8. **Game Center**
   - **Para:** Logros, leaderboards (si agregas gamificación)

#### Resumen para tu App ID:

**Mínimo necesario:**
- ✅ Push Notifications
- ✅ Background Modes

**Recomendado para tu app:**
- ✅ Push Notifications
- ✅ Background Modes
- ✅ Maps
- ✅ Location Services

**Cómo habilitarlas:**
1. En la pestaña **"Capabilities"**, busca cada una en la lista
2. Marca la casilla **"ENABLE"** (Habilitar) junto a cada capability
3. Haz clic en el icono **ⓘ** si quieres ver más información sobre cada una

### Paso 4: Registrar el App ID

1. Revisa la información
2. Haz clic en **"Register"** (Registrar)
3. ✅ **Listo!** Tu App ID está creado

---

## 🔄 Método 2: Crear Nuevo Certificado desde Apple Developer

Si no tienes un certificado o necesitas crear uno nuevo:

### Paso 1: Ir a Apple Developer

1. Ve a [Apple Developer Portal](https://developer.apple.com/account)
2. Inicia sesión con tu cuenta de Apple Developer

### Paso 2: Crear Certificado APNS

1. Ve a **Certificates, Identifiers & Profiles**
2. En el menú lateral, selecciona **"Certificates"**
3. Haz clic en el botón **"+"** (agregar) en la esquina superior derecha

### Paso 3: Seleccionar Tipo de Certificado

1. Selecciona **"Apple Push Notification service SSL (Sandbox & Production)"**
   - O **"Apple Push Notification service SSL (Sandbox)"** para solo desarrollo
2. Haz clic en **"Continue"**

### Paso 4: Seleccionar App ID

1. Selecciona tu **App ID** (ej: `com.playasrd.playasrd`)
2. Si no tienes uno, créalo primero en "Identifiers"
3. Haz clic en **"Continue"**

### Paso 5: Crear Certificate Signing Request (CSR)

1. En tu Mac, abre **Keychain Access**
2. Ve a: **Keychain Access** → **Certificate Assistant** → **Request a Certificate From a Certificate Authority...**
3. Ingresa:
   - **User Email Address:** Tu email
   - **Common Name:** Tu nombre o nombre de la app
   - **CA Email Address:** Déjalo vacío
   - **Request is:** Selecciona **"Saved to disk"**
4. Haz clic en **"Continue"**
5. Guarda el archivo `.certSigningRequest` en tu Escritorio

### Paso 6: Subir CSR a Apple Developer

1. De vuelta en Apple Developer Portal
2. Haz clic en **"Choose File"** y selecciona el archivo `.certSigningRequest` que acabas de crear
3. Haz clic en **"Continue"**

### Paso 7: Descargar Certificado

1. Apple generará el certificado
2. Haz clic en **"Download"** para descargar el archivo `.cer`

### Paso 8: Instalar Certificado

1. **Doble clic** en el archivo `.cer` descargado
2. Se instalará automáticamente en Keychain Access

### Paso 9: Exportar como P12

Sigue los pasos del **Método 1** (Paso 3 en adelante) para exportar el certificado como P12.

---

## 📤 Subir P12 a Firebase Console

### Paso 1: Ir a Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto: **playas-rd-2b475**
3. Ve a **Configuración del proyecto** (⚙️)
4. Pestaña **"Cloud Messaging"**

### Paso 2: Subir Certificado

1. En la sección **"Certificados APNs"**
2. Haz clic en **"Subir certificado"** o **"Upload"**
3. Selecciona **"Certificado de desarrollo"** o **"Development certificate"**
4. Haz clic en **"Explorar"** o arrastra el archivo `.p12`
5. Ingresa la **contraseña** que creaste al exportar (o déjala vacía si no pusiste contraseña)
6. Haz clic en **"Subir"** o **"Upload"**

✅ **Listo!** El certificado está configurado.

---

## 🔍 Verificar que Funciona

Después de subir el certificado:

1. **Ejecuta la app en un dispositivo físico:**
   ```bash
   flutter run
   ```

2. **Busca en los logs:**
   ```
   ✅ Token APNS obtenido: [token]
   📱 TOKEN FCM PARA NOTIFICACIONES PUSH
   📱 TOKEN FCM: [token_fcm]
   ```

3. **Prueba enviar una notificación:**
   - Ve a Firebase Console → Cloud Messaging
   - "Enviar mensaje de prueba"
   - Pega el token FCM
   - Envía la notificación

---

## ⚠️ Problemas Comunes

### Error: "No se puede exportar porque falta la clave privada"

**Solución:**
- Asegúrate de que el certificado tenga su clave privada asociada
- En Keychain Access, verifica que el certificado tenga una flecha desplegable
- Si no tiene clave privada, necesitas crear un nuevo certificado

### Error: "Contraseña incorrecta"

**Solución:**
- Si olvidaste la contraseña, tendrás que exportar el certificado nuevamente
- O deja la contraseña vacía al exportar (menos seguro)

### Error: "Certificado expirado"

**Solución:**
- Los certificados de desarrollo expiran después de 1 año
- Crea un nuevo certificado siguiendo el Método 2
- Sube el nuevo certificado a Firebase

### No aparece el certificado en Keychain Access

**Solución:**
- Verifica que estés viendo "login" (no "System")
- Verifica que estés en la categoría "My Certificates"
- Si instalaste el certificado pero no aparece, reinstálalo (doble clic en el .cer)

---

## 📝 Notas Importantes

1. **Certificado de Desarrollo vs Producción:**
   - **Desarrollo:** Para probar en dispositivos durante desarrollo
   - **Producción:** Para TestFlight y App Store
   - Puedes tener ambos y subirlos a Firebase

2. **Seguridad:**
   - El archivo P12 contiene tu clave privada - **manténlo seguro**
   - No lo subas a repositorios públicos
   - Considera usar contraseña al exportar

3. **Vencimiento:**
   - Los certificados APNS expiran después de 1 año
   - Necesitarás renovarlos periódicamente

4. **Alternativa: APNs Auth Key (Recomendado para producción):**
   - En lugar de certificados P12, puedes usar una **APNs Auth Key**
   - No expira y funciona para todas tus apps
   - Ve a Apple Developer → Keys → Crea una nueva key con "Apple Push Notifications service (APNs)"
   - Descarga el archivo `.p8` y súbelo a Firebase

---

## ✅ Checklist

- [ ] Certificado instalado en Keychain Access
- [ ] Certificado exportado como P12
- [ ] Contraseña del P12 anotada (si se usó)
- [ ] Archivo P12 subido a Firebase Console
- [ ] Token FCM obtenido correctamente en la app
- [ ] Notificación de prueba enviada exitosamente

---

## 🆘 ¿Necesitas Ayuda?

Si tienes problemas:
1. Verifica que el certificado esté instalado correctamente en Keychain Access
2. Asegúrate de estar usando un dispositivo físico (no simulador)
3. Verifica que Push Notifications esté habilitado en tu App ID en Apple Developer
4. Revisa los logs de la app para ver errores específicos

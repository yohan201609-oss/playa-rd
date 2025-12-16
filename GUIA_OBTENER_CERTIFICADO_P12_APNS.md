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

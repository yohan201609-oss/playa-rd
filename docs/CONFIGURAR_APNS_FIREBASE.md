# Guía: Configurar APNS para Firebase Cloud Messaging en iOS

## Información del Proyecto
- **Bundle ID**: `com.playasrd.playasrd`
- **App Name**: Playas RD IOS
- **Firebase Project**: playas-rd-2b475

## Método Recomendado: Claves de Autenticación de APNS

### Paso 1: Acceder a Apple Developer Portal
1. Ve a [https://developer.apple.com/account](https://developer.apple.com/account)
2. Inicia sesión con tu cuenta de desarrollador de Apple

### Paso 2: Crear una Clave de Autenticación de APNS
1. En el menú lateral izquierdo, haz clic en **"Certificates, Identifiers & Profiles"**
2. En la sección **"Keys"**, haz clic en el botón **"+"** (o "Create a key")
3. Completa el formulario:
   - **Key Name**: Ejemplo: "Playas RD APNS Key" o "Firebase APNS Key"
   - **Activa la casilla**: ✅ **"Apple Push Notifications service (APNs)"**
4. Haz clic en **"Continue"** y luego en **"Register"**

### Paso 3: Descargar y Guardar la Clave
⚠️ **IMPORTANTE**: Solo puedes descargar el archivo `.p8` **UNA VEZ**. Guárdalo en un lugar seguro.

1. Haz clic en **"Download"** para descargar el archivo `.p8`
2. **Anota la siguiente información** (la necesitarás en Firebase):
   - **Key ID**: Aparece en la página de detalles de la clave (ejemplo: `ABC123XYZ`)
   - **Team ID**: Aparece en la esquina superior derecha del portal (ejemplo: `TEAM123456`)

### Paso 4: Subir la Clave a Firebase
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto: **playas-rd-2b475**
3. Ve a **Configuración del proyecto** (⚙️) → **Apps de Apple** → **"Playas RD IOS"**
4. En la sección **"Clave de autenticación de APNS"**:
   
   **Para Desarrollo:**
   - Haz clic en el botón **"Subir"** junto a "No se subió una clave de autenticación de APNS de desarrollo"
   - Selecciona el archivo `.p8` que descargaste
   
   - Ingresa el **Key ID**
   - Ingresa el **Team ID**
   - Haz clic en **"Subir"**
   
   **Para Producción:**
   - Haz clic en el botón **"Subir"** junto a "No se proporcionó una clave de autenticación de APNS de producción"
   - Selecciona el **mismo archivo `.p8`** (la misma clave funciona para ambos)
   - Ingresa el **Key ID** (el mismo)
   - Ingresa el **Team ID** (el mismo)
   - Haz clic en **"Subir"**

### ✅ Verificación
Después de subir las claves, deberías ver:
- ✅ Una clave de autenticación de APNS de desarrollo configurada
- ✅ Una clave de autenticación de APNS de producción configurada

## Método Alternativo: Certificados de APNS (No Recomendado)

Si prefieres usar certificados en lugar de claves (método más antiguo):

1. En Apple Developer Portal, ve a **"Certificates"**
2. Haz clic en **"+"** para crear un nuevo certificado
3. Selecciona **"Apple Push Notification service SSL (Sandbox & Production)"**
4. Selecciona tu App ID: `com.playasrd.playasrd`
5. Sigue el asistente para crear un CSR (Certificate Signing Request) usando Keychain Access
6. Descarga el certificado y súbelo a Firebase

⚠️ **Nota**: Las claves de autenticación son más modernas y recomendadas porque:
- No expiran
- Funcionan para desarrollo y producción
- Son más fáciles de gestionar

## Solución de Problemas

### Error: "Invalid Key"
- Verifica que el archivo `.p8` sea el correcto
- Asegúrate de que el Key ID y Team ID sean correctos
- Verifica que la clave tenga habilitado "Apple Push Notifications service (APNs)"

### Error: "Key already exists"
- Si ya subiste una clave, no necesitas subirla de nuevo
- Verifica en Firebase Console si ya está configurada

### No puedo descargar el archivo .p8
- Si ya lo descargaste antes, no podrás descargarlo de nuevo
- Necesitarás crear una nueva clave si perdiste el archivo

## Referencias
- [Documentación de Firebase: Configurar APNs](https://firebase.google.com/docs/cloud-messaging/ios/certificates)
- [Documentación de Apple: Managing Keys](https://developer.apple.com/documentation/security/certificates_and_keys)


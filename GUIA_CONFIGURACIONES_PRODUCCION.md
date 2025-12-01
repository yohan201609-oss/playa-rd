# 🚀 Guía Paso a Paso: Configuraciones para Producción - Android

> **Nota:** Esta guía se enfoca en **Android** para publicación en Google Play Store.  
> Para iOS/App Store, consulta la documentación cuando estés listo.

## 📋 Índice

1. [Configuración de Variables de Entorno](#1-configuración-de-variables-de-entorno)
2. [Configuración de Android para Producción](#2-configuración-de-android-para-producción)
3. [Seguridad de Firebase](#3-seguridad-de-firebase)
4. [Restricciones de API Keys](#4-restricciones-de-api-keys)
5. [Configuración de Google Play Console](#5-configuración-de-google-play-console)
6. [Optimizaciones Finales](#6-optimizaciones-finales)
7. [Checklist Final](#7-checklist-final)

> **📖 Guía Completa:** Para una guía detallada paso a paso, consulta [GUIA_PRODUCCION_ANDROID.md](./GUIA_PRODUCCION_ANDROID.md)

---

## 1. Configuración de Variables de Entorno

### ⚠️ **PRIORIDAD ALTA**

### Paso 1.1: Crear archivo `.env`

Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:

```bash
# API Key de OpenWeatherMap (para el servicio de clima)
OPENWEATHER_API_KEY=tu_api_key_aqui

# API Key de Google Maps (si se usa en el futuro)
MAPS_API_KEY=tu_api_key_aqui

# URL base de API (si aplica)
API_BASE_URL=https://api.tudominio.com
```

### Paso 1.2: Obtener API Key de OpenWeatherMap

1. Ve a [OpenWeatherMap](https://openweathermap.org/api)
2. Crea una cuenta gratuita
3. Genera una API Key en tu dashboard
4. Copia la key y pégala en el archivo `.env`

**Límites del plan gratuito:**
- 60 llamadas por minuto
- 1,000,000 llamadas por mes
- Suficiente para producción inicial

### Paso 1.3: Crear archivo `.env.example`

Crea un archivo `.env.example` (sin valores reales) para documentar las variables necesarias:

```bash
# API Key de OpenWeatherMap
OPENWEATHER_API_KEY=

# API Key de Google Maps
MAPS_API_KEY=

# URL base de API
API_BASE_URL=
```

### Paso 1.4: Agregar `.env` a `.gitignore`

Asegúrate de que `.env` esté en `.gitignore` para no subir las keys al repositorio:

```gitignore
# Variables de entorno
.env
.env.local
.env.*.local
```

**✅ Verificación:**
```bash
# Verificar que el archivo existe
ls -la .env

# Verificar que está en .gitignore
cat .gitignore | grep .env
```

---

## 2. Configuración de Android para Producción

### ⚠️ **PRIORIDAD CRÍTICA**

### Paso 2.1: Crear Keystore para Firma de Aplicación

**IMPORTANTE:** Guarda este keystore en un lugar seguro. Si lo pierdes, no podrás actualizar tu app en Google Play.

```bash
# Generar keystore
keytool -genkey -v -keystore ~/playas-rd-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias playas-rd

# O en Windows (PowerShell):
keytool -genkey -v -keystore $env:USERPROFILE\playas-rd-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias playas-rd
```

**Información que te pedirá:**
- Contraseña del keystore: **GUÁRDALA EN UN LUGAR SEGURO**
- Nombre y apellido: Tu nombre o nombre de la empresa
- Unidad organizacional: (puedes dejarlo vacío)
- Ciudad: Tu ciudad
- Estado/Provincia: Tu estado/provincia
- Código de país: DO (para República Dominicana)

### Paso 2.2: Crear archivo `key.properties`

Crea un archivo `android/key.properties` (NO lo subas a Git):

```properties
storePassword=tu_contraseña_del_keystore
keyPassword=tu_contraseña_del_keystore
keyAlias=playas-rd
storeFile=C:\\Users\\TuUsuario\\playas-rd-release-key.jks
```

**⚠️ IMPORTANTE:** 
- Usa rutas absolutas en Windows
- Reemplaza `TuUsuario` con tu nombre de usuario de Windows
- Guarda este archivo en un lugar seguro

### Paso 2.3: Actualizar `android/app/build.gradle.kts`

Modifica el archivo para usar el keystore en builds de release:

```kotlin
// Agregar al inicio del archivo, después de los plugins
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("⚠️ key.properties no encontrado. Usando configuración de debug.")
}

android {
    // ... código existente ...

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Cambiar esta línea:
            // signingConfig = signingConfigs.getByName("debug")
            // Por:
            signingConfig = signingConfigs.getByName("release")
            
            // Agregar minificación y ofuscación
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### Paso 2.4: Crear archivo ProGuard

Crea `android/app/proguard-rules.pro`:

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

# Gson (si se usa)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Mantener clases de modelos
-keep class com.playasrd.playasrd.models.** { *; }
```

### Paso 2.5: Actualizar `android/gradle.properties`

Agregar al final del archivo:

```properties
# Habilitar R8 completo para producción
android.enableR8.fullMode=true
```

### Paso 2.6: Agregar `key.properties` a `.gitignore`

```gitignore
# Android keystore
android/key.properties
*.jks
*.keystore
```

**✅ Verificación:**
```bash
# Probar build de release
flutter build apk --release

# O para App Bundle (recomendado para Google Play)
flutter build appbundle --release
```

---

## 3. Seguridad de Firebase

### ⚠️ **PRIORIDAD ALTA**

### Paso 4.1: Actualizar Reglas de Firestore

**Problema actual:** Las reglas permiten escritura sin autenticación.

Actualiza `firestore.rules`:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Funciones de ayuda
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // PLAYAS - Solo lectura pública, escritura solo para admins
    match /beaches/{beachId} {
      allow read: if true;
      // TODO: Crear colección de admins y verificar aquí
      allow write: if isSignedIn(); // Temporal: cambiar a verificación de admin
    }
    
    // REPORTES - Los usuarios pueden crear y editar sus propios reportes
    match /reports/{reportId} {
      allow read: if true;
      allow create: if isSignedIn() && 
        request.resource.data.userId == request.auth.uid;
      allow update: if isSignedIn() && 
        resource.data.userId == request.auth.uid;
      allow delete: if isSignedIn() && 
        resource.data.userId == request.auth.uid;
    }
    
    // USUARIOS - Solo pueden ver y editar su propia información
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create, update: if isSignedIn() && isOwner(userId);
      allow delete: if false; // No permitir borrar usuarios
    }
    
    // FOTOS DE VISITANTES
    match /beach_photos/{photoId} {
      allow read: if true;
      allow create: if isSignedIn() && 
        request.resource.data.uid == request.auth.uid;
      allow delete: if isSignedIn() && 
        resource.data.uid == request.auth.uid;
      allow update: if false;
    }
  }
}
```

### Paso 4.2: Desplegar Reglas de Firestore

```bash
# Instalar Firebase CLI si no lo tienes
npm install -g firebase-tools

# Iniciar sesión
firebase login

# Desplegar reglas
firebase deploy --only firestore:rules
```

### Paso 4.3: Actualizar Reglas de Storage

Las reglas actuales están bien, pero verifica que `storage.rules` tenga:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isImage() {
      return request.resource.contentType.matches('image/.*');
    }
    
    // FOTOS DE REPORTES - Solo usuarios autenticados
    match /reports/{userId}/{fileName} {
      allow read: if true;
      allow write: if isSignedIn() && 
        isOwner(userId) &&
        isImage() &&
        request.resource.size < 5 * 1024 * 1024; // 5MB
    }
    
    // FOTOS DE PERFIL
    match /profiles/{userId}/{fileName} {
      allow read: if true;
      allow write: if isSignedIn() && 
        isOwner(userId) &&
        isImage() &&
        request.resource.size < 2 * 1024 * 1024; // 2MB
    }
    
    // FOTOS DE PLAYAS - Solo usuarios autenticados
    match /beaches/{beachId}/{fileName} {
      allow read: if true;
      allow write: if isSignedIn() &&
        isImage() &&
        request.resource.size < 10 * 1024 * 1024; // 10MB
    }
    
    // FOTOS DE VISITANTES
    match /beach_photos/{beachId}/{fileName} {
      allow read: if true;
      allow write: if isSignedIn() && 
        isImage() &&
        request.resource.size < 5 * 1024 * 1024; // 5MB
    }
  }
}
```

### Paso 4.4: Desplegar Reglas de Storage

```bash
firebase deploy --only storage
```

---

## 4. Restricciones de API Keys

### ⚠️ **PRIORIDAD ALTA**

> **📋 Referencia Rápida - SHA-1:**
> 
> **⚠️ IMPORTANTE:** Cuando usas App Bundles, Google Play usa su propia clave de firma. Necesitas el SHA-1 de la clave de Google Play, no el de tu keystore local.
> 
> **SHA-1 de Google Play (App Signing Key)** - **USA ESTE:**
> - Obtén el certificado desde: Google Play Console → Integridad de la app → Firma de apps → "Descargar certificado"
> - Este es el SHA-1 que Google Play usa para firmar los APKs finales
> - **Este es el que debes usar para Firebase y restricciones de API**
> 
> **SHA-1 de Keystore Local (Upload Key)** - Solo referencia:
> - SHA-1: `3B:28:EC:D6:0C:45:15:5C:9A:62:15:34:4F:BE:77:12:50:F6:24:86`
> - Keystore: `C:\Users\Johan Almanzar\playas-rd-release-key.jks`
> - Alias: `playas-rd`
> - Package Name: `com.playasrd.playasrd`
> - **Nota:** Este es solo para firmar el App Bundle que subes, no para los APKs finales

### Paso 5.1: Restringir Google Maps API Key

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto `playas-rd-2b475`
3. Ve a "APIs & Services" > "Credentials"
4. Encuentra tu API Key de Google Maps
5. Haz clic en editar
6. En "Application restrictions":
   - Selecciona "Android apps"
   - Agrega el package name: `com.playasrd.playasrd`
   - Agrega el SHA-1 de tu keystore de release
7. En "API restrictions":
   - Selecciona "Restrict key"
   - Marca solo: "Maps SDK for Android" y "Places API"

**Obtener SHA-1 del keystore de PRODUCCIÓN (Release):**

**Windows (PowerShell):**
```powershell
keytool -list -v -keystore "C:\Users\Johan Almanzar\playas-rd-release-key.jks" -alias playas-rd -storepass TU_CONTRASEÑA
```

**Linux/Mac:**
```bash
keytool -list -v -keystore ~/playas-rd-release-key.jks -alias playas-rd
```

**⚠️ IMPORTANTE - Diferencia entre SHA-1 de Google Play y Keystore Local:**

### 1. SHA-1 de Google Play (App Signing Key) - **USA ESTE PARA PRODUCCIÓN**

Cuando subes un App Bundle, Google Play genera su propia clave de firma y la usa para firmar los APKs que distribuye a los usuarios.

**Cómo obtener el SHA-1 de Google Play:**

1. Ve a **Google Play Console** → Tu app → **Integridad de la app** → **Firma de apps**
2. En la sección **"Certificado de la clave de firma de la app"**, haz clic en **"Descargar certificado"**
3. Guarda el archivo (generalmente se llama `deployment_cert.der` o similar)
4. Obtén el SHA-1 del certificado descargado:

**Windows (PowerShell):**
```powershell
keytool -printcert -file "ruta\al\certificado.der"
```

**Linux/Mac:**
```bash
keytool -printcert -file ruta/al/certificado.der
```

**O si es un archivo .pem:**
```bash
openssl x509 -in certificado.pem -fingerprint -sha1 -noout
```

**Este SHA-1 es el que debes usar para:**
- ✅ Configurar Firebase (agregarlo en Firebase Console)
- ✅ Restricciones de API en Google Cloud Console
- ✅ Cualquier servicio que requiera el SHA-1 de la app en producción

### 2. SHA-1 de Keystore Local (Upload Key) - Solo referencia

Este es el SHA-1 de tu keystore local que usas para firmar el App Bundle antes de subirlo.

- **SHA-1**: `3B:28:EC:D6:0C:45:15:5C:9A:62:15:34:4F:BE:77:12:50:F6:24:86`
- **Keystore**: `C:\Users\Johan Almanzar\playas-rd-release-key.jks`
- **Alias**: `playas-rd`
- **Nota:** Este SHA-1 NO se usa para los APKs finales que Google Play distribuye

**Para obtener SHA-1 del keystore local:**
```powershell
keytool -list -v -keystore "C:\Users\Johan Almanzar\playas-rd-release-key.jks" -alias playas-rd -storepass TU_CONTRASEÑA
```

### 3. SHA-1 de DEBUG - Solo desarrollo

- **SHA-1**: `72:F1:7A:53:0F:1B:EB:E0:0D:DD:1D:92:0F:56:5A:8D:2D:05:08:E6`
- Solo para desarrollo local
- No usar para producción

**Para obtener SHA-1 de DEBUG:**
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### 📝 Resumen

| Tipo | Cuándo usar | Dónde obtener |
|------|-------------|---------------|
| **SHA-1 de Google Play** | ✅ **Producción** (Firebase, APIs) | Google Play Console → Firma de apps → Descargar certificado |
| **SHA-1 de Keystore Local** | Solo para referencia | Tu keystore local (`playas-rd-release-key.jks`) |
| **SHA-1 de Debug** | Solo desarrollo | Keystore de debug (`.android/debug.keystore`) |

### 🔄 Actualizar Firebase con SHA-1 de Google Play

**Después de subir tu primera versión a Google Play:**

1. **Obtén el certificado de Google Play:**
   - Google Play Console → **Integridad de la app** → **Firma de apps**
   - Haz clic en **"Descargar certificado"**
   - Guarda el archivo (ej: `deployment_cert.der`)

2. **Obtén el SHA-1 del certificado:**
   ```powershell
   keytool -printcert -file "ruta\al\certificado.der"
   ```
   Busca la línea que dice `SHA1:` y copia el valor (sin espacios).

3. **Agrega el SHA-1 en Firebase Console:**
   - Ve a [Firebase Console](https://console.firebase.google.com/)
   - Selecciona tu proyecto `playas-rd-2b475`
   - Ve a **Configuración del proyecto** (⚙️) → **Tus apps**
   - Haz clic en tu app Android
   - En **"Huellas digitales del certificado SHA"**, haz clic en **"Agregar huella digital"**
   - Pega el SHA-1 de Google Play (sin los dos puntos)
   - Guarda los cambios

4. **Descarga el nuevo `google-services.json`:**
   - Después de agregar el SHA-1, descarga el nuevo archivo `google-services.json`
   - Reemplaza el archivo en `android/app/google-services.json`
   - Reconstruye tu app

**⚠️ Nota:** Puedes tener múltiples SHA-1 configurados en Firebase (debug, upload key, y app signing key). Esto permite que la app funcione tanto en desarrollo como en producción.

### Paso 5.2: Restringir Firebase API Keys

Para cada API Key de Firebase (Android, iOS, Web):

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto `playas-rd-2b475`
3. Ve a "APIs & Services" > "Credentials"
4. Para cada API Key:
   - **Android:** Restringir a package name `com.playasrd.playasrd`
   - **iOS:** Restringir a bundle ID `com.playasrd.playasrd`
   - **Web:** Restringir a dominios específicos (si aplica)

### Paso 5.3: Habilitar APIs Necesarias

Asegúrate de que estas APIs estén habilitadas en Google Cloud Console:

- ✅ Maps SDK for Android
- ✅ Maps SDK for iOS
- ✅ Places API
- ✅ Geocoding API
- ✅ Firebase Cloud Messaging API
- ✅ Firebase Authentication API

---

## 5. Configuración de Google Play Console

### ⚠️ **PRIORIDAD ALTA**

### Paso 6.1: Crear Cuenta de Desarrollador

1. Ve a [Google Play Console](https://play.google.com/console)
2. Paga la tarifa única de $25 USD
3. Completa el perfil de desarrollador

### Paso 6.2: Crear la Aplicación

1. Haz clic en "Crear aplicación"
2. Completa la información:
   - **Nombre de la app:** Playas RD
   - **Idioma predeterminado:** Español
   - **Tipo de app:** Aplicación
   - **Gratis o de pago:** Gratis

### Paso 6.3: Configurar Store Listing

Completa toda la información:

- **Descripción corta:** Descubre las mejores playas de República Dominicana
- **Descripción completa:** (Usa el contenido de `README.md`)
- **Icono:** 512x512 px
- **Capturas de pantalla:** Mínimo 2, máximo 8
- **Categoría:** Viajes y guías locales
- **Contacto:** Tu email
- **Política de privacidad:** URL (debes crear una página web o usar GitHub Pages)

### Paso 6.4: Configurar Contenido de la App

1. **Clasificación de contenido:** Completa el cuestionario
2. **Objetivo de la app y público:** Selecciona apropiadamente
3. **Política de privacidad:** Debe ser una URL pública

### Paso 6.5: Crear Versión de Prueba Interna

Antes de publicar a producción, es recomendable crear una versión de prueba interna para validar que todo funcione correctamente.

#### 6.5.1: Acceder a la Sección de Pruebas Internas

1. En Google Play Console, ve a tu aplicación
2. En el menú lateral, selecciona **"Pruebas"** > **"Pruebas internas"**
3. Haz clic en **"Crear una versión de prueba interna"**

#### 6.5.2: Subir Paquetes de Aplicación

En la sección **"Paquetes de aplicación"**:

1. **Opción 1: Arrastrar y Soltar**
   - Arrastra tu archivo `.aab` (App Bundle) o `.apk` al área de carga
   - El área muestra: "Suelta los paquetes de aplicaciones aquí para subirlos"
   - Suelta el archivo cuando veas el área resaltada

2. **Opción 2: Botón Subir**
   - Haz clic en el botón **"Subir"** (con icono de flecha hacia arriba)
   - Selecciona tu archivo desde el explorador de archivos
   - Archivo recomendado: `build/app/outputs/bundle/release/app-release.aab`

3. **Opción 3: Agregar desde la Biblioteca**
   - Haz clic en **"Agregar desde la biblioteca"** (icono de carpeta con plus)
   - Selecciona un paquete previamente subido

**✅ Archivos aceptados:**
- App Bundle (`.aab`) - **Recomendado para Google Play**
- APK (`.apk`) - Para pruebas rápidas

#### 6.5.3: Completar Detalles de la Versión

En la sección **"Detalles de la versión"**:

1. **Nombre de la versión** (campo obligatorio, máximo 50 caracteres):
   - Ejemplos: `v1.0.0-internal`, `1.0.0-beta`, `2024.01.15-internal`
   - Este nombre es solo para tu referencia interna
   - **No es visible para los usuarios** en Google Play
   - Sugerencia: Usa el formato `v[versión]-internal` o `[fecha]-internal`

2. **Notas de la versión** (opcional pero recomendado):
   - Describe los cambios y mejoras de esta versión
   - Ayuda a tu equipo a entender qué se probó
   - Ejemplo:
     ```
     Versión de prueba interna v1.0.0
     - Primera versión de prueba
     - Funcionalidades principales implementadas
     - Pendiente: Validar integración con Firebase
     ```

#### 6.5.4: Solución de Error "Código de Versión Ya Usado"

Si ves el error **"Ya se usó el código de la versión X. Prueba con otro código"**:

**Causa:** Google Play requiere que cada versión tenga un `versionCode` único y mayor que las versiones anteriores.

**Solución:**

1. **Edita `pubspec.yaml`**:
   ```yaml
   version: 1.0.0+3  # Incrementa el número después del +
   ```
   - El formato es: `versionName+versionCode`
   - `1.0.0` = versión visible para usuarios
   - `3` = código interno que debe incrementarse

2. **Regenera el App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

3. **Sube el nuevo archivo** a Google Play Console

**⚠️ Importante:**
- Cada vez que subas una nueva versión, incrementa el `versionCode`
- El `versionCode` debe ser siempre mayor que el anterior
- No puedes reutilizar un `versionCode` que ya fue usado

**Ejemplo de versiones:**
- Primera versión: `1.0.0+1`
- Segunda versión: `1.0.0+2`
- Tercera versión: `1.0.0+3` o `1.0.1+3` (si cambias la versión visible)

#### 6.5.5: Herramientas de Integridad de la App

En la parte superior de la página, verás información sobre:

- **Administrar la protección de la integridad**: Configura App Integrity API para proteger tu app
- **Cambiar clave de firma**: Si necesitas cambiar la clave de firma (solo hazlo si es absolutamente necesario)

**⚠️ Importante:** 
- La protección de integridad ayuda a prevenir modificaciones no autorizadas
- No cambies la clave de firma a menos que sea estrictamente necesario (perderás la capacidad de actualizar versiones anteriores)

#### 6.5.6: Revisar y Guardar

1. Verifica que el paquete se haya subido correctamente
2. Revisa que el nombre de la versión sea descriptivo
3. Haz clic en **"Guardar"** o **"Revisar versión"**

#### 6.5.7: Agregar Testers (Opcional)

Después de crear la versión:

1. Ve a **"Testers"** en la sección de Pruebas Internas
2. Puedes agregar testers por:
   - **Lista de correos**: Agrega direcciones de correo específicas
   - **Grupos de Google**: Usa un grupo de Google existente
   - **Enlace de prueba**: Genera un enlace que cualquiera puede usar (hasta 100 testers)

**✅ Ventajas de las pruebas internas:**
- Pruebas rápidas sin pasar por revisión de Google
- Ideal para validar funcionalidades antes de producción
- Permite iterar rápidamente con feedback del equipo
- No cuenta hacia el límite de actualizaciones de producción

### Paso 6.6: Crear Versión de Producción

1. Ve a "Producción" > "Crear nueva versión"
2. Sube el App Bundle (`.aab`) generado con:
   ```bash
   flutter build appbundle --release
   ```
3. Completa las notas de la versión
4. Revisa y publica

**✅ Archivos necesarios:**
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- Icono: 512x512 px
- Capturas: Mínimo 2 (1080x1920 o 1920x1080)

---

## 6. Optimizaciones Finales

### Paso 8.1: Verificar Tamaño de la App

```bash
# Android
flutter build apk --release --analyze-size

# iOS
flutter build ios --release --analyze-size
```

### Paso 8.2: Habilitar Tree Shaking

Ya está habilitado por defecto en Flutter, pero verifica en `pubspec.yaml` que no tengas imports innecesarios.

### Paso 8.3: Configurar Splash Screen

Asegúrate de tener un splash screen apropiado. Flutter lo maneja automáticamente, pero puedes personalizarlo.

### Paso 8.4: Configurar Iconos de la App

Ya tienes `flutter_launcher_icons.yaml`. Ejecuta:

```bash
flutter pub run flutter_launcher_icons
```

### Paso 8.5: Testing Final

Antes de publicar, prueba:

- ✅ Login/Registro
- ✅ Navegación en el mapa
- ✅ Crear reportes
- ✅ Subir fotos
- ✅ Sistema de favoritos
- ✅ Notificaciones push
- ✅ Modo offline (si aplica)

---

## 7. Checklist Final

### Configuración General
- [ ] Archivo `.env` creado con todas las variables
- [ ] `.env` agregado a `.gitignore`
- [ ] `.env.example` creado para documentación
- [ ] API Key de OpenWeatherMap obtenida y configurada

### Android
- [ ] Keystore creado y guardado de forma segura
- [ ] `key.properties` configurado
- [ ] `build.gradle.kts` actualizado con signing config
- [ ] ProGuard configurado
- [ ] Build de release probado exitosamente
- [ ] App Bundle generado (`.aab`)
- [ ] SHA-1 del keystore obtenido para restricciones de API

### Firebase
- [ ] Reglas de Firestore actualizadas y desplegadas
- [ ] Reglas de Storage actualizadas y desplegadas
- [ ] API Keys restringidas en Google Cloud Console
- [ ] APIs necesarias habilitadas

### Google Play Console
- [ ] Cuenta de desarrollador creada ($25 USD pagado)
- [ ] App creada en Google Play Console
- [ ] Store listing completado:
  - [ ] Título y descripción
  - [ ] Icono (512x512 px)
  - [ ] Capturas de pantalla (mínimo 2)
  - [ ] Categoría seleccionada
- [ ] Política de privacidad publicada (URL pública)
- [ ] Contenido de la app configurado
- [ ] **Versión de prueba interna creada** (recomendado antes de producción):
  - [ ] App Bundle o APK subido a pruebas internas
  - [ ] Nombre de versión asignado (máximo 50 caracteres)
  - [ ] Notas de versión completadas
  - [ ] Testers agregados (opcional)
  - [ ] Versión probada y validada
- [ ] App Bundle subido a producción
- [ ] App enviada para revisión

### Seguridad
- [ ] Todas las API Keys tienen restricciones
- [ ] Reglas de Firebase son seguras
- [ ] No hay información sensible en el código
- [ ] `.env` no está en el repositorio

### Documentación Legal
- [ ] Política de privacidad creada y publicada
- [ ] Términos de servicio creados (si aplica)
- [ ] URLs de políticas agregadas en las stores

---

## 📝 Notas Importantes

### Costos
- **Google Play Developer:** $25 USD (pago único)
- **Firebase:** Gratis hasta cierto límite
- **Google Maps API:** Gratis hasta 28,000 cargas/mes
- **AdMob:** Gratis (ganas dinero con anuncios)

### Tiempo Estimado
- **Configuración básica:** 2-3 horas
- **Configuración completa:** 1-2 días
- **Revisión de Google Play:** 1-7 días

### Recursos Adicionales
- [Guía Completa de Producción Android](./GUIA_PRODUCCION_ANDROID.md)
- [Documentación de Flutter - Android](https://flutter.dev/docs/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Firebase Documentation](https://firebase.google.com/docs)

---

## 🆘 Solución de Problemas Comunes

### Error: "key.properties no encontrado"
- Verifica que el archivo existe en `android/key.properties`
- Verifica que la ruta en el archivo es correcta (absoluta en Windows)

### Error: "Keystore password incorrect"
- Verifica que la contraseña en `key.properties` sea correcta
- Si olvidaste la contraseña, necesitas crear un nuevo keystore (y una nueva app en Play Store)

### Error: "API Key restringida"
- Verifica que las restricciones en Google Cloud Console sean correctas
- Para Android: Package name (`com.playasrd.playasrd`) + SHA-1 del keystore de release
- Verifica que el SHA-1 sea del keystore de release, no del de debug
- Para testing, puedes agregar temporalmente el SHA-1 de debug

---

**¡Éxito con tu publicación! 🎉**


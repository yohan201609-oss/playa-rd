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

**Obtener SHA-1 del keystore:**
```bash
keytool -list -v -keystore ~/playas-rd-release-key.jks -alias playas-rd
```

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

### Paso 6.5: Crear Versión de Producción

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
- [ ] App Bundle subido
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


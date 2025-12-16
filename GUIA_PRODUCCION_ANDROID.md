# 🚀 Guía Completa: Publicar en Google Play Store - Android

**Proyecto:** Playas RD  
**Plataforma:** Android  
**Versión:** 1.0.0+1

---

## 📋 Índice

1. [Configuración del Keystore](#1-configuración-del-keystore)
2. [Configuración de Build para Producción](#2-configuración-de-build-para-producción)
3. [Optimizaciones de Producción](#3-optimizaciones-de-producción)
4. [Seguridad de Firebase](#4-seguridad-de-firebase)
5. [Restricciones de API Keys](#5-restricciones-de-api-keys)
6. [Configuración de Google Play Console](#6-configuración-de-google-play-console)
7. [Generar y Subir el App Bundle](#7-generar-y-subir-el-app-bundle)
8. [Checklist Final](#8-checklist-final)
9. [Solución de Problemas](#9-solución-de-problemas)

---

## 1. Configuración del Keystore

### ⚠️ **PRIORIDAD CRÍTICA**

El keystore es **ESENCIAL** para publicar en Google Play. Si lo pierdes, no podrás actualizar tu app.

### Paso 1.1: Generar el Keystore

**En Windows (PowerShell):**

```powershell
keytool -genkey -v -keystore $env:USERPROFILE\playas-rd-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias playas-rd
```

**En Linux/Mac:**

```bash
keytool -genkey -v -keystore ~/playas-rd-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias playas-rd
```

**Información que te pedirá:**
- **Contraseña del keystore:** ⚠️ **GUÁRDALA EN UN LUGAR SEGURO** (la necesitarás siempre)
- **Contraseña de la clave:** (puede ser la misma que la del keystore)
- **Nombre y apellido:** Tu nombre o nombre de la empresa
- **Unidad organizacional:** (puedes dejarlo vacío o poner tu empresa)
- **Ciudad:** Tu ciudad
- **Estado/Provincia:** Tu estado/provincia
- **Código de país:** DO (para República Dominicana)

### Paso 1.2: Crear archivo `key.properties`

Crea el archivo `android/key.properties` con el siguiente contenido:

```properties
storePassword=tu_contraseña_del_keystore
keyPassword=tu_contraseña_del_keystore
keyAlias=playas-rd
storeFile=C:\\Users\\TuUsuario\\playas-rd-release-key.jks
```

**⚠️ IMPORTANTE:**
- Reemplaza `TuUsuario` con tu nombre de usuario de Windows
- Usa rutas absolutas en Windows (con doble backslash `\\`)
- En Linux/Mac, usa: `storeFile=/home/tuusuario/playas-rd-release-key.jks`
- **NUNCA** subas este archivo al repositorio (ya está en `.gitignore`)

**Ejemplo real en Windows:**
```properties
storePassword=MiPasswordSegura123!
keyPassword=MiPasswordSegura123!
keyAlias=playas-rd
storeFile=C:\\Users\\Juan\\playas-rd-release-key.jks
```

### Paso 1.3: Obtener SHA-1 del Keystore

Necesitarás el SHA-1 para configurar las restricciones de API Keys:

**En Windows (PowerShell):**
```powershell
keytool -list -v -keystore $env:USERPROFILE\playas-rd-release-key.jks -alias playas-rd
```

**En Linux/Mac:**
```bash
keytool -list -v -keystore ~/playas-rd-release-key.jks -alias playas-rd
```

Busca la línea que dice `SHA1:` y copia el valor. Lo necesitarás más adelante.

**Ejemplo de salida:**
```
Alias name: playas-rd
Creation date: 15 ene 2025
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: CN=Tu Nombre, OU=Tu Empresa, L=Tu Ciudad, ST=Tu Estado, C=DO
Issuer: CN=Tu Nombre, OU=Tu Empresa, L=Tu Ciudad, ST=Tu Estado, C=DO
Serial number: 1234567890abcdef
Valid from: Mon Jan 15 10:00:00 AST 2025 until: Thu Jan 15 10:00:00 AST 2055
Certificate fingerprints:
     SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
     SHA256: 12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF
```

**Copia el valor SHA1** (sin los dos puntos): `ABCDEF1234567890ABCDEF1234567890ABCDEF12`

### Paso 1.4: Verificar que `build.gradle.kts` está configurado

El archivo `android/app/build.gradle.kts` ya está configurado para usar el keystore. Verifica que tenga:

```kotlin
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
```

**✅ Estado:** Ya está configurado correctamente.

---

## 2. Configuración de Build para Producción

### Paso 2.1: Verificar ProGuard

El archivo `android/app/proguard-rules.pro` ya está creado con todas las reglas necesarias.

**✅ Estado:** Ya está configurado.

### Paso 2.2: Verificar R8 Full Mode

El archivo `android/gradle.properties` ya tiene:

```properties
android.enableR8.fullMode=true
```

**✅ Estado:** Ya está habilitado.

### Paso 2.3: Verificar Minificación

El archivo `android/app/build.gradle.kts` ya tiene configurado:

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

**✅ Estado:** Ya está configurado.

---

## 3. Optimizaciones de Producción

### Paso 3.1: Verificar Versión

En `pubspec.yaml`, verifica que tengas:

```yaml
version: 1.0.0+1
```

Donde:
- `1.0.0` = versión visible al usuario (versionName)
- `1` = build number (versionCode) - incrementa con cada build

**Para la próxima versión, cambia a:** `1.0.1+2` (o `1.1.0+2` si es una actualización mayor)

### Paso 3.2: Probar Build de Release

**Generar App Bundle (recomendado para Google Play):**

```bash
flutter build appbundle --release
```

El archivo se generará en:
```
build/app/outputs/bundle/release/app-release.aab
```

**O generar APK (para testing):**

```bash
flutter build apk --release
```

El archivo se generará en:
```
build/app/outputs/flutter-apk/app-release.apk
```

**Verificar tamaño:**

```bash
flutter build apk --release --analyze-size
```

---

## 4. Seguridad de Firebase

### Paso 4.1: Verificar Reglas de Firestore

El archivo `firestore.rules` ya está configurado con reglas seguras. Verifica que esté desplegado:

```bash
# Si tienes Firebase CLI instalado
firebase deploy --only firestore:rules
```

**✅ Estado:** Las reglas ya están configuradas correctamente.

### Paso 4.2: Verificar Reglas de Storage

El archivo `storage.rules` ya está configurado con límites de tamaño y permisos adecuados.

```bash
# Desplegar reglas de Storage
firebase deploy --only storage:rules
```

**✅ Estado:** Las reglas ya están configuradas correctamente.

---

## 5. Restricciones de API Keys

### ⚠️ **PRIORIDAD ALTA**

### Paso 5.1: Restringir Google Maps API Key

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Credentials**
4. Busca tu API Key de Google Maps (la que está configurada en AndroidManifest)
5. Haz clic en el nombre de la API Key para editarla
6. En **Application restrictions**:
   - Selecciona **Android apps**
   - Haz clic en **+ Add an item**
   - **Package name:** `com.playasrd.playasrd`
   - **SHA-1 certificate fingerprint:** Pega el SHA-1 que obtuviste en el Paso 1.3
7. En **API restrictions**:
   - Selecciona **Restrict key**
   - Marca solo estas APIs:
     - ✅ Maps SDK for Android
     - ✅ Geocoding API
     - ✅ Places API (si la usas)
8. Haz clic en **Save**

### Paso 5.2: Restringir Firebase API Key para Android

1. En la misma página de Credentials
2. Busca la API Key de Firebase para Android: `AIzaSyDFS0POsHWn9azaDIAviZM8FlUSjf8_fVs`
3. Edita la API Key
4. En **Application restrictions**:
   - Selecciona **Android apps**
   - **Package name:** `com.playasrd.playasrd`
   - **SHA-1:** El mismo SHA-1 del keystore de release
5. En **API restrictions**:
   - Selecciona **Restrict key**
   - Marca las APIs de Firebase que uses
6. Guarda los cambios

### Paso 5.3: Verificar APIs Habilitadas

Asegúrate de que estas APIs estén habilitadas en Google Cloud Console:

1. Ve a **APIs & Services** > **Library**
2. Busca y habilita:
   - ✅ Maps SDK for Android
   - ✅ Geocoding API
   - ✅ Places API (opcional)
   - ✅ Firebase Cloud Messaging API
   - ✅ Firebase Authentication API

---

## 6. Configuración de Google Play Console

### Paso 6.1: Crear Cuenta de Desarrollador

1. Ve a [Google Play Console](https://play.google.com/console)
2. Si no tienes cuenta, crea una cuenta de Google
3. Paga la tarifa única de **$25 USD** (pago único, no anual)
4. Completa el perfil de desarrollador:
   - Nombre del desarrollador
   - Email de contacto
   - Teléfono
   - Dirección

### Paso 6.2: Crear la Aplicación

1. En Google Play Console, haz clic en **Crear aplicación**
2. Completa la información:
   - **Nombre de la app:** Playas RD
   - **Idioma predeterminado:** Español
   - **Tipo de app:** Aplicación
   - **Gratis o de pago:** Gratis
   - **Declaración de exportación:** Marca si aplica
3. Acepta la Declaración de exportación de Estados Unidos (si aplica)
4. Haz clic en **Crear aplicación**

### Paso 6.3: Configurar Store Listing

Completa toda la información en **Store listing**:

**Información básica:**
- **Título:** Playas RD (máximo 50 caracteres)
- **Descripción corta:** Descubre las mejores playas de República Dominicana (máximo 80 caracteres)
- **Descripción completa:** 
  ```
  Playas RD es tu guía completa para descubrir las mejores playas de República Dominicana.
  
  Características:
  • Explora más de 100 playas hermosas
  • Información detallada de cada playa
  • Mapa interactivo con ubicaciones
  • Reporta condiciones de las playas
  • Sistema de favoritos
  • Notificaciones sobre condiciones del mar
  
  Descubre playas paradisíacas, desde las famosas playas de Punta Cana hasta tesoros escondidos en toda la isla.
  ```

**Gráficos:**
- **Icono:** 512x512 px (PNG, sin transparencia)
- **Capturas de pantalla:** Mínimo 2, máximo 8
  - Teléfono: 1080x1920 px o 1920x1080 px
  - Tableta (opcional): 1200x1920 px o 1920x1200 px

**Categorización:**
- **Tipo de app:** Aplicación
- **Categoría:** Viajes y guías locales
- **Etiquetas:** playas, turismo, república dominicana, viajes

**Contacto:**
- **Email:** Tu email de contacto
- **Teléfono:** (opcional)
- **Sitio web:** (si tienes)

**Política de privacidad:**
- **URL:** Debe ser una URL pública
- Puedes usar GitHub Pages, Firebase Hosting, o cualquier hosting gratuito
- El archivo `docs/politica_privacidad.md` puede servir como base

### Paso 6.4: Configurar Contenido de la App

1. Ve a **Contenido de la app**
2. Completa el cuestionario de clasificación de contenido
3. Selecciona el objetivo de la app y público objetivo
4. Marca si la app está dirigida a niños (probablemente NO para esta app)

### Paso 6.5: Configurar Precios y Distribución

1. Ve a **Precios y distribución**
2. Selecciona **Gratis**
3. Selecciona los países donde quieres distribuir (o todos)
4. Acepta los acuerdos de distribución

---

## 7. Generar y Subir el App Bundle

### Paso 7.1: Generar el App Bundle

```bash
flutter build appbundle --release
```

**Verifica que el build fue exitoso:**
- Debe generar: `build/app/outputs/bundle/release/app-release.aab`
- El tamaño debería ser entre 20-50 MB aproximadamente

### Paso 7.2: Subir a Google Play Console

1. En Google Play Console, ve a tu app
2. En el menú lateral, ve a **Producción** (o **Versión de prueba** para testing)
3. Haz clic en **Crear nueva versión**
4. Completa:
   - **Nombre de la versión:** 1.0.0 (debe coincidir con `pubspec.yaml`)
   - **Notas de la versión:**
     ```
     Primera versión de Playas RD
     
     • Explora más de 100 playas de República Dominicana
     • Mapa interactivo con ubicaciones
     • Sistema de reportes de condiciones
     • Favoritos y notificaciones
     ```
5. Haz clic en **Subir** y selecciona el archivo `app-release.aab`
6. Espera a que se procese (puede tardar unos minutos)

### Paso 7.3: Revisar y Publicar

1. Una vez procesado, revisa toda la información
2. Verifica que no haya errores o advertencias
3. Haz clic en **Revisar versión**
4. Si todo está correcto, haz clic en **Iniciar publicación en producción**

**⏱️ Tiempo de revisión:**
- Google Play típicamente revisa apps en 1-7 días
- Puedes recibir notificaciones si hay problemas

---

## 8. Checklist Final

### Configuración Técnica
- [ ] Keystore creado y guardado de forma segura
- [ ] Archivo `android/key.properties` creado con rutas correctas
- [ ] SHA-1 del keystore obtenido y copiado
- [ ] Build de release probado exitosamente
- [ ] App Bundle generado (`app-release.aab`)
- [ ] Tamaño del bundle verificado (razonable)

### Seguridad
- [ ] Reglas de Firestore desplegadas
- [ ] Reglas de Storage desplegadas
- [ ] Google Maps API Key restringida (package name + SHA-1)
- [ ] Firebase API Key restringida (package name + SHA-1)
- [ ] APIs necesarias habilitadas en Google Cloud Console

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
- [ ] Precios y distribución configurados

### App Bundle
- [ ] App Bundle subido a Google Play Console
- [ ] Notas de la versión completadas
- [ ] Versión revisada y sin errores
- [ ] App enviada para revisión

### Testing (Antes de Publicar)
- [ ] Login/Registro funciona
- [ ] Mapa carga correctamente
- [ ] Navegación funciona
- [ ] Crear reportes funciona
- [ ] Subir fotos funciona
- [ ] Sistema de favoritos funciona
- [ ] Notificaciones funcionan
- [ ] Anuncios se muestran correctamente

---

## 9. Solución de Problemas

### Error: "key.properties no encontrado"

**Solución:**
- Verifica que el archivo existe en `android/key.properties`
- Verifica que la ruta en el archivo es correcta (absoluta en Windows)
- En Windows, usa doble backslash: `C:\\Users\\...`

### Error: "Keystore password incorrect"

**Solución:**
- Verifica que la contraseña en `key.properties` sea correcta
- Si olvidaste la contraseña, necesitas crear un nuevo keystore
- ⚠️ Si ya publicaste la app, no puedes cambiar el keystore

### Error: "API Key restringida"

**Solución:**
- Verifica que el package name sea correcto: `com.playasrd.playasrd`
- Verifica que el SHA-1 sea el del keystore de release (no el de debug)
- Para testing, puedes agregar el SHA-1 de debug temporalmente

### Error al subir App Bundle

**Solución:**
- Verifica que la versión en `pubspec.yaml` sea mayor que cualquier versión anterior
- Verifica que el bundle esté firmado correctamente
- Verifica que no haya errores en el build

### La app es rechazada por Google Play

**Causas comunes:**
- Política de privacidad faltante o incorrecta
- Permisos no justificados
- Contenido inapropiado
- Violación de políticas de anuncios

**Solución:**
- Revisa el email de Google Play Console para ver la razón específica
- Corrige los problemas mencionados
- Responde a través de Google Play Console

---

## 📝 Notas Importantes

### Seguridad del Keystore

- ⚠️ **GUARDA EL KEYSTORE EN UN LUGAR SEGURO**
- ⚠️ Si pierdes el keystore, NO podrás actualizar tu app en Google Play
- ⚠️ Considera usar un gestor de contraseñas para guardar las credenciales
- ⚠️ Haz backup del keystore en múltiples ubicaciones seguras
- ⚠️ Considera guardar una copia en la nube (encriptada) o en un USB seguro

### Actualizaciones Futuras

Para cada nueva versión:
1. Incrementa el `versionCode` en `pubspec.yaml` (el número después del `+`)
2. Actualiza el `versionName` si es necesario
3. Genera nuevo App Bundle: `flutter build appbundle --release`
4. Sube a Google Play Console en la misma versión de producción

**Ejemplo:**
- Versión 1: `1.0.0+1`
- Versión 2: `1.0.1+2` (parche)
- Versión 3: `1.1.0+3` (nueva funcionalidad)

### Costos

- **Google Play Developer:** $25 USD (pago único)
- **Firebase:** Gratis hasta cierto límite (suficiente para empezar)
- **Google Maps API:** Gratis hasta 28,000 cargas de mapa/mes
- **AdMob:** Gratis (ganas dinero con anuncios)

---

## 🎯 Próximos Pasos Después de Publicar

1. **Monitorear métricas** en Google Play Console
2. **Responder a reseñas** de usuarios
3. **Actualizar la app** regularmente con mejoras
4. **Analizar crash reports** en Firebase Crashlytics
5. **Optimizar** basado en feedback de usuarios

---

## 📚 Recursos Adicionales

- [Documentación de Flutter - Android](https://flutter.dev/docs/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps API Documentation](https://developers.google.com/maps/documentation)

---

**¡Éxito con tu publicación en Google Play! 🎉**

**Última actualización:** $(date)


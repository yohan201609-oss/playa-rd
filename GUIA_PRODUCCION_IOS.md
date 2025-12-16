# 🍎 Guía Completa: Publicar en App Store - iOS

**Proyecto:** Playas RD  
**Plataforma:** iOS  
**Versión:** 1.0.1+4

---

## 📋 Índice

1. [Requisitos Previos](#1-requisitos-previos)
2. [Configuración Inicial del Proyecto](#2-configuración-inicial-del-proyecto)
3. [Configuración de Certificados y Perfiles](#3-configuración-de-certificados-y-perfiles)
4. [Configuración de Xcode](#4-configuración-de-xcode)
5. [Configuración de Firebase para iOS](#5-configuración-de-firebase-para-ios)
6. [Configuración de Google Sign-In](#6-configuración-de-google-sign-in)
7. [Configuración de Google Maps](#7-configuración-de-google-maps)
8. [Configuración de AdMob](#8-configuración-de-admob)
9. [Configuración de Permisos](#9-configuración-de-permisos)
10. [Build y Pruebas](#10-build-y-pruebas)
11. [Configuración de App Store Connect](#11-configuración-de-app-store-connect)
12. [Subir la App a App Store](#12-subir-la-app-a-app-store)
13. [Checklist Final](#13-checklist-final)
14. [Solución de Problemas](#14-solución-de-problemas)

---

## 1. Requisitos Previos

### ⚠️ **IMPORTANTE: Necesitas una Mac**

iOS solo se puede desarrollar y publicar desde una Mac con macOS.

### Paso 1.1: Software Necesario

1. **macOS** (versión 12.0 o superior recomendada)
2. **Xcode** (última versión desde Mac App Store)
   - Descarga desde: [Mac App Store - Xcode](https://apps.apple.com/app/xcode/id497799835)
   - Tamaño: ~15 GB (asegúrate de tener espacio)
   - Incluye iOS Simulator y todas las herramientas necesarias
3. **Flutter** (ya instalado en tu proyecto)
4. **CocoaPods** (gestor de dependencias para iOS)
   ```bash
   sudo gem install cocoapods
   ```

### Paso 1.2: Cuenta de Desarrollador de Apple

1. **Cuenta de Apple ID** (gratis)
   - Necesaria para probar en dispositivos físicos
   - Crea una en: [appleid.apple.com](https://appleid.apple.com)

2. **Programa de Desarrollador de Apple** ($99 USD/año)
   - Necesario para publicar en App Store
   - Inscríbete en: [developer.apple.com/programs](https://developer.apple.com/programs)
   - Proceso de aprobación: 24-48 horas típicamente

### Paso 1.3: Verificar Instalación

```bash
# Verificar Flutter
flutter doctor

# Verificar Xcode
xcode-select --print-path

# Verificar CocoaPods
pod --version
```

**Salida esperada de `flutter doctor`:**
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Xcode - develop for iOS and macOS
[✓] CocoaPods version 1.x.x
```

---

## 2. Configuración Inicial del Proyecto

### Paso 2.1: Verificar Bundle Identifier

El Bundle ID debe ser único y seguir el formato: `com.tuempresa.tuapp`

**Bundle ID actual del proyecto:**
- **Configurado:** `com.playasrd.playasrd`
- **En Xcode:** `com.playasrd.playasRdFlutter` (necesita actualización)

**Ubicación:** `ios/Runner.xcodeproj/project.pbxproj`

### Paso 2.2: Actualizar Bundle Identifier en Xcode

1. Abre el proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ **IMPORTANTE:** Abre el `.xcworkspace`, NO el `.xcodeproj`

2. En Xcode:
   - Selecciona el proyecto **Runner** en el navegador izquierdo
   - Selecciona el target **Runner**
   - Ve a la pestaña **General**
   - En **Identity**, cambia **Bundle Identifier** a: `com.playasrd.playasrd`
   - Presiona **Enter** y confirma los cambios

### Paso 2.3: Verificar Versión

En `pubspec.yaml`, verifica:
```yaml
version: 1.0.1+4
```

Donde:
- `1.0.1` = versión visible al usuario (CFBundleShortVersionString)
- `4` = build number (CFBundleVersion) - incrementa con cada build

---

## 3. Configuración de Certificados y Perfiles

### ⚠️ **PRIORIDAD CRÍTICA**

Los certificados y perfiles son esenciales para firmar y publicar tu app.

### Paso 3.1: Acceder a Apple Developer Portal

1. Ve a [developer.apple.com/account](https://developer.apple.com/account)
2. Inicia sesión con tu cuenta de desarrollador
3. Ve a **Certificates, Identifiers & Profiles**

### Paso 3.2: Registrar App ID

1. En el menú lateral, ve a **Identifiers**
2. Haz clic en el botón **+** (arriba a la izquierda)
3. Selecciona **App IDs** y haz clic en **Continue**
4. Selecciona **App** y haz clic en **Continue**
5. Completa:
   - **Description:** Playas RD
   - **Bundle ID:** Selecciona **Explicit** y escribe: `com.playasrd.playasrd`
6. En **Capabilities**, marca:
   - ✅ **Push Notifications** (para Firebase Cloud Messaging)
   - ✅ **Sign in with Apple** (opcional, si lo usas)
   - ✅ **Associated Domains** (si usas deep links)
7. Haz clic en **Continue** y luego en **Register**

### Paso 3.3: Crear Certificado de Distribución

1. Ve a **Certificates**
2. Haz clic en el botón **+**
3. Selecciona **iOS App Development** (para desarrollo) o **Apple Distribution** (para App Store)
4. Haz clic en **Continue**
5. Sigue las instrucciones para crear un **Certificate Signing Request (CSR)**:
   - Abre **Keychain Access** en tu Mac
   - Ve a **Keychain Access** > **Certificate Assistant** > **Request a Certificate from a Certificate Authority**
   - Ingresa tu email y nombre
   - Selecciona **Saved to disk**
   - Guarda el archivo `.certSigningRequest`
6. Sube el archivo CSR en el portal de Apple
7. Descarga el certificado y haz doble clic para instalarlo en Keychain

### Paso 3.4: Crear Perfil de Provisioning

1. Ve a **Profiles**
2. Haz clic en el botón **+**
3. Selecciona **App Store** (para publicación) o **Development** (para pruebas)
4. Selecciona el **App ID** que creaste (`com.playasrd.playasrd`)
5. Selecciona el **Certificado** que creaste
6. Si es Development, selecciona los dispositivos donde probarás
7. Dale un nombre al perfil (ej: "Playas RD App Store")
8. Haz clic en **Generate**
9. Descarga el perfil y haz doble clic para instalarlo

### Paso 3.5: Configurar Xcode para Usar el Perfil

1. Abre `ios/Runner.xcworkspace` en Xcode
2. Selecciona el proyecto **Runner**
3. Selecciona el target **Runner**
4. Ve a la pestaña **Signing & Capabilities**
5. Marca **Automatically manage signing**
6. Selecciona tu **Team** (tu cuenta de desarrollador)
7. Xcode debería detectar automáticamente el perfil correcto

**Si prefieres gestión manual:**
- Desmarca **Automatically manage signing**
- Selecciona el **Provisioning Profile** que descargaste

---

## 4. Configuración de Xcode

### Paso 4.1: Configurar Deployment Target

1. En Xcode, selecciona el proyecto **Runner**
2. Selecciona el target **Runner**
3. Ve a la pestaña **General**
4. En **Deployment Info**, selecciona:
   - **iOS:** 12.0 o superior (recomendado 13.0+)
   - Esto debe coincidir con `ios/Podfile` (verifica `platform :ios, '13.0'`)

### Paso 4.2: Verificar Configuración de Build

1. Ve a la pestaña **Build Settings**
2. Busca **Code Signing Identity**:
   - **Debug:** iOS Developer
   - **Release:** Apple Distribution
3. Busca **Provisioning Profile**:
   - Debe coincidir con el perfil que creaste

### Paso 4.3: Configurar Capabilities

En la pestaña **Signing & Capabilities**, verifica que estén habilitadas:

- ✅ **Push Notifications** (para Firebase)
- ✅ **Background Modes** (para notificaciones)
- ✅ **Maps** (si usas mapas nativos)

---

## 5. Configuración de Firebase para iOS

### Paso 5.1: Verificar GoogleService-Info.plist

El archivo `ios/Runner/GoogleService-Info.plist` ya está configurado.

**Verifica que contenga:**
- ✅ `BUNDLE_ID`: `com.playasrd.playasrd`
- ✅ `PROJECT_ID`: `playas-rd-2b475`
- ✅ `API_KEY`: Configurado
- ✅ `GOOGLE_APP_ID`: Configurado

### Paso 5.2: Configurar Firebase en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **Project Settings** (ícono de engranaje)
4. En la pestaña **General**, verifica que la app iOS esté registrada:
   - **Bundle ID:** `com.playasrd.playasrd`
   - **App ID:** `1:360714035813:ios:e7b023b9692d3d09629c8c`

### Paso 5.3: Configurar Push Notifications

1. En Firebase Console, ve a **Project Settings** > **Cloud Messaging**
2. En **Apple app configuration**, sube tu **APNs Authentication Key**:
   - Ve a [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
   - Crea una nueva **Key** con permisos de **Apple Push Notifications service (APNs)**
   - Descarga el archivo `.p8`
   - Súbelo en Firebase Console
   - Ingresa el **Key ID** y **Team ID**

**Alternativa (más antigua):**
- Usa un **APNs Certificate** en lugar de la Key

### Paso 5.4: Instalar Dependencias de CocoaPods

```bash
cd ios
pod install
cd ..
```

**Si hay errores:**
```bash
# Limpiar y reinstalar
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

---

## 6. Configuración de Google Sign-In

### Paso 6.1: Verificar URL Scheme

El `REVERSED_CLIENT_ID` del `GoogleService-Info.plist` debe estar en `Info.plist`.

**Verifica en `ios/Runner/Info.plist`:**

Agrega (si no está):
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.360714035813-j1q7j0elbuep49uurma34kkofh9v27i5</string>
        </array>
    </dict>
</array>
```

Este valor debe ser el `REVERSED_CLIENT_ID` de tu `GoogleService-Info.plist`.

### Paso 6.2: Configurar OAuth Client en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Credentials**
4. Busca el **OAuth 2.0 Client ID** para iOS:
   - **Client ID:** `360714035813-j1q7j0elbuep49uurma34kkofh9v27i5`
5. Verifica que el **Bundle ID** sea: `com.playasrd.playasrd`

### Paso 6.3: Configurar URL de Redirección

En el OAuth Client de iOS, verifica que tenga configurado:
- **Bundle ID:** `com.playasrd.playasrd`

---

## 7. Configuración de Google Maps

### Paso 7.1: Obtener API Key de Google Maps para iOS

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Credentials**
4. Crea una nueva **API Key** o usa una existente
5. Configura restricciones:
   - **Application restrictions:** iOS apps
   - **Bundle ID:** `com.playasrd.playasrd`
   - **API restrictions:** Restrict key
   - Marca: ✅ Maps SDK for iOS
   - Marca: ✅ Geocoding API

### Paso 7.2: Agregar API Key en AppDelegate.swift

Abre `ios/Runner/AppDelegate.swift` y agrega:

```swift
import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("TU_API_KEY_DE_GOOGLE_MAPS_IOS")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Reemplaza** `TU_API_KEY_DE_GOOGLE_MAPS_IOS` con tu API Key real.

### Paso 7.3: Habilitar APIs en Google Cloud Console

Asegúrate de que estas APIs estén habilitadas:
- ✅ Maps SDK for iOS
- ✅ Geocoding API
- ✅ Places API (si la usas)

---

## 8. Configuración de AdMob

### Paso 8.1: Verificar App ID de AdMob

En `ios/Runner/Info.plist`, verifica que esté configurado:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-2612958934827252~9650417470</string>
```

**✅ Estado:** Ya está configurado.

### Paso 8.2: Configurar AdMob en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **Grow** > **AdMob**
4. Vincula tu cuenta de AdMob (o créala si no tienes)
5. Registra la app iOS con el Bundle ID: `com.playasrd.playasrd`

---

## 9. Configuración de Permisos

### Paso 9.1: Verificar Permisos en Info.plist

El archivo `ios/Runner/Info.plist` ya tiene los permisos configurados:

**✅ Permisos configurados:**
- ✅ **Cámara** (`NSCameraUsageDescription`)
- ✅ **Galería** (`NSPhotoLibraryUsageDescription`)
- ✅ **Ubicación cuando está en uso** (`NSLocationWhenInUseUsageDescription`)
- ✅ **Ubicación siempre** (`NSLocationAlwaysUsageDescription`)
- ✅ **Notificaciones push** (`UIBackgroundModes`)

**Verifica que las descripciones sean claras y en español:**
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para tomar fotos de las playas</string>
```

### Paso 9.2: Agregar Permisos Adicionales (si es necesario)

Si necesitas otros permisos, agrégalos en `Info.plist`:

```xml
<!-- Para acceso a contactos (si lo necesitas) -->
<key>NSContactsUsageDescription</key>
<string>Descripción de por qué necesitas acceso a contactos</string>
```

---

## 10. Build y Pruebas

### Paso 10.1: Limpiar el Proyecto

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Paso 10.2: Probar en Simulador

```bash
# Listar simuladores disponibles
xcrun simctl list devices

# Ejecutar en simulador
flutter run -d ios
```

### Paso 10.3: Probar en Dispositivo Físico

1. Conecta tu iPhone/iPad a la Mac
2. En el dispositivo, ve a **Settings** > **General** > **VPN & Device Management**
3. Confía en tu certificado de desarrollador
4. En Xcode, selecciona tu dispositivo como destino
5. Ejecuta:
   ```bash
   flutter run -d <device-id>
   ```

### Paso 10.4: Build de Release

**Para App Store:**
```bash
flutter build ios --release
```

**Para Ad Hoc Distribution (testing):**
```bash
flutter build ios --release --no-codesign
```

El build se generará en: `build/ios/iphoneos/Runner.app`

---

## 11. Configuración de App Store Connect

### Paso 11.1: Crear la App en App Store Connect

1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Inicia sesión con tu cuenta de desarrollador
3. Haz clic en **My Apps** > **+** (crear nueva app)
4. Completa:
   - **Platform:** iOS
   - **Name:** Playas RD
   - **Primary Language:** Spanish
   - **Bundle ID:** `com.playasrd.playasrd` (selecciona el que registraste)
   - **SKU:** `playas-rd-ios` (identificador único, no visible a usuarios)
5. Haz clic en **Create**

### Paso 11.2: Configurar Información de la App

**1. App Information:**
- **Category:** Travel
- **Subcategory:** (opcional)
- **Privacy Policy URL:** URL pública de tu política de privacidad

**2. Pricing and Availability:**
- **Price:** Free
- **Availability:** Todos los países (o selecciona específicos)

**3. App Privacy:**
- Completa el cuestionario de privacidad
- Indica qué datos recopilas y cómo los usas
- Basado en tu app, probablemente recopilas:
  - Ubicación
  - Fotos
  - Información de cuenta (Firebase Auth)

### Paso 11.3: Preparar Assets para Store Listing

**Icono de la App:**
- Tamaño: 1024x1024 px
- Formato: PNG o JPEG
- Sin transparencia
- Sin bordes redondeados (Apple los agrega automáticamente)

**Capturas de Pantalla:**
- **iPhone 6.7" (iPhone 14 Pro Max):** 1290x2796 px
- **iPhone 6.5" (iPhone 11 Pro Max):** 1242x2688 px
- **iPhone 5.5" (iPhone 8 Plus):** 1242x2208 px
- Mínimo: 1 captura por tamaño
- Máximo: 10 capturas por tamaño
- Formato: PNG o JPEG

**Descripción:**
- **Nombre:** Playas RD (máximo 30 caracteres)
- **Subtítulo:** Descubre las mejores playas (máximo 30 caracteres)
- **Descripción:** 
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
- **Palabras clave:** playas, turismo, república dominicana, viajes, beach (máximo 100 caracteres, separadas por comas)

**Información de Soporte:**
- **URL de Marketing:** (opcional) URL de tu sitio web
- **URL de Soporte:** URL donde los usuarios pueden obtener ayuda
- **Email de Marketing:** Tu email de contacto

---

## 12. Subir la App a App Store

### Paso 12.1: Archivar la App en Xcode

1. Abre `ios/Runner.xcworkspace` en Xcode
2. Selecciona **Any iOS Device** como destino (no un simulador)
3. Ve a **Product** > **Archive**
4. Espera a que termine el proceso (puede tardar varios minutos)

### Paso 12.2: Subir desde Xcode Organizer

1. Una vez archivado, se abrirá **Organizer**
2. Selecciona el archive que acabas de crear
3. Haz clic en **Distribute App**
4. Selecciona **App Store Connect**
5. Haz clic en **Next**
6. Selecciona **Upload**
7. Selecciona las opciones:
   - ✅ **Include bitcode** (si está disponible)
   - ✅ **Upload your app's symbols** (para crash reports)
8. Selecciona tu equipo de distribución
9. Haz clic en **Upload**
10. Espera a que termine la subida

### Paso 12.3: Subir desde Terminal (Alternativa)

```bash
# Build y archivar
flutter build ios --release

# Subir usando xcodebuild (más avanzado)
cd ios
xcodebuild -workspace Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -archivePath build/Runner.xcarchive \
           archive

# Exportar y subir (requiere configuración adicional)
```

### Paso 12.4: Configurar Versión en App Store Connect

1. Ve a App Store Connect
2. Selecciona tu app **Playas RD**
3. Ve a la pestaña **App Store**
4. En **1.0 Prepare for Submission**, completa:
   - **Version:** 1.0.1 (debe coincidir con `pubspec.yaml`)
   - **Build:** Selecciona el build que subiste
   - **What's New in This Version:** Notas de la versión

**Ejemplo de notas de versión:**
```
Primera versión de Playas RD

• Explora más de 100 playas de República Dominicana
• Mapa interactivo con ubicaciones
• Sistema de reportes de condiciones
• Favoritos y notificaciones
```

### Paso 12.5: Completar Información de Revisión

1. **App Review Information:**
   - **Contact Information:** Tu información de contacto
   - **Phone Number:** Tu teléfono
   - **Demo Account:** (opcional) Cuenta de prueba si tu app requiere login
   - **Notes:** Información adicional para los revisores

2. **Version Information:**
   - Completa todos los campos requeridos
   - Sube las capturas de pantalla
   - Agrega el icono de la app

3. **Advertising Identifier (IDFA):**
   - Si usas AdMob, marca **Yes**
   - Completa el cuestionario sobre el uso de IDFA

### Paso 12.6: Enviar para Revisión

1. Revisa toda la información
2. Verifica que no haya errores o advertencias
3. Haz clic en **Submit for Review**
4. Confirma el envío

**⏱️ Tiempo de revisión:**
- Apple típicamente revisa apps en 24-48 horas
- Puedes recibir notificaciones si hay problemas
- El estado aparecerá en App Store Connect

---

## 13. Checklist Final

### Configuración Técnica
- [ ] macOS y Xcode instalados y actualizados
- [ ] Cuenta de desarrollador de Apple activa ($99 USD/año)
- [ ] Bundle ID registrado en Apple Developer Portal
- [ ] Certificado de distribución creado e instalado
- [ ] Perfil de provisioning creado e instalado
- [ ] Xcode configurado con signing automático o manual
- [ ] Deployment target configurado (iOS 13.0+)
- [ ] CocoaPods instalado y dependencias actualizadas

### Firebase
- [ ] `GoogleService-Info.plist` configurado correctamente
- [ ] App iOS registrada en Firebase Console
- [ ] APNs Authentication Key configurada en Firebase
- [ ] Push notifications configuradas
- [ ] Firebase dependencies instaladas (`pod install`)

### Google Services
- [ ] Google Sign-In configurado (URL Scheme en Info.plist)
- [ ] OAuth Client ID configurado en Google Cloud Console
- [ ] Google Maps API Key configurada en AppDelegate.swift
- [ ] APIs de Google Maps habilitadas en Google Cloud Console
- [ ] Restricciones de API Keys configuradas (Bundle ID)

### AdMob
- [ ] App ID de AdMob configurado en Info.plist
- [ ] App registrada en AdMob/Firebase
- [ ] IDFA configurado correctamente (si aplica)

### Permisos
- [ ] Todos los permisos configurados en Info.plist
- [ ] Descripciones de permisos en español y claras
- [ ] Background modes configurados (notificaciones)

### Build y Testing
- [ ] Build de release exitoso (`flutter build ios --release`)
- [ ] App probada en simulador
- [ ] App probada en dispositivo físico
- [ ] Todas las funcionalidades probadas:
  - [ ] Login/Registro
  - [ ] Mapa carga correctamente
  - [ ] Navegación funciona
  - [ ] Crear reportes funciona
  - [ ] Subir fotos funciona
  - [ ] Sistema de favoritos funciona
  - [ ] Notificaciones funcionan
  - [ ] Anuncios se muestran correctamente

### App Store Connect
- [ ] App creada en App Store Connect
- [ ] Información de la app completada
- [ ] Categoría y pricing configurados
- [ ] App Privacy completado
- [ ] Store listing completado:
  - [ ] Icono (1024x1024 px)
  - [ ] Capturas de pantalla (mínimo 1 por tamaño)
  - [ ] Descripción y palabras clave
  - [ ] URL de política de privacidad
- [ ] Versión y build configurados
- [ ] App enviada para revisión

---

## 14. Solución de Problemas

### Error: "No signing certificate found"

**Solución:**
- Verifica que tengas una cuenta de desarrollador activa
- En Xcode, ve a **Preferences** > **Accounts**
- Agrega tu cuenta de Apple ID
- Selecciona tu **Team** en Signing & Capabilities

### Error: "Provisioning profile doesn't match"

**Solución:**
- Verifica que el Bundle ID en Xcode coincida con el del perfil
- Verifica que el perfil esté instalado (doble clic en el archivo `.mobileprovision`)
- En Xcode, intenta **Download Manual Profiles** en Signing & Capabilities

### Error: "CocoaPods not found"

**Solución:**
```bash
sudo gem install cocoapods
cd ios
pod install
```

### Error: "GoogleService-Info.plist not found"

**Solución:**
- Verifica que el archivo esté en `ios/Runner/GoogleService-Info.plist`
- Verifica que esté agregado al proyecto en Xcode (debe aparecer en el navegador)

### Error: "API Key not valid"

**Solución:**
- Verifica que la API Key esté correcta en `AppDelegate.swift`
- Verifica que las APIs estén habilitadas en Google Cloud Console
- Verifica que las restricciones de la API Key permitan tu Bundle ID

### Error: "Push notifications not working"

**Solución:**
- Verifica que Push Notifications esté habilitado en Capabilities
- Verifica que APNs Authentication Key esté configurada en Firebase
- Verifica que el dispositivo tenga permisos de notificaciones

### Error al subir a App Store: "Invalid Bundle"

**Solución:**
- Verifica que el Bundle ID coincida exactamente con el de App Store Connect
- Verifica que la versión y build number sean únicos
- Verifica que el app esté firmado correctamente

### La app es rechazada por Apple

**Causas comunes:**
- Política de privacidad faltante o incorrecta
- Permisos no justificados en Info.plist
- Contenido inapropiado
- Violación de guías de diseño de Apple
- Problemas con anuncios (si usas AdMob)

**Solución:**
- Revisa el email de App Store Connect para ver la razón específica
- Lee las [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Corrige los problemas mencionados
- Responde a través de App Store Connect

### Error: "Bitcode is deprecated"

**Solución:**
- Desde Xcode 14, Bitcode está deprecado
- No es necesario habilitarlo
- Si aparece el error, simplemente ignóralo o desmárcalo

---

## 📝 Notas Importantes

### Actualizaciones Futuras

Para cada nueva versión:
1. Incrementa el `build number` en `pubspec.yaml` (el número después del `+`)
2. Actualiza el `version name` si es necesario
3. Archiva y sube la nueva versión desde Xcode
4. En App Store Connect, crea una nueva versión y selecciona el nuevo build

**Ejemplo:**
- Versión 1: `1.0.1+4`
- Versión 2: `1.0.2+5` (parche)
- Versión 3: `1.1.0+6` (nueva funcionalidad)

### Costos

- **Apple Developer Program:** $99 USD/año
- **Firebase:** Gratis hasta cierto límite (suficiente para empezar)
- **Google Maps API:** Gratis hasta 28,000 cargas de mapa/mes
- **AdMob:** Gratis (ganas dinero con anuncios)

### Requisitos de Hardware

- **Mac:** Necesario para desarrollar y publicar iOS
- **Dispositivo iOS:** Recomendado para pruebas reales (opcional, puedes usar simulador)

### TestFlight (Beta Testing)

Antes de publicar, puedes usar TestFlight para pruebas:
1. En App Store Connect, ve a **TestFlight**
2. Agrega testers internos o externos
3. Sube un build (igual que para App Store)
4. Los testers recibirán un email con instrucciones

---

## 🎯 Próximos Pasos Después de Publicar

1. **Monitorear métricas** en App Store Connect
2. **Responder a reseñas** de usuarios
3. **Actualizar la app** regularmente con mejoras
4. **Analizar crash reports** en Firebase Crashlytics
5. **Optimizar** basado en feedback de usuarios
6. **Mantener actualizado** con nuevas versiones de iOS

---

## 📚 Recursos Adicionales

- [Documentación de Flutter - iOS](https://docs.flutter.dev/deployment/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps iOS SDK](https://developers.google.com/maps/documentation/ios-sdk)
- [CocoaPods Documentation](https://guides.cocoapods.org/)

---

## 🔗 Enlaces Rápidos

- [Apple Developer Portal](https://developer.apple.com/account)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Firebase Console](https://console.firebase.google.com)
- [Google Cloud Console](https://console.cloud.google.com)
- [AdMob Console](https://apps.admob.com)

---

**¡Éxito con tu publicación en App Store! 🎉**

**Última actualización:** Enero 2025



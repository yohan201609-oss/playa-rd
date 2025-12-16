# 🍎 Configuración de Xcode para Producción - iOS

**Proyecto:** Playas RD  
**Bundle ID:** `com.playasrd.playasrd`  
**Versión:** 1.0.1+4

---

## 📋 Checklist Rápido

- [ ] Abrir el workspace correcto (`.xcworkspace`)
- [ ] Configurar Bundle Identifier
- [ ] Configurar Signing & Capabilities
- [ ] Seleccionar Team de desarrollo
- [ ] Configurar Deployment Target
- [ ] Verificar Build Configuration (Release)
- [ ] Configurar Scheme para Release
- [ ] Verificar Capabilities

---

## ✅ Paso 1: Abrir el Proyecto Correctamente

**⚠️ IMPORTANTE:** Siempre abre el **`.xcworkspace`**, NO el `.xcodeproj`

```bash
cd /Users/gabrielsaladin/Desktop/playa-rd
open ios/Runner.xcworkspace
```

**¿Por qué?** Porque usas CocoaPods, y el workspace incluye los pods necesarios.

---

## ✅ Paso 2: Configurar Bundle Identifier

1. En Xcode, en el navegador izquierdo, selecciona el proyecto **Runner** (icono azul)
2. Selecciona el **target "Runner"** (no el proyecto)
3. Ve a la pestaña **General**
4. En la sección **Identity**, verifica:
   - **Bundle Identifier:** `com.playasrd.playasrd`
   - **Display Name:** `Playas RD`
   - **Version:** `1.0.1` (debe coincidir con `pubspec.yaml`)
   - **Build:** `4` (debe coincidir con `pubspec.yaml`)

**Si el Bundle ID está incorrecto:**
- Cámbialo a: `com.playasrd.playasrd`
- Presiona **Enter** y confirma

---

## ✅ Paso 3: Configurar Signing & Capabilities (CRÍTICO)

Esta es la configuración más importante para producción.

### 3.1 Ir a Signing & Capabilities

1. Con el target **Runner** seleccionado
2. Ve a la pestaña **Signing & Capabilities**

### 3.2 Configurar Signing Automático

**Opción A: Signing Automático (Recomendado)**

1. Marca ✅ **Automatically manage signing**
2. En **Team**, selecciona tu cuenta de desarrollador:
   - Si no aparece, haz clic en **Add Account...**
   - Ingresa tu Apple ID de desarrollador
   - Tu Team ID debería ser: `C3TZFSL98Z`
3. Xcode automáticamente:
   - Creará/actualizará el perfil de provisioning
   - Configurará el certificado correcto
   - Asignará el Bundle ID

**Verifica que aparezca:**
- ✅ **Provisioning Profile:** `iOS Team Provisioning Profile: com.playasrd.playasrd`
- ✅ **Signing Certificate:** `Apple Distribution` (para Release)

**Opción B: Signing Manual (Si prefieres control total)**

1. Desmarca **Automatically manage signing**
2. En **Provisioning Profile**, selecciona el perfil que descargaste desde Apple Developer Portal
3. Asegúrate de que sea un perfil de **App Store Distribution**

### 3.3 Verificar Capabilities

En la misma pestaña **Signing & Capabilities**, verifica que estén habilitadas:

- ✅ **Push Notifications** (para Firebase)
- ✅ **Background Modes** (debe incluir):
  - ✅ Remote notifications
  - ✅ Location updates (si usas ubicación en background)

**Si falta alguna:**
- Haz clic en **+ Capability**
- Agrega las que necesites

---

## ✅ Paso 4: Configurar Deployment Target

1. Con el target **Runner** seleccionado
2. Ve a la pestaña **General**
3. En **Deployment Info**, configura:
   - **iOS:** `15.0` (o superior)
   - **Devices:** Solo **iPhone** (no iPad, no Apple Watch)

**Verifica en Build Settings:**
1. Ve a la pestaña **Build Settings**
2. Busca **iOS Deployment Target**
3. Debe ser `15.0` o superior
4. Busca **Targeted Device Family**
5. Debe ser solo `iPhone` (valor `1`)

---

## ✅ Paso 5: Configurar Build Configuration para Release

### 5.1 Seleccionar Scheme y Destino

1. En la barra superior de Xcode, verifica:
   - **Scheme:** `Runner`
   - **Destination:** `Any iOS Device` (NO un simulador)
   
   **⚠️ IMPORTANTE:** Para producción, SIEMPRE selecciona **"Any iOS Device"** o un dispositivo físico conectado.

### 5.2 Verificar Build Configuration

1. Ve a **Product** > **Scheme** > **Edit Scheme...**
2. Selecciona **Run** en el lado izquierdo
3. En **Build Configuration**, selecciona **Release**
4. Haz clic en **Close**

**Para Archive (producción):**
1. En **Edit Scheme**, selecciona **Archive**
2. En **Build Configuration**, debe estar en **Release**
3. Haz clic en **Close**

---

## ✅ Paso 6: Verificar Configuración de Build Settings

1. Con el target **Runner** seleccionado
2. Ve a la pestaña **Build Settings**
3. Busca y verifica estas configuraciones:

### Code Signing

- **Code Signing Identity:**
  - **Debug:** `iOS Developer`
  - **Release:** `Apple Distribution` ✅
  
- **Code Signing Style:** `Automatic` (o `Manual` si prefieres)

- **Development Team:** `C3TZFSL98Z` ✅

- **Provisioning Profile:**
  - **Release:** Debe mostrar el perfil de App Store

### Product

- **Product Bundle Identifier:** `com.playasrd.playasrd` ✅

- **Product Name:** `Playas RD`

### Deployment

- **iOS Deployment Target:** `15.0` ✅

- **Targeted Device Family:** `iPhone` (valor `1`) ✅

---

## ✅ Paso 7: Verificar Info.plist

El archivo `ios/Runner/Info.plist` debe tener:

- ✅ **Bundle Identifier:** Usa `$(PRODUCT_BUNDLE_IDENTIFIER)` (se reemplaza automáticamente)
- ✅ **Display Name:** `Playas RD`
- ✅ **Version:** `$(FLUTTER_BUILD_NAME)` (se toma de `pubspec.yaml`)
- ✅ **Build:** `$(FLUTTER_BUILD_NUMBER)` (se toma de `pubspec.yaml`)

**Permisos configurados:**
- ✅ Cámara (`NSCameraUsageDescription`)
- ✅ Galería (`NSPhotoLibraryUsageDescription`)
- ✅ Ubicación (`NSLocationWhenInUseUsageDescription`)
- ✅ Ubicación siempre (`NSLocationAlwaysUsageDescription`)

**Configuraciones de servicios:**
- ✅ Google Sign-In (`GIDClientID`)
- ✅ AdMob (`GADApplicationIdentifier`)
- ✅ URL Schemes para Google Sign-In

---

## ✅ Paso 8: Verificar GoogleService-Info.plist

1. En el navegador de Xcode, verifica que `GoogleService-Info.plist` esté en:
   - `ios/Runner/GoogleService-Info.plist`
2. Verifica que esté agregado al target:
   - Selecciona el archivo
   - En el panel derecho, pestaña **File Inspector**
   - Verifica que esté marcado en **Target Membership** > **Runner**

**Contenido mínimo requerido:**
- ✅ `BUNDLE_ID`: `com.playasrd.playasrd`
- ✅ `PROJECT_ID`: `playas-rd-2b475`
- ✅ `API_KEY`: Configurado
- ✅ `GOOGLE_APP_ID`: Configurado

---

## ✅ Paso 9: Limpiar y Preparar para Build

Antes de compilar para producción, limpia el proyecto:

```bash
# Desde la raíz del proyecto
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
```

---

## ✅ Paso 10: Compilar para Producción

### Opción A: Desde Xcode (Recomendado para Archive)

1. En Xcode, selecciona **Any iOS Device** como destino
2. Ve a **Product** > **Archive**
3. Espera a que termine (puede tardar varios minutos)
4. Se abrirá **Organizer** automáticamente
5. Selecciona el archive y haz clic en **Distribute App**
6. Selecciona **App Store Connect**
7. Sigue los pasos para subir

### Opción B: Desde Terminal (Para verificar)

```bash
# Build de release (sin archivar)
flutter build ios --release

# Esto creará el build en: build/ios/iphoneos/Runner.app
```

**⚠️ Nota:** Para subir a App Store, necesitas usar Xcode para crear el Archive.

---

## 🔍 Verificación Final Antes de Compilar

### Checklist de Verificación:

- [ ] ✅ Bundle ID: `com.playasrd.playasrd`
- [ ] ✅ Team seleccionado: `C3TZFSL98Z`
- [ ] ✅ Signing automático habilitado (o perfil manual configurado)
- [ ] ✅ Certificado: `Apple Distribution` (para Release)
- [ ] ✅ Deployment Target: `15.0` o superior
- [ ] ✅ Targeted Device Family: Solo iPhone
- [ ] ✅ Build Configuration: Release
- [ ] ✅ Destination: Any iOS Device (no simulador)
- [ ] ✅ GoogleService-Info.plist presente y correcto
- [ ] ✅ Info.plist con todos los permisos
- [ ] ✅ Versión y Build coinciden con `pubspec.yaml` (1.0.1+4)

---

## ⚠️ Errores Comunes y Soluciones

### Error: "No signing certificate found"

**Solución:**
1. Ve a **Xcode** > **Preferences** > **Accounts**
2. Selecciona tu cuenta de Apple
3. Haz clic en **Download Manual Profiles**
4. Vuelve a **Signing & Capabilities** y selecciona tu Team

### Error: "Provisioning profile doesn't match"

**Solución:**
1. Verifica que el Bundle ID en Xcode sea exactamente `com.playasrd.playasrd`
2. En Apple Developer Portal, verifica que el App ID coincida
3. Regenera el perfil de provisioning si es necesario
4. En Xcode, intenta **Download Manual Profiles** nuevamente

### Error: "Code signing is required"

**Solución:**
1. Asegúrate de tener una cuenta de desarrollador activa ($99 USD/año)
2. Verifica que el Team esté seleccionado en Signing & Capabilities
3. Si usas signing automático, Xcode debería crear el perfil automáticamente

### Error: "GoogleService-Info.plist not found"

**Solución:**
1. Verifica que el archivo esté en `ios/Runner/GoogleService-Info.plist`
2. En Xcode, verifica que el archivo esté agregado al target Runner
3. Selecciona el archivo y en **File Inspector**, verifica **Target Membership**

### Error al compilar: "Undefined symbol"

**Solución:**
```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

---

## 📝 Notas Importantes

### Versión y Build Number

- **Versión:** Se toma de `pubspec.yaml` → `version: 1.0.1+4`
  - `1.0.1` = Versión visible al usuario
  - `4` = Build number (incrementa con cada build)

**Para una nueva versión:**
1. Edita `pubspec.yaml`:
   ```yaml
   version: 1.0.2+5  # Incrementa versión y build
   ```
2. Xcode tomará automáticamente estos valores

### Certificados y Perfiles

- **Para desarrollo:** Usa `iOS Developer` certificate
- **Para producción/App Store:** Usa `Apple Distribution` certificate
- Xcode con signing automático maneja esto por ti

### Build Configuration

- **Debug:** Para desarrollo y pruebas
- **Release:** Para producción y App Store
- **Profile:** Para profiling de rendimiento

Siempre usa **Release** para compilar para producción.

---

## 🎯 Resumen de Configuración Actual

**Tu proyecto está configurado con:**

- ✅ Bundle ID: `com.playasrd.playasrd`
- ✅ Team ID: `C3TZFSL98Z`
- ✅ Deployment Target: `15.0`
- ✅ Device Family: Solo iPhone (`1`)
- ✅ Versión: `1.0.1+4`
- ✅ Signing: Automático (recomendado)

**Solo necesitas verificar en Xcode:**
1. Que el Team esté seleccionado
2. Que el Bundle ID sea correcto
3. Que el destino sea "Any iOS Device" para Archive
4. Que el Build Configuration sea Release

---

## 🚀 Próximos Pasos

Una vez configurado Xcode:

1. **Compilar:** `Product` > `Archive` en Xcode
2. **Subir:** Desde Organizer, `Distribute App` > `App Store Connect`
3. **Configurar en App Store Connect:** Seleccionar el build y completar la información
4. **Enviar para revisión:** `Submit for Review`

---

**¡Listo para compilar para producción! 🎉**

**Última actualización:** Diciembre 2024

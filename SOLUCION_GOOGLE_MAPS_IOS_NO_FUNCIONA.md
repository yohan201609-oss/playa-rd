# 🔧 Solución: Google Maps No Funciona en iOS (iPhone)

## 📋 Problema

El mapa de Google Maps no se muestra en iOS (iPhone), pero funciona correctamente en Android.

**⚠️ PROBLEMA IDENTIFICADO:** Estás usando la API Key de **Firebase** (`AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`) en lugar de una API Key específica de **Google Maps**.

**Clave actual (Firebase - INCORRECTA):** `AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`  
**Ubicación:** `ios/Runner/AppDelegate.swift` (línea 14)

**Solución:** Necesitas crear una nueva API Key específica de Google Maps para iOS. Ver: `CREAR_API_KEY_GOOGLE_MAPS_IOS.md`

---

## 🔍 Posibles Causas

1. **Restricciones de la API Key:** La clave está restringida para un Bundle ID diferente
2. **APIs no habilitadas:** Maps SDK for iOS no está habilitado en Google Cloud Console
3. **Bundle ID incorrecto:** Discrepancia entre el Bundle ID configurado y el real

---

## ✅ Solución 1: Crear Nueva API Key de Google Maps para iOS (RECOMENDADO)

**⚠️ IMPORTANTE:** La clave actual es de Firebase, no de Google Maps. Necesitas crear una nueva.

**Ver guía completa:** `CREAR_API_KEY_GOOGLE_MAPS_IOS.md`

### Resumen rápido:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea una nueva API Key
3. Configura restricciones para iOS apps con Bundle ID: `com.playasrd.playasRdFlutter`
4. Habilita Maps SDK for iOS
5. Actualiza `AppDelegate.swift` con la nueva clave

---

## ✅ Solución 1b: Verificar y Configurar Restricciones de la API Key (Si ya tienes una clave de Maps)

### Paso 1: Identificar el Bundle ID Real

Tu app iOS usa el Bundle ID: **`com.playasrd.playasRdFlutter`**

⚠️ **IMPORTANTE:** Hay una discrepancia:
- Bundle ID en `project.pbxproj`: `com.playasrd.playasRdFlutter`
- Bundle ID en `GoogleService-Info.plist`: `com.playasrd.playasrd`

### Paso 2: Configurar Restricciones en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Credentials**
4. Busca la API Key: `AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`
5. Haz clic en el nombre de la API Key para editarla

#### Configurar Application Restrictions:

1. En **"Application restrictions"**, selecciona **"iOS apps"**
2. Haz clic en **"+ Add an item"**
3. Agrega el Bundle ID:
   - **Bundle ID:** `com.playasrd.playasRdFlutter`
   - ⚠️ **IMPORTANTE:** Usa exactamente este Bundle ID (con la "F" mayúscula en "Flutter")
4. Si también quieres permitir el otro Bundle ID (por si acaso):
   - Haz clic en **"+ Add an item"** nuevamente
   - **Bundle ID:** `com.playasrd.playasrd` (sin "Flutter")

#### Configurar API Restrictions:

1. En **"API restrictions"**, selecciona **"Restrict key"**
2. Marca SOLO estas APIs:
   - ✅ **Maps SDK for iOS** ⚠️ **OBLIGATORIO**
   - ✅ **Geocoding API**
   - ✅ **Places API** (si la usas)
3. Haz clic en **"Save"**
4. Espera 1-2 minutos para que los cambios se propaguen

---

## ✅ Solución 2: Verificar que las APIs Estén Habilitadas

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Library**
4. Busca y verifica que estén **habilitadas** (Enabled):
   - ✅ **Maps SDK for iOS** ⚠️ **CRÍTICO - Debe estar habilitado**
   - ✅ **Geocoding API**
   - ✅ **Places API** (si la usas)

Si alguna no está habilitada:
1. Haz clic en la API
2. Haz clic en **"Enable"** (Habilitar)
3. Espera unos segundos

---

## ✅ Solución 3: Quitar Restricciones Temporalmente (SOLO PARA DEBUG)

⚠️ **ADVERTENCIA:** Esta solución es solo para desarrollo. NO uses esto en producción.

### Pasos:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Credentials**
4. Busca la API Key: `AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`
5. Haz clic en el nombre de la API Key para editarla
6. En **"Application restrictions"**, selecciona **"None"**
7. Haz clic en **"Save"**
8. Espera 1-2 minutos

**⚠️ IMPORTANTE:** Vuelve a configurar las restricciones antes de publicar en producción.

---

## ✅ Solución 4: Verificar la Configuración en AppDelegate.swift

Asegúrate de que `ios/Runner/AppDelegate.swift` tenga la configuración correcta:

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
    // Configurar Google Maps API Key
    GMSServices.provideAPIKey("AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

✅ **Verifica que:**
- La línea `import GoogleMaps` esté presente
- La línea `GMSServices.provideAPIKey(...)` esté presente
- La API Key sea correcta: `AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`

---

## 🔍 Verificar que Funciona

Después de aplicar cualquiera de las soluciones:

1. **Espera 1-2 minutos** para que los cambios se propaguen
2. **Limpia el proyecto:**
   ```bash
   flutter clean
   flutter pub get
   ```
3. **Compila y prueba en iOS:**
   ```bash
   flutter run -d ios
   ```
   O desde Xcode:
   - Abre `ios/Runner.xcworkspace` en Xcode
   - Selecciona un dispositivo o simulador
   - Presiona ⌘+R para ejecutar

4. **Verifica que el mapa se muestre correctamente**

---

## 🆘 Solución de Problemas

### ❌ "API Key no autorizada" o "This API key is not authorized"

**Causas posibles:**
1. El Bundle ID no coincide exactamente
2. Las APIs no están habilitadas
3. Las restricciones aún no se han propagado

**Soluciones:**
- Verifica que el Bundle ID sea exactamente: `com.playasrd.playasRdFlutter`
- Verifica que **Maps SDK for iOS** esté habilitado
- Espera 2-3 minutos más

### ❌ El mapa sigue sin funcionar después de configurar restricciones

1. **Verifica el Bundle ID real:**
   - Abre Xcode
   - Selecciona el proyecto "Runner"
   - Ve a la pestaña "General"
   - Verifica el "Bundle Identifier"
   - Usa ese Bundle ID exacto en Google Cloud Console

2. **Verifica que las APIs estén habilitadas:**
   - Maps SDK for iOS (obligatorio)
   - Geocoding API
   - Places API (si la usas)

3. **Limpia y reconstruye:**
   ```bash
   flutter clean
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter run -d ios
   ```

### ❌ Error: "GoogleMaps module not found"

Este es un error diferente. Verifica que:
1. Los pods estén instalados:
   ```bash
   cd ios
   pod install
   cd ..
   ```
2. Abres el proyecto desde `ios/Runner.xcworkspace` (NO desde `.xcodeproj`)

---

## 📝 Resumen de Configuración

### API Key de iOS
- **Clave:** `AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`
- **Ubicación:** `ios/Runner/AppDelegate.swift`

### Bundle ID
- **Bundle ID real:** `com.playasrd.playasRdFlutter`
- **Bundle ID alternativo:** `com.playasrd.playasrd` (en GoogleService-Info.plist)

### Restricciones Recomendadas
- ✅ **Application restrictions:** iOS apps
  - Bundle ID: `com.playasrd.playasRdFlutter` (principal)
  - Bundle ID: `com.playasrd.playasrd` (alternativo, opcional)
- ✅ **API restrictions:** Restrict key
  - Maps SDK for iOS ⚠️ **OBLIGATORIO**
  - Geocoding API
  - Places API (si la usas)

---

## 📚 Referencias

- [Documentación de Google Maps iOS SDK](https://developers.google.com/maps/documentation/ios-sdk)
- [Configurar restricciones de API Keys](https://cloud.google.com/docs/authentication/api-keys#restricting_apis)
- Ver también: `GUIA_PRODUCCION_IOS.md`

---

**Última actualización:** Diciembre 2024


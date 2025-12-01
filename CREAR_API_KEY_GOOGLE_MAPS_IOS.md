# 🔑 Crear API Key de Google Maps para iOS

## 📋 Situación Actual

Actualmente estás usando la API Key de **Firebase** (`AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`) para Google Maps en iOS, pero necesitas una API Key específica de **Google Maps**.

**Clave actual (Firebase):** `AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`  
**Clave de Android (Google Maps):** `AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus`

---

## ✅ Solución: Crear Nueva API Key de Google Maps para iOS

### Paso 1: Crear la API Key en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Credentials**
4. Haz clic en **"+ CREATE CREDENTIALS"** (Crear credenciales)
5. Selecciona **"API key"** (Clave de API)
6. Se creará una nueva API Key (copia esta clave, la necesitarás)

### Paso 2: Configurar Restricciones de Aplicación

1. Haz clic en el nombre de la nueva API Key para editarla
2. En **"Application restrictions"**, selecciona **"iOS apps"**
3. Haz clic en **"+ Add an item"**
4. Agrega el Bundle ID:
   - **Bundle ID:** `com.playasrd.playasRdFlutter`
   - ⚠️ **IMPORTANTE:** Usa exactamente este Bundle ID (con la "F" mayúscula en "Flutter")
5. Si también quieres permitir el otro Bundle ID:
   - Haz clic en **"+ Add an item"** nuevamente
   - **Bundle ID:** `com.playasrd.playasrd` (sin "Flutter")

### Paso 3: Configurar Restricciones de API

1. En **"API restrictions"**, selecciona **"Restrict key"**
2. Marca SOLO estas APIs:
   - ✅ **Maps SDK for iOS** ⚠️ **OBLIGATORIO**
   - ✅ **Geocoding API**
   - ✅ **Places API** (si la usas)
3. Haz clic en **"Save"** (Guardar)

### Paso 4: Verificar que Maps SDK for iOS Esté Habilitado

1. Ve a **APIs & Services** > **Library**
2. Busca **"Maps SDK for iOS"**
3. Si no está habilitado, haz clic en **"Enable"** (Habilitar)
4. Espera unos segundos

### Paso 5: Actualizar AppDelegate.swift

1. Abre `ios/Runner/AppDelegate.swift`
2. Reemplaza la API Key de Firebase con la nueva API Key de Google Maps:

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
    // Configurar Google Maps API Key (específica para Maps, no Firebase)
    GMSServices.provideAPIKey("TU_NUEVA_API_KEY_DE_GOOGLE_MAPS_IOS")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Reemplaza** `TU_NUEVA_API_KEY_DE_GOOGLE_MAPS_IOS` con la nueva API Key que creaste.

### Paso 6: Probar

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

---

## 🔄 Alternativa: Usar la Misma Clave de Android (NO RECOMENDADO)

Si prefieres usar la misma clave de Android para iOS:

1. Ve a Google Cloud Console
2. Edita la clave de Android: `AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus`
3. En **"Application restrictions"**, selecciona **"None"** (temporalmente)
4. O agrega restricciones para ambas plataformas (más complejo)

⚠️ **NO RECOMENDADO** porque:
- Mejor práctica es tener claves separadas por plataforma
- Más fácil de gestionar y depurar
- Mejor seguridad

---

## 📝 Resumen

### Lo que necesitas hacer:

1. ✅ Crear nueva API Key de Google Maps para iOS
2. ✅ Configurar restricciones: iOS apps + Bundle ID `com.playasrd.playasRdFlutter`
3. ✅ Habilitar Maps SDK for iOS
4. ✅ Actualizar `AppDelegate.swift` con la nueva clave
5. ✅ Probar en iOS

### Bundle ID importante:
- **Bundle ID real:** `com.playasrd.playasRdFlutter` (con "F" mayúscula)

---

## 🆘 Solución de Problemas

### ❌ "API Key no autorizada"

- Verifica que el Bundle ID sea exactamente: `com.playasrd.playasRdFlutter`
- Verifica que **Maps SDK for iOS** esté habilitado
- Espera 2-3 minutos para que los cambios se propaguen

### ❌ El mapa sigue sin funcionar

1. Verifica que la nueva API Key esté en `AppDelegate.swift`
2. Verifica que Maps SDK for iOS esté habilitado
3. Limpia y reconstruye:
   ```bash
   flutter clean
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter run -d ios
   ```

---

**Última actualización:** Diciembre 2024


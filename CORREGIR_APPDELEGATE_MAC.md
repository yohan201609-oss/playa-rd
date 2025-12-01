# 🔧 Corregir AppDelegate.swift en Mac

## ❌ Error Actual

Estás viendo estos errores en Xcode:
- "Invalid conditional compilation expression" (línea 10)
- "#error directive requires parentheses" (línea 12)

## 🔍 Causa

El archivo `AppDelegate.swift` en tu Mac todavía tiene el código antiguo con directivas de preprocesador (`#if`, `#error`, `#import`) que no funcionan en Swift.

## ✅ Solución: Actualizar el Archivo

### Opción 1: Desde Terminal (Más Rápido)

```bash
cd ~/Desktop/playa-rd

# 1. Descartar cambios locales en AppDelegate.swift
git checkout -- ios/Runner/AppDelegate.swift

# 2. Verificar que se actualizó
cat ios/Runner/AppDelegate.swift
```

El archivo debe verse así (sin `#if`, `#error`, o `#import`):

```swift
import Flutter
import UIKit
import GoogleMaps

// La API Key se importa a través del Bridging Header (Runner-Bridging-Header.h)
// El archivo GoogleMaps-API-Key.h debe estar agregado al proyecto en Xcode

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Optimización: Inicializar Google Maps de forma diferida después del registro de plugins
    // para reducir el impacto en el tiempo de inicio y uso de memoria
    GeneratedPluginRegistrant.register(with: self)
    
    // Inicializar Google Maps después de que los plugins estén registrados
    // Esto permite que Flutter esté listo antes de cargar el SDK pesado de Google Maps
    DispatchQueue.main.async {
      GMSServices.provideAPIKey(GOOGLE_MAPS_API_KEY)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Opción 2: Editar Manualmente en Xcode

1. **Abre el archivo en Xcode:**
   - En el navegador de proyectos, busca `AppDelegate.swift`
   - Haz doble clic para abrirlo

2. **Elimina las líneas problemáticas:**
   - Busca y elimina cualquier línea que tenga:
     - `#if __has_include(...)`
     - `#import "GoogleMaps-API-Key.h"`
     - `#else`
     - `#error "..."`
     - `#endif`

3. **El archivo debe quedar así:**

```swift
import Flutter
import UIKit
import GoogleMaps

// La API Key se importa a través del Bridging Header (Runner-Bridging-Header.h)
// El archivo GoogleMaps-API-Key.h debe estar agregado al proyecto en Xcode

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    DispatchQueue.main.async {
      GMSServices.provideAPIKey(GOOGLE_MAPS_API_KEY)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

4. **Guarda el archivo:** `Cmd + S`

## ✅ Verificación

### 1. Verificar el contenido del archivo

```bash
cd ~/Desktop/playa-rd
cat ios/Runner/AppDelegate.swift | grep -E "#if|#import|#error"
```

**No debe mostrar nada** (sin directivas de preprocesador).

### 2. Verificar el Bridging Header

```bash
cat ios/Runner/Runner-Bridging-Header.h
```

Debe mostrar:
```objc
#import "GeneratedPluginRegistrant.h"
#import "GoogleMaps-API-Key.h"
```

### 3. Reconstruir en Xcode

1. **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)

Los errores deben desaparecer.

## 🆘 Si el Error Persiste

### Verificar que el archivo está actualizado

```bash
cd ~/Desktop/playa-rd
git diff ios/Runner/AppDelegate.swift
```

Si muestra diferencias, significa que el archivo no está actualizado. Ejecuta:

```bash
git checkout -- ios/Runner/AppDelegate.swift
```

### Verificar que el Bridging Header está correcto

1. En Xcode, abre `Runner-Bridging-Header.h`
2. Debe contener:
   ```objc
   #import "GeneratedPluginRegistrant.h"
   #import "GoogleMaps-API-Key.h"
   ```

### Verificar que GoogleMaps-API-Key.h está agregado al proyecto

1. En Xcode, busca `GoogleMaps-API-Key.h` en el navegador de proyectos
2. Si no aparece, agrégalo (ver `PASOS_DESPUES_PULL.md`)

## 📝 Resumen de Comandos

```bash
# 1. Actualizar AppDelegate.swift
cd ~/Desktop/playa-rd
git checkout -- ios/Runner/AppDelegate.swift

# 2. Verificar que está correcto
cat ios/Runner/AppDelegate.swift

# 3. Verificar Bridging Header
cat ios/Runner/Runner-Bridging-Header.h

# 4. En Xcode: Clean y Build
# Product → Clean Build Folder (⇧⌘K)
# Product → Build (⌘B)
```

## ✅ Checklist

- [ ] `AppDelegate.swift` no tiene directivas `#if`, `#import`, o `#error`
- [ ] `Runner-Bridging-Header.h` contiene `#import "GoogleMaps-API-Key.h"`
- [ ] `GoogleMaps-API-Key.h` está agregado al proyecto en Xcode
- [ ] Proyecto limpiado (Clean Build Folder)
- [ ] Build exitoso sin errores


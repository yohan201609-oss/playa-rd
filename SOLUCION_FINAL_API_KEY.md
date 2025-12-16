# ✅ Solución Final: Errores de GoogleMaps-API-Key.h

## 🔍 Problema

Aunque el archivo `GoogleMaps-API-Key.h` existe y tiene la API key configurada, Xcode muestra errores:
- "Invalid conditional compilation expression"
- "Cannot find 'GOOGLE_MAPS_API_KEY' in scope"

## ✅ Solución Aplicada

Se ha actualizado el **Bridging Header** para importar el archivo de API Key. Esto permite que Swift acceda a las constantes definidas en Objective-C.

### Cambios realizados:

1. **Runner-Bridging-Header.h** - Agregado el import:
   ```objc
   #import "GoogleMaps-API-Key.h"
   ```

2. **AppDelegate.swift** - Simplificado (ya no necesita el import directo)

## 📋 Pasos para Resolver en Mac

### Paso 1: Actualizar el repositorio

```bash
cd ~/Desktop/playa-rd
git pull origin main
```

### Paso 2: Verificar que el archivo existe

```bash
ls -la ios/Runner/GoogleMaps-API-Key.h
```

### Paso 3: Agregar el archivo al proyecto de Xcode (IMPORTANTE)

1. **Abre el proyecto:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Agrega GoogleMaps-API-Key.h al proyecto:**
   - En el navegador de proyectos (panel izquierdo)
   - Clic derecho en la carpeta `Runner`
   - Selecciona "Add Files to Runner..."
   - Navega a: `ios/Runner/GoogleMaps-API-Key.h`
   - **NO marques** "Copy items if needed"
   - Asegúrate de que el target "Runner" esté seleccionado
   - Haz clic en "Add"

3. **Verifica que aparezca en el proyecto:**
   - El archivo debe estar visible en el navegador de proyectos
   - Debe estar dentro de la carpeta `Runner`

### Paso 4: Verificar el Bridging Header

1. En Xcode, selecciona el proyecto "Runner" en el navegador
2. Selecciona el target "Runner"
3. Ve a la pestaña "Build Settings"
4. Busca "Objective-C Bridging Header"
5. Debe mostrar: `Runner/Runner-Bridging-Header.h`

### Paso 5: Limpiar y reconstruir

En Xcode:
- **Product → Clean Build Folder** (⇧⌘K)
- **Product → Build** (⌘B)

O desde Terminal:

```bash
cd ~/Desktop/playa-rd
flutter clean
flutter pub get
flutter build ios --no-codesign
```

## 🔑 Si Necesitas Cambiar la API Key

1. Abre `GoogleMaps-API-Key.h` en Xcode o cualquier editor
2. Edita la línea 10:
   ```objc
   #define GOOGLE_MAPS_API_KEY @"TU_API_KEY_AQUI"
   ```
3. Reemplaza `TU_API_KEY_AQUI` con tu clave real
4. Guarda el archivo

## ✅ Verificación

Después de seguir estos pasos:

1. **El archivo aparece en el navegador de proyectos de Xcode**
2. **El proyecto compila sin errores**
3. **La constante `GOOGLE_MAPS_API_KEY` está disponible en Swift**

## 🆘 Si el Error Persiste

### Verificar que el archivo está en el proyecto:

1. En Xcode, busca `GoogleMaps-API-Key.h` en el navegador de proyectos
2. Si no aparece, agrégalo siguiendo el Paso 3

### Verificar el Bridging Header:

1. Selecciona el proyecto → Target "Runner" → Build Settings
2. Busca "Objective-C Bridging Header"
3. Debe ser: `Runner/Runner-Bridging-Header.h`

### Verificar el contenido del Bridging Header:

Abre `ios/Runner/Runner-Bridging-Header.h` y verifica que tenga:

```objc
#import "GeneratedPluginRegistrant.h"
#import "GoogleMaps-API-Key.h"
```

### Reconstruir desde cero:

```bash
cd ~/Desktop/playa-rd
flutter clean
rm -rf ios/Pods ios/Podfile.lock
cd ios
pod install
cd ..
flutter pub get
flutter build ios --no-codesign
```

## 📚 Archivos Modificados

- ✅ `ios/Runner/Runner-Bridging-Header.h` - Agregado import
- ✅ `ios/Runner/AppDelegate.swift` - Simplificado (sin import directo)
- ✅ `ios/Runner/GoogleMaps-API-Key.h` - Debe estar agregado al proyecto


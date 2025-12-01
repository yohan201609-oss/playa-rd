# 🔧 Solución: Errores de Compilación con GoogleMaps-API-Key.h

## ❌ Errores Comunes

Si ves estos errores en Xcode:

1. **"Invalid conditional compilation expression"**
2. **"#error directive requires parentheses"**
3. **"'GoogleMaps-API-Key.h' file not found"**

## 🔍 Causa

El archivo `GoogleMaps-API-Key.h` existe en el sistema de archivos, pero **no está agregado al proyecto de Xcode**. Xcode necesita que el archivo esté explícitamente agregado al proyecto para poder compilarlo.

## ✅ Solución Paso a Paso

### Paso 1: Verificar que el archivo existe

En Terminal, verifica que el archivo existe:

```bash
cd ~/Desktop/playa-rd/ios/Runner
ls -la GoogleMaps-API-Key.h
```

Si no existe, créalo desde el template:

```bash
cp GoogleMaps-API-Key.h.template GoogleMaps-API-Key.h
```

### Paso 2: Abrir el proyecto en Xcode

```bash
cd ~/Desktop/playa-rd
open ios/Runner.xcworkspace
```

**⚠️ IMPORTANTE:** Usa `.xcworkspace`, NO `.xcodeproj`

### Paso 3: Agregar el archivo al proyecto

1. **En el navegador de proyectos de Xcode** (panel izquierdo):
   - Busca la carpeta `Runner`
   - Haz clic derecho sobre la carpeta `Runner`

2. **Selecciona "Add Files to Runner..."**

3. **En el diálogo que aparece:**
   - Navega a: `ios/Runner/GoogleMaps-API-Key.h`
   - **IMPORTANTE:** 
     - ❌ **NO marques** "Copy items if needed" (el archivo ya está en la ubicación correcta)
     - ✅ **SÍ marca** que el target "Runner" esté seleccionado
   - Haz clic en "Add"

4. **Verifica que el archivo aparezca:**
   - El archivo `GoogleMaps-API-Key.h` debe aparecer en el navegador de proyectos
   - Debe estar dentro de la carpeta `Runner`
   - Debe tener el target "Runner" asignado (puedes verificar en el Inspector de archivos)

### Paso 4: Verificar la configuración del archivo

1. **Selecciona el archivo** `GoogleMaps-API-Key.h` en el navegador
2. **Abre el Inspector de archivos** (panel derecho, icono de documento)
3. **En "Target Membership":**
   - ✅ Debe estar marcado "Runner"

### Paso 5: Limpiar y reconstruir

En Xcode:
1. **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)

O desde Terminal:

```bash
cd ~/Desktop/playa-rd
flutter clean
flutter pub get
flutter build ios --no-codesign
```

## 🔄 Si el Archivo No Existe

Si el archivo `GoogleMaps-API-Key.h` no existe:

### Opción 1: Crear desde el template

```bash
cd ~/Desktop/playa-rd/ios/Runner
cp GoogleMaps-API-Key.h.template GoogleMaps-API-Key.h
```

Luego edita el archivo y reemplaza `YOUR_API_KEY_HERE` con tu clave API real.

### Opción 2: Crear manualmente

1. Crea un nuevo archivo en Xcode:
   - Clic derecho en `Runner` → "New File..."
   - Selecciona "Header File"
   - Nómbralo: `GoogleMaps-API-Key.h`

2. Agrega este contenido:

```objc
//
// GoogleMaps-API-Key.h
// Configuración local de Google Maps API Key
// ⚠️ ESTE ARCHIVO NO SE SUBE AL REPOSITORIO
//

#ifndef GoogleMaps_API_Key_h
#define GoogleMaps_API_Key_h

#define GOOGLE_MAPS_API_KEY @"TU_API_KEY_AQUI"

#endif /* GoogleMaps_API_Key_h */
```

3. Reemplaza `TU_API_KEY_AQUI` con tu clave API real de Google Maps.

## ✅ Verificación Final

Después de agregar el archivo, verifica:

1. **El archivo aparece en el navegador de proyectos de Xcode**
2. **El target "Runner" está seleccionado**
3. **El proyecto compila sin errores**

## 🆘 Si el Error Persiste

### Verificar que el archivo está en la ubicación correcta

```bash
cd ~/Desktop/playa-rd
find . -name "GoogleMaps-API-Key.h" -type f
```

Debe mostrar: `./ios/Runner/GoogleMaps-API-Key.h`

### Verificar el contenido del archivo

```bash
cat ios/Runner/GoogleMaps-API-Key.h
```

Debe contener la definición de `GOOGLE_MAPS_API_KEY`.

### Eliminar y volver a agregar

1. En Xcode, elimina la referencia al archivo (Delete → "Remove Reference")
2. Vuelve a agregarlo siguiendo el Paso 3

### Verificar el import en AppDelegate.swift

Abre `ios/Runner/AppDelegate.swift` y verifica que tenga:

```swift
#import "GoogleMaps-API-Key.h"
```

## 📚 Referencias

- Ver `ios/Runner/README_API_KEY.md` para más detalles sobre configuración
- Ver `CONFIGURAR_API_KEYS.md` para información general sobre API keys


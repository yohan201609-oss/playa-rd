# 🔐 Configuración de Google Maps API Key para iOS

## ⚠️ Importante

El archivo `GoogleMaps-API-Key.h` contiene tu clave API real y **NO se sube al repositorio** por seguridad.

## 📋 Pasos para configurar

### 1. Crear el archivo de configuración

Si aún no existe, copia el template:

```bash
cd ios/Runner
cp GoogleMaps-API-Key.h.template GoogleMaps-API-Key.h
```

### 2. Editar el archivo

Abre `GoogleMaps-API-Key.h` y reemplaza `YOUR_API_KEY_HERE` con tu clave API real de Google Maps.

### 3. Agregar al proyecto de Xcode

**IMPORTANTE:** El archivo debe estar agregado al proyecto de Xcode para que se compile:

1. Abre el proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. En Xcode:
   - Haz clic derecho en la carpeta `Runner` en el navegador de proyectos
   - Selecciona "Add Files to Runner..."
   - Navega a `ios/Runner/GoogleMaps-API-Key.h`
   - **NO marques** "Copy items if needed" (el archivo ya está en la ubicación correcta)
   - Asegúrate de que el target "Runner" esté seleccionado
   - Haz clic en "Add"

3. Verifica que el archivo aparezca en el proyecto:
   - Debe estar visible en el navegador de proyectos de Xcode
   - Debe tener el target "Runner" asignado

### 4. Verificar compilación

Compila el proyecto para verificar que todo funciona:

```bash
flutter build ios --no-codesign
```

O desde Xcode:
- Product → Build (⌘B)

## 🔄 Si la clave fue expuesta

Si GitHub detectó que la clave fue expuesta en un commit anterior:

1. **Rota la clave inmediatamente:**
   - Ve a [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
   - Crea una nueva clave API
   - Elimina o restringe la clave antigua

2. **Actualiza el archivo local:**
   - Edita `GoogleMaps-API-Key.h` con la nueva clave
   - El archivo NO se subirá al repositorio (está en .gitignore)

3. **Verifica restricciones:**
   - Limita la nueva clave por aplicación iOS
   - Configura restricciones de Bundle ID si es posible

## ✅ Verificación

Antes de hacer commit, verifica:

```bash
git status
```

El archivo `GoogleMaps-API-Key.h` **NO debe aparecer** en la lista. Solo debe aparecer `GoogleMaps-API-Key.h.template`.


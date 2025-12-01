# 🔧 Solución de Problemas en Xcode

**Proyecto:** Playas RD Flutter  
**Objetivo:** Resolver errores y advertencias al abrir el proyecto en Xcode

---

## 📋 Problemas Identificados

Basado en los errores mostrados en Xcode:

1. ❌ **Error:** `Unable to find module dependency: 'GoogleMaps'`
2. ⚠️ **Advertencia:** AppIcon con 37 archivos sin asignar
3. ⚠️ **Advertencia:** `UNNotificationPresentationOptionAlert` deprecado (iOS 14.0)
4. ⚠️ **Advertencia:** Problemas con `geocoding_ios` y `geolocator_apple`
5. ⚠️ **Advertencia:** Deployment target para iOS Simulator

---

## 🔴 Problema 0: Error de Google Sign-In (GIDClientID)

### Síntoma
```
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', 
reason: 'No active configuration. Make sure GIDClientID is set in Info.plist.'
```

### Causa
Falta la clave `GIDClientID` en el archivo `Info.plist` de iOS. Esta clave es requerida para que Google Sign-In funcione correctamente.

### Solución

#### Opción 1: Agregar manualmente en Xcode (Recomendado)

1. **Abre el proyecto en Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Navega al archivo Info.plist:**
   - En el navegador izquierdo, expande `Runner`
   - Selecciona `Info.plist`

3. **Agrega la clave GIDClientID:**
   - Haz clic derecho en cualquier parte del editor
   - Selecciona **"Add Row"** (o presiona el botón `+`)
   - En la columna "Key", escribe: `GIDClientID`
   - En la columna "Type", asegúrate de que sea: `String`
   - En la columna "Value", agrega: `360714035813-j1q7j0elbuep49uurma34kkofh9v27i5.apps.googleusercontent.com`

4. **Verifica el valor:**
   - Este valor debe ser el mismo que aparece en `GoogleService-Info.plist` como `CLIENT_ID`
   - Ubicación del valor: `ios/Runner/GoogleService-Info.plist` → clave `CLIENT_ID`

5. **Verifica que esté en el lugar correcto:**
   - La clave `GIDClientID` debe estar al mismo nivel que otras claves como `GADApplicationIdentifier`
   - Debe estar dentro del diccionario principal de `Information Property List`

#### Opción 2: Editar directamente el archivo XML (Avanzado)

Si prefieres editar el archivo directamente, puedes abrir `ios/Runner/Info.plist` en un editor de texto y agregar:

```xml
<key>GIDClientID</key>
<string>360714035813-j1q7j0elbuep49uurma34kkofh9v27i5.apps.googleusercontent.com</string>
```

⚠️ **Importante:** Si editas el XML directamente, asegúrate de mantener el formato correcto.

#### Verificación

Después de agregar la clave:

1. **Cierra y vuelve a abrir Xcode** (para asegurar que se recargue el archivo)
2. **Verifica en Xcode** que la clave `GIDClientID` aparezca en la lista
3. **Compila la app nuevamente:**
   ```bash
   flutter clean
   flutter run -d ios
   ```

#### Si el valor es diferente

Si tu `CLIENT_ID` es diferente, puedes encontrarlo en:
- `ios/Runner/GoogleService-Info.plist` → clave `CLIENT_ID`
- O en Firebase Console → Project Settings → Tu app iOS → `CLIENT_ID`

---

## 🔴 Problema 1: Error de GoogleMaps

### Síntoma
```
Unable to find module dependency: 'GoogleMaps'
import GoogleMaps
```

### Causa
Las dependencias de CocoaPods no están instaladas o el workspace no está configurado correctamente.

### Solución

#### Paso 1: Verificar que estás usando el Workspace correcto

**⚠️ IMPORTANTE:** Debes abrir `Runner.xcworkspace`, NO `Runner.xcodeproj`

```bash
# Si Xcode está abierto, ciérralo primero
# Luego abre el workspace correcto:
cd ios
open Runner.xcworkspace
```

#### Paso 2: Instalar dependencias de CocoaPods

En Terminal, ejecuta:

```bash
cd ios
pod install
```

Este comando puede tardar varios minutos la primera vez. Verás algo como:

```
Analyzing dependencies
Downloading dependencies
Installing GoogleMaps (x.x.x)
Installing google_maps_flutter_ios (x.x.x)
...
```

#### Paso 3: Verificar la instalación

Después de `pod install`, deberías ver:
- ✅ La carpeta `Pods` en el navegador izquierdo de Xcode
- ✅ El archivo `Podfile.lock` en la carpeta `ios`

#### Paso 4: Limpiar y reconstruir

Si el error persiste después de instalar pods:

```bash
# Limpiar build de Flutter
cd ..  # Volver a la raíz del proyecto
flutter clean
flutter pub get

# Limpiar pods
cd ios
rm -rf Pods
rm -rf Podfile.lock
pod install --repo-update
```

#### Paso 5: Cerrar y reabrir Xcode

1. Cierra completamente Xcode
2. Abre nuevamente: `open ios/Runner.xcworkspace`
3. Espera a que Xcode indexe el proyecto

---

## ⚠️ Problema 2: AppIcon con archivos sin asignar

### Síntoma
```
The app icon set 'AppIcon' has 37 unassigned children
```

### Causa
Hay muchos archivos de iconos en la carpeta `AppIcon.appiconset` que no están asignados en el contenido del asset.

### Solución

Esto es una advertencia, no un error crítico. Puedes ignorarla si la app funciona correctamente. Para eliminarla:

#### Opción 1: Eliminar archivos no usados (Recomendado)

1. En Xcode, ve a `Runner` > `Assets.xcassets` > `AppIcon`
2. Revisa qué tamaños de icono están configurados
3. Elimina los archivos PNG que no están asignados

O desde Terminal:

```bash
cd ios/Runner/Assets.xcassets/AppIcon.appiconset
# Revisa Contents.json para ver qué tamaños se usan
# Elimina los archivos no referenciados
```

#### Opción 2: Ignorar la advertencia

Si la app funciona correctamente, puedes ignorar esta advertencia. No afecta la funcionalidad.

---

## ⚠️ Problema 3: API Deprecado en flutter_local_notifications

### Síntoma
```
'UNNotificationPresentationOptionAlert' is deprecated: first deprecated in iOS 14.0
```

### Causa
El plugin `flutter_local_notifications` está usando APIs deprecadas de iOS.

### Solución

Esta advertencia viene del código del plugin, no de tu código. Tienes varias opciones:

#### Opción 1: Actualizar el plugin (Recomendado)

Actualiza `flutter_local_notifications` a la última versión:

```bash
flutter pub upgrade flutter_local_notifications
```

Luego reinstala los pods:

```bash
cd ios
pod install
```

#### Opción 2: Esperar actualización del plugin

Los desarrolladores del plugin están trabajando en actualizar el código. Mientras tanto, puedes ignorar esta advertencia ya que:
- ✅ La funcionalidad sigue funcionando
- ✅ Es solo una advertencia de deprecación, no un error
- ✅ iOS 14.0+ sigue soportando estas APIs (aunque deprecadas)

#### Opción 3: Suprimir la advertencia en Xcode

1. Selecciona el proyecto `Runner` en Xcode
2. Ve a **Build Settings**
3. Busca "Other Warning Flags"
4. Agrega: `-Wno-deprecated-declarations`

⚠️ **No recomendado:** Esto oculta todas las advertencias de deprecación.

---

## ⚠️ Problema 4: Problemas con geocoding_ios y geolocator_apple

### Síntoma
```
no rule to process file '/Users/.../geocoding_ios...'
'authorizationStatus' is deprecated: first deprecated in iOS 14.0
Implementing deprecated method
```

### Causa
Problemas similares: APIs deprecadas en los plugins de geolocalización.

### Solución

#### Paso 1: Actualizar los plugins

```bash
flutter pub upgrade geolocator geocoding
```

#### Paso 2: Reinstalar pods

```bash
cd ios
pod install --repo-update
```

#### Paso 3: Actualizar deployment target (si es necesario)

El `Podfile` ya tiene configurado iOS 13.0, pero puedes asegurarte verificando:

```ruby
platform :ios, '13.0'
```

Y en el `post_install`:

```ruby
target.build_configurations.each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
end
```

---

## ⚠️ Problema 5: Deployment Target para iOS Simulator

### Síntoma
```
The iOS Simulator deployment target 'IPHONEOS_DEPLOYMENT_TARGET'...
```

### Causa
Algunos pods tienen un deployment target diferente al proyecto.

### Solución

Ya está configurado en el `Podfile`, pero asegúrate de que el `post_install` esté configurando todos los targets:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

Luego ejecuta:

```bash
cd ios
pod install
```

---

## 🚀 Solución Completa: Pasos Recomendados

Sigue estos pasos en orden para resolver todos los problemas:

### Paso 1: Verificar Flutter y CocoaPods

```bash
# Verificar Flutter
flutter doctor

# Verificar CocoaPods
pod --version

# Si CocoaPods no está instalado:
sudo gem install cocoapods
```

### Paso 2: Limpiar todo

```bash
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
cd ..

flutter clean
flutter pub get
```

### Paso 3: Instalar dependencias

```bash
cd ios
pod install --repo-update
cd ..
```

### Paso 4: Abrir Xcode correctamente

```bash
# Cerrar Xcode si está abierto, luego:
open ios/Runner.xcworkspace
```

### Paso 5: Verificar en Xcode

1. En el navegador izquierdo, verifica que aparezca la carpeta `Pods`
2. Selecciona el proyecto `Runner` (icono azul)
3. Selecciona el target `Runner`
4. Ve a **Build Settings** y busca "Swift Language Version"
5. Debe estar en Swift 5 o superior

### Paso 6: Limpiar build en Xcode

1. En Xcode: **Product** > **Clean Build Folder** (Shift + Cmd + K)
2. Cierra Xcode
3. Vuelve a abrir: `open ios/Runner.xcworkspace`

### Paso 7: Compilar

```bash
# Desde Terminal (recomendado)
flutter run -d ios

# O desde Xcode
# Selecciona un simulador/dispositivo
# Clic en Play (▶️) o Cmd + R
```

---

## ✅ Verificación Final

Después de seguir los pasos, deberías ver:

- ✅ **Sin errores rojos** en el panel de Issues
- ✅ **Carpeta Pods visible** en el navegador izquierdo
- ✅ **GoogleMaps import funciona** correctamente
- ⚠️ **Algunas advertencias amarillas** pueden persistir (normal, vienen de plugins)

---

## 🆘 Si el Error Persiste

### Verificar que GoogleMaps está instalado

```bash
cd ios
pod list | grep -i google
```

Deberías ver:
- `GoogleMaps`
- `google_maps_flutter_ios`

### Verificar configuración del Podfile

Abre `ios/Podfile` y verifica que tenga:

```ruby
platform :ios, '13.0'
use_frameworks!
use_modular_headers!
```

### Verificar que abriste el workspace correcto

**⚠️ CRÍTICO:** Debes abrir `Runner.xcworkspace`, NO `Runner.xcodeproj`

Verifica en el título de Xcode:
- ✅ Correcto: "Runner.xcworkspace"
- ❌ Incorrecto: "Runner.xcodeproj"

---

## 📝 Notas Importantes

### Sobre las Advertencias

Las advertencias de deprecación que vienen de los plugins (`flutter_local_notifications`, `geolocator_apple`, etc.) son normales y:
- ✅ No afectan la funcionalidad
- ✅ Los plugins las están actualizando gradualmente
- ✅ Puedes ignorarlas mientras la app funciona

### Sobre GoogleMaps

El error de GoogleMaps es crítico y debe resolverse antes de compilar. Generalmente se resuelve:
1. Instalando los pods correctamente
2. Asegurándote de abrir el `.xcworkspace`

### Sobre AppIcon

La advertencia de AppIcon es cosmética. Si no quieres verla, puedes limpiar los archivos no usados, pero no es necesario para que la app funcione.

---

## 🔗 Referencias

- [Guía: Abrir en Xcode](GUIA_ABRIR_EN_XCODE.md)
- [Guía: Compilar en Mac](GUIA_COMPILAR_MAC.md)
- [Documentación de CocoaPods](https://guides.cocoapods.org/)

---

**Última actualización:** Enero 2025


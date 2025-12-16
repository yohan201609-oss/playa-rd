# Solución: Error "Command PhaseScriptExecution failed with a nonzero exit code"

## 🔴 Problema

Estás viendo este error al compilar en Xcode:
```
Command PhaseScriptExecution failed with a nonzero exit code
```

Este error ocurre durante la fase de scripts de build y puede tener varias causas.

## ✅ Soluciones (Probar en Orden)

### Solución 1: Limpiar y Reinstalar CocoaPods (Más Común)

```bash
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
pod cache clean --all
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

Luego intenta compilar de nuevo.

---

### Solución 2: Verificar Scripts de Build en Xcode

1. Abre `ios/Runner.xcodeproj` en Xcode
2. Selecciona el proyecto **Runner** en el navegador izquierdo
3. Selecciona el target **Runner**
4. Ve a la pestaña **Build Phases**
5. Busca la sección **"Run Script"** o **"Scripts"**
6. Verifica que los scripts de Flutter estén correctos:
   - Debería haber un script que ejecute `"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build`
   - Verifica que no haya errores de sintaxis

Si hay problemas, puedes:
- Expandir el script para ver el error específico
- Verificar que las rutas sean correctas

---

### Solución 3: Verificar Permisos y Rutas

```bash
# Dar permisos de ejecución a scripts de Flutter
chmod +x "$(which flutter)"
chmod +x "$(flutter --print-sdk-path)/packages/flutter_tools/bin/xcode_backend.sh"

# Verificar que Flutter esté en el PATH
which flutter
flutter doctor -v
```

---

### Solución 4: Limpiar Build Folder de Xcode

1. En Xcode, ve a **Product** → **Clean Build Folder** (⇧⌘K)
2. O desde terminal:
   ```bash
   cd ios
   xcodebuild clean
   cd ..
   ```

---

### Solución 5: Verificar Versión de CocoaPods

```bash
# Verificar versión
pod --version

# Actualizar CocoaPods si es necesario
sudo gem install cocoapods

# Actualizar repositorio de CocoaPods
pod repo update
```

---

### Solución 6: Verificar Configuración de Flutter

```bash
# Verificar que Flutter esté correctamente configurado
flutter doctor -v

# Verificar que no haya problemas con el SDK
flutter --version
```

---

### Solución 7: Reinstalar Dependencias de Flutter

```bash
flutter clean
flutter pub get
cd ios
pod install --repo-update
cd ..
```

---

### Solución 8: Verificar Variables de Entorno

A veces el problema es con variables de entorno. Verifica:

```bash
# Verificar FLUTTER_ROOT
echo $FLUTTER_ROOT

# Si no está configurado, agrégalo a tu .zshrc o .bash_profile
# Agrega esta línea (ajusta la ruta según tu instalación):
# export FLUTTER_ROOT=/path/to/flutter
# export PATH="$FLUTTER_ROOT/bin:$PATH"
```

---

### Solución 9: Verificar Archivos de Configuración

A veces el problema está en archivos de configuración corruptos:

```bash
cd ios
# Eliminar archivos generados
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf Flutter/Generated.xcconfig
rm -rf Flutter/ephemeral

# Regenerar
cd ..
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

---

### Solución 10: Verificar Errores Específicos en Xcode

1. En Xcode, ve a **View** → **Navigators** → **Report Navigator** (⌘9)
2. Busca el build que falló
3. Expande los detalles del error
4. Busca el mensaje de error específico dentro de "PhaseScriptExecution"
5. El error específico te dirá qué script está fallando

---

## 🔍 Diagnóstico Avanzado

### Ver Logs Detallados

En Xcode:
1. Ve a **Product** → **Scheme** → **Edit Scheme**
2. Selecciona **Run** → **Arguments**
3. En **Environment Variables**, agrega:
   - `FLUTTER_BUILD_MODE`: `debug`
   - `VERBOSE_SCRIPT_LOGGING`: `1`
4. Intenta compilar de nuevo y revisa los logs detallados

### Desde Terminal (Más Detallado)

```bash
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  build 2>&1 | tee build.log
```

Luego revisa `build.log` para ver el error específico.

---

## ⚠️ Errores Comunes y Soluciones Específicas

### Error: "No such file or directory: xcode_backend.sh"

**Solución:**
```bash
flutter precache --ios
flutter clean
cd ios
pod install
```

### Error: "Command not found: flutter"

**Solución:**
```bash
# Agregar Flutter al PATH
export PATH="$PATH:/path/to/flutter/bin"
# O reinstalar Flutter
```

### Error: "CocoaPods not installed"

**Solución:**
```bash
sudo gem install cocoapods
pod setup
```

### Error: "Pod install failed"

**Solución:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
```

---

## 🎯 Solución Rápida (Probar Primero)

Si quieres una solución rápida, prueba esto en orden:

```bash
# 1. Limpiar todo
flutter clean
cd ios
rm -rf Pods Podfile.lock .symlinks
pod cache clean --all

# 2. Reinstalar
pod install --repo-update
cd ..

# 3. Obtener dependencias de Flutter
flutter pub get

# 4. Precache de iOS
flutter precache --ios

# 5. Intentar compilar de nuevo
flutter run
```

---

## 📝 Si Nada Funciona

1. **Comparte el error completo**: En Xcode, expande el error de "PhaseScriptExecution" y copia el mensaje completo
2. **Revisa los logs**: Ve a Report Navigator en Xcode y comparte el log completo del build que falló
3. **Verifica Flutter Doctor**: Ejecuta `flutter doctor -v` y comparte la salida

---

**¿Puedes compartir el mensaje de error completo que aparece cuando expandes "PhaseScriptExecution" en Xcode?** Eso me ayudaría a darte una solución más específica.

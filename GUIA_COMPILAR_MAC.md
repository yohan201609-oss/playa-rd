# 🍎 Guía Rápida: Compilar iOS en Mac

**Proyecto:** Playas RD Flutter  
**Fecha:** Enero 2025

---

## 📋 Pasos Rápidos

### ✅ Paso 1: Preparar tu Mac

#### 1.1 Instalar Xcode
```bash
# Abre la Mac App Store y busca "Xcode"
# Descarga e instala Xcode (puede tardar 1-2 horas, ~15 GB)
# Una vez instalado, abre Xcode y acepta la licencia
```

**Verificar instalación:**
```bash
xcode-select --print-path
# Debería mostrar: /Applications/Xcode.app/Contents/Developer
```

#### 1.2 Instalar CocoaPods
```bash
sudo gem install cocoapods
```

**Verificar instalación:**
```bash
pod --version
# Debería mostrar una versión (ej: 1.14.0)
```

#### 1.3 Verificar Flutter
```bash
flutter doctor
```

**Salida esperada:**
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Xcode - develop for iOS and macOS
[✓] CocoaPods version 1.x.x
[!] Android toolchain - not needed for iOS
```

---

### ✅ Paso 2: Transferir el Proyecto a tu Mac

#### Opción A: Usando Git (Recomendado)
```bash
# En tu Mac, abre Terminal
cd ~/Desktop  # o donde quieras guardar el proyecto

# Si ya tienes el proyecto en Git:
git clone <URL_DEL_REPOSITORIO> playas_rd_flutter
cd playas_rd_flutter

# Si no tienes Git configurado, primero configura:
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

#### Opción B: Usando USB/Carpeta Compartida
1. En Windows: Comprime el proyecto en un ZIP (excluye `build/`, `.dart_tool/`, `node_modules/`)
2. Copia el ZIP a tu Mac (USB, red, etc.)
3. En Mac: Descomprime el ZIP
4. Abre Terminal y navega al proyecto:
```bash
cd ~/Downloads/playas_rd_flutter  # o donde lo hayas descomprimido
```

---

### ✅ Paso 3: Instalar Dependencias

#### 3.1 Instalar Dependencias de Flutter
```bash
cd playas_rd_flutter
flutter pub get
```

#### 3.2 Instalar Dependencias de iOS (CocoaPods)
```bash
cd ios
pod install
cd ..
```

**⚠️ Si hay errores:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

**⏱️ Tiempo estimado:** 5-15 minutos (primera vez)

---

### ✅ Paso 4: Configurar el Proyecto en Xcode

#### 4.1 Abrir el Proyecto
```bash
cd playas_rd_flutter
open ios/Runner.xcworkspace
```

**⚠️ IMPORTANTE:** Abre el `.xcworkspace`, NO el `.xcodeproj`

#### 4.2 Configurar el Bundle ID

1. En Xcode, en el navegador izquierdo, selecciona **Runner** (el proyecto azul)
2. Selecciona el target **Runner** (no el proyecto)
3. Ve a la pestaña **General**
4. En **Identity**, cambia **Bundle Identifier** a: `com.playasrd.playasrd`
5. Presiona **Enter** y confirma

#### 4.3 Configurar Signing (Firma)

1. Ve a la pestaña **Signing & Capabilities**
2. Marca **✅ Automatically manage signing**
3. En **Team**, selecciona tu cuenta de Apple:
   - Si no aparece, haz clic en **Add Account...**
   - Ingresa tu Apple ID
   - Acepta los términos si es necesario

**Si no tienes cuenta de desarrollador:**
- Puedes usar tu Apple ID personal (gratis)
- Solo podrás probar en tu dispositivo físico
- No podrás publicar en App Store (necesitas $99 USD/año)

#### 4.4 Configurar Deployment Target

1. En la pestaña **General**, en **Deployment Info**
2. Verifica que **iOS** sea **13.0** o superior
3. Esto debe coincidir con el `Podfile` (ya está configurado en `platform :ios, '13.0'`)

---

### ✅ Paso 5: Verificar Configuraciones

#### 5.1 Verificar GoogleService-Info.plist
```bash
# Verifica que el archivo existe y tiene el Bundle ID correcto
cat ios/Runner/GoogleService-Info.plist | grep BUNDLE_ID
# Debería mostrar: com.playasrd.playasrd
```

#### 5.2 Verificar que AppDelegate tiene Google Maps
```bash
grep -n "GoogleMaps" ios/Runner/AppDelegate.swift
# Debería mostrar la importación y configuración
```

---

### ✅ Paso 6: Compilar y Ejecutar

#### 6.1 Limpiar el Proyecto (Primera Vez)
```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

#### 6.2 Compilar para Simulador
```bash
# Listar simuladores disponibles
xcrun simctl list devices available

# Compilar y ejecutar en simulador
flutter run -d ios

# O selecciona un simulador específico
flutter run -d "iPhone 15 Pro"
```

#### 6.3 Compilar para Dispositivo Físico

1. **Conecta tu iPhone/iPad a la Mac** con cable USB
2. **Confía en la computadora** en tu iPhone (aparecerá un mensaje)
3. **En Xcode:**
   - Selecciona tu dispositivo como destino (arriba, al lado del botón Play)
   - Si aparece "Trust Developer", confía en el certificado
4. **En Terminal:**
```bash
# Listar dispositivos conectados
flutter devices

# Ejecutar en tu dispositivo
flutter run -d <device-id>
```

---

### ✅ Paso 7: Build de Release (Para Publicar)

#### 7.1 Build de Release
```bash
flutter build ios --release
```

**Ubicación del build:**
- `build/ios/iphoneos/Runner.app`

#### 7.2 Archivar en Xcode (Para App Store)

1. Abre Xcode: `open ios/Runner.xcworkspace`
2. Selecciona **Any iOS Device** como destino (no un simulador)
3. Ve a **Product** > **Archive**
4. Espera a que termine (5-10 minutos)
5. Se abrirá **Organizer** automáticamente

#### 7.3 Subir a App Store Connect

1. En **Organizer**, selecciona el archive que acabas de crear
2. Haz clic en **Distribute App**
3. Selecciona **App Store Connect**
4. Sigue los pasos para subir

---

## 🔧 Solución de Problemas Comunes

### Error: "No Podfile found"
```bash
cd ios
pod init  # Solo si no existe Podfile
pod install
```

### Error: "CocoaPods not installed"
```bash
sudo gem install cocoapods
pod setup
```

### Error: "Signing for Runner requires a development team"
- En Xcode, ve a **Signing & Capabilities**
- Selecciona tu **Team** (Apple ID)
- Si no aparece, agrega tu cuenta en **Preferences** > **Accounts**

### Error: "Command PhaseScriptExecution failed"
```bash
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Error: "Google Maps not working"
1. Verifica que la API Key esté configurada en `AppDelegate.swift`
2. Verifica que las APIs estén habilitadas en Google Cloud Console:
   - Maps SDK for iOS
   - Geocoding API
3. Verifica que la API Key tenga restricciones para tu Bundle ID

### Error: "Cannot find 'GoogleMaps' in scope"
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

### La app no se instala en el dispositivo
1. Ve a **Settings** > **General** > **VPN & Device Management** en tu iPhone
2. Confía en tu certificado de desarrollador
3. Vuelve a intentar instalar desde Xcode

### Build muy lento
```bash
# Limpiar caché de Flutter
flutter clean
flutter pub get

# Limpiar caché de CocoaPods
cd ios
rm -rf Pods Podfile.lock ~/Library/Caches/CocoaPods
pod install --repo-update
cd ..
```

---

## 📝 Checklist Antes de Compilar

- [ ] Xcode instalado y licencia aceptada
- [ ] CocoaPods instalado (`pod --version`)
- [ ] Flutter instalado (`flutter doctor`)
- [ ] Proyecto transferido a Mac
- [ ] `flutter pub get` ejecutado sin errores
- [ ] `pod install` ejecutado sin errores
- [ ] Bundle ID configurado en Xcode (`com.playasrd.playasrd`)
- [ ] Signing configurado en Xcode (Team seleccionado)
- [ ] GoogleService-Info.plist presente en `ios/Runner/`
- [ ] AppDelegate.swift tiene configuración de Google Maps
- [ ] Info.plist tiene URL Scheme para Google Sign-In

---

## 🚀 Comandos Rápidos de Referencia

```bash
# Navegar al proyecto
cd playas_rd_flutter

# Limpiar y reinstalar todo
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Abrir en Xcode
open ios/Runner.xcworkspace

# Compilar y ejecutar en simulador
flutter run -d ios

# Compilar release
flutter build ios --release

# Ver dispositivos disponibles
flutter devices

# Verificar configuración
flutter doctor -v
```

---

## 📚 Recursos Adicionales

- [Documentación Flutter iOS](https://docs.flutter.dev/deployment/ios)
- [Guía de Producción iOS](GUIA_PRODUCCION_IOS.md) (en este proyecto)
- [Apple Developer Portal](https://developer.apple.com/account)
- [CocoaPods Documentation](https://guides.cocoapods.org/)

---

## ⚡ Notas Importantes

1. **Primera compilación:** Puede tardar 10-20 minutos mientras descarga dependencias
2. **Espacio en disco:** Asegúrate de tener al menos 20 GB libres
3. **Conexión a internet:** Necesaria para descargar dependencias
4. **Certificados:** Se crean automáticamente si usas "Automatically manage signing"
5. **Bundle ID:** Debe coincidir exactamente con Firebase (`com.playasrd.playasrd`)

---

**¡Éxito compilando en Mac! 🎉**

Si tienes problemas, revisa la sección de "Solución de Problemas" o consulta la guía completa en `GUIA_PRODUCCION_IOS.md`.



# 🍎 Guía: Instalar Flutter en Mac

**Proyecto:** Playas RD Flutter  
**Objetivo:** Instalar Flutter en Mac para compilar iOS

---

## 📋 Requisitos Previos

### 1. macOS
- **Versión mínima:** macOS 10.14 (Mojave) o superior
- **Recomendado:** macOS 12.0 (Monterey) o superior

### 2. Espacio en disco
- **Mínimo:** 5 GB libres
- **Recomendado:** 15-20 GB libres (para Xcode, Flutter, dependencias)

### 3. Conexión a Internet
- Necesaria para descargar Flutter y dependencias

---

## 🚀 Método 1: Instalación Rápida (Recomendado)

### Paso 1: Descargar Flutter

1. **Abre tu navegador** en Mac
2. **Ve a:** https://docs.flutter.dev/get-started/install/macos
3. **Descarga el SDK** de Flutter:
   - Haz clic en "Download Flutter SDK"
   - El archivo será algo como: `flutter_macos_arm64_x.x.x-stable.zip` (para Mac con Apple Silicon)
   - O `flutter_macos_x64_x.x.x-stable.zip` (para Mac Intel)

**💡 Nota:** 
- **Mac M1/M2/M3:** Descarga la versión `arm64`
- **Mac Intel:** Descarga la versión `x64`

### Paso 2: Extraer Flutter

1. **Abre Finder**
2. **Navega a** tu carpeta de usuario (ej: `/Users/tunombre`)
3. **Extrae el ZIP** haciendo doble clic
4. Esto creará una carpeta `flutter`

**Estructura esperada:**
```
/Users/tunombre/flutter/
  ├── bin/
  ├── packages/
  └── ...
```

### Paso 3: Agregar Flutter al PATH

1. **Abre Terminal** (Cmd + Espacio, escribe "Terminal")

2. **Abre tu archivo de configuración del shell:**
   
   Si usas **Zsh** (macOS Catalina y superior - por defecto):
   ```bash
   open ~/.zshrc
   ```
   
   Si usas **Bash** (macOS anterior):
   ```bash
   open ~/.bash_profile
   ```

3. **Agrega estas líneas al final del archivo:**
   ```bash
   export PATH="$PATH:$HOME/flutter/bin"
   ```
   
   **⚠️ IMPORTANTE:** Reemplaza `$HOME/flutter` con la ruta completa donde extrajiste Flutter si no está en tu carpeta home.

4. **Guarda el archivo** (Cmd + S)

5. **Recarga la configuración:**
   ```bash
   source ~/.zshrc
   ```
   O si usas Bash:
   ```bash
   source ~/.bash_profile
   ```

6. **Verifica la instalación:**
   ```bash
   flutter --version
   ```
   
   Deberías ver algo como:
   ```
   Flutter 3.x.x • channel stable
   ```

---

## 🚀 Método 2: Usando Homebrew (Alternativa)

### Paso 1: Instalar Homebrew (si no lo tienes)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Sigue las instrucciones en pantalla.

### Paso 2: Instalar Flutter con Homebrew

```bash
brew install --cask flutter
```

### Paso 3: Verificar instalación

```bash
flutter --version
```

---

## ✅ Verificar Instalación Completa

### Ejecutar Flutter Doctor

```bash
flutter doctor
```

**Salida esperada (después de instalar Xcode):**
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] macOS (versión x.x.x)
[✓] Xcode - develop for iOS and macOS
[✓] CocoaPods version 1.x.x
[✓] Chrome - develop for the web
[!] Android toolchain - not needed for iOS
[!] Visual Studio Code - not required
```

**⚠️ Si ves errores:**
- Sigue las instrucciones que `flutter doctor` te da
- Generalmente te dirá qué instalar o configurar

---

## 📦 Instalar Dependencias Adicionales

### 1. Instalar Xcode

**Método:**
1. Abre **App Store** en Mac
2. Busca "Xcode"
3. Haz clic en "Obtener" / "Instalar"
4. **Tamaño:** ~15 GB - puede tardar 1-2 horas

**Después de instalar:**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 2. Instalar CocoaPods

```bash
sudo gem install cocoapods
```

**Verificar:**
```bash
pod --version
```

### 3. Aceptar Licencia de Xcode

```bash
sudo xcodebuild -license accept
```

---

## 🔧 Configurar Flutter para iOS

### Verificar que Flutter detecta Xcode

```bash
flutter doctor -v
```

Deberías ver:
```
[✓] Xcode - develop for iOS and macOS (Xcode x.x.x)
[✓] CocoaPods version 1.x.x
```

### Configurar el Command Line Tools de Xcode

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

---

## 🧪 Probar la Instalación

### Crear un proyecto de prueba

```bash
# Navegar a donde quieras crear el proyecto
cd ~/Desktop

# Crear proyecto de prueba
flutter create prueba_flutter

# Entrar al proyecto
cd prueba_flutter

# Ejecutar en simulador iOS
flutter run -d ios
```

**Si todo funciona:**
- Se abrirá el simulador de iOS
- Verás la app de ejemplo de Flutter
- ¡Instalación exitosa! 🎉

---

## 📝 Configuración para tu Proyecto Playas RD

Una vez instalado Flutter:

1. **Descomprime tu proyecto** que descargaste de Google Drive
2. **Navega al proyecto:**
   ```bash
   cd ~/Desktop/playas_rd_flutter
   ```
   (O donde lo hayas descomprimido)

3. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

4. **Instalar dependencias de iOS:**
   ```bash
   cd ios
   pod install
   cd ..
   ```

5. **Verificar configuración:**
   ```bash
   flutter doctor
   ```

6. **Compilar:**
   ```bash
   flutter run -d ios
   ```

---

## 🔍 Solución de Problemas

### Error: "Command not found: flutter"

**Solución:**
- Verifica que agregaste Flutter al PATH
- Reinicia Terminal
- Verifica la ruta: `echo $PATH` (debe incluir `/Users/tunombre/flutter/bin`)

### Error: "Xcode not found"

**Solución:**
1. Instala Xcode desde App Store
2. Ejecuta: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
3. Ejecuta: `sudo xcodebuild -runFirstLaunch`

### Error: "CocoaPods not found"

**Solución:**
```bash
sudo gem install cocoapods
```

Si tienes errores con permisos:
```bash
sudo gem install -n /usr/local/bin cocoapods
```

### Error: "No devices available"

**Solución:**
```bash
# Abrir simulador de iOS
open -a Simulator

# O listar dispositivos disponibles
flutter devices
```

### Flutter doctor muestra errores

**Solución:**
- Lee los mensajes de error cuidadosamente
- `flutter doctor` suele dar instrucciones específicas
- Ejecuta los comandos que sugiere

---

## 📚 Recursos Adicionales

- [Documentación oficial de Flutter](https://docs.flutter.dev/get-started/install/macos)
- [Guía de compilación en Mac](GUIA_COMPILAR_MAC.md) (en este proyecto)
- [Foro de Flutter](https://flutter.dev/community)

---

## ✅ Checklist de Instalación

- [ ] macOS actualizado (10.14 o superior)
- [ ] Flutter descargado y extraído
- [ ] Flutter agregado al PATH
- [ ] `flutter --version` funciona
- [ ] Xcode instalado desde App Store
- [ ] Licencia de Xcode aceptada
- [ ] CocoaPods instalado
- [ ] `flutter doctor` muestra todo correcto (o solo advertencias menores)
- [ ] Proyecto de prueba funciona (`flutter create prueba && flutter run`)

---

## 🎯 Comandos Rápidos de Referencia

```bash
# Verificar versión de Flutter
flutter --version

# Verificar configuración completa
flutter doctor

# Ver dispositivos disponibles
flutter devices

# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Compilar para iOS
flutter build ios

# Ejecutar en simulador
flutter run -d ios
```

---

**¡Éxito con la instalación! 🎉**

Una vez completada, sigue la guía `GUIA_COMPILAR_MAC.md` para compilar tu proyecto Playas RD.

---

**Última actualización:** Enero 2025



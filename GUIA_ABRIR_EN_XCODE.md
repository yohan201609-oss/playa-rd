# 🍎 Guía: Abrir Proyecto en Xcode

**Proyecto:** Playas RD Flutter  
**Objetivo:** Abrir correctamente el proyecto iOS en Xcode

---

## ⚠️ IMPORTANTE: Abre el Workspace, NO el Proyecto

Para proyectos Flutter con CocoaPods, **siempre** debes abrir el archivo `.xcworkspace`, **NO** el `.xcodeproj`.

---

## 🚀 Método 1: Desde Terminal (Recomendado)

### Paso 1: Navegar al Proyecto

```bash
cd ~/Desktop/playas_rd_flutter
```

(O la ruta donde descomprimiste tu proyecto)

### Paso 2: Abrir el Workspace

```bash
open ios/Runner.xcworkspace
```

**✅ Este es el archivo correcto a abrir**

---

## 🚀 Método 2: Desde Finder

### Paso 1: Navegar a la Carpeta del Proyecto

1. Abre **Finder**
2. Ve a donde descomprimiste tu proyecto (ej: `Desktop/playas_rd_flutter`)
3. Abre la carpeta `ios`

### Paso 2: Abrir el Workspace

1. Busca el archivo **`Runner.xcworkspace`**
2. Haz **doble clic** en él
3. Se abrirá en Xcode automáticamente

**⚠️ NO abras:**
- ❌ `Runner.xcodeproj` (este NO es el correcto)
- ✅ `Runner.xcworkspace` (este SÍ es el correcto)

---

## 🔍 Cómo Identificar el Archivo Correcto

### ✅ Archivo Correcto: `Runner.xcworkspace`

- **Icono:** Parece una caja azul con esquinas redondeadas
- **Extensión:** `.xcworkspace`
- **Ubicación:** `ios/Runner.xcworkspace`

### ❌ Archivo Incorrecto: `Runner.xcodeproj`

- **Icono:** Parece un documento azul
- **Extensión:** `.xcodeproj`
- **Ubicación:** `ios/Runner.xcodeproj`

**Si abres el `.xcodeproj` en lugar del `.xcworkspace`:**
- ❌ No se cargarán las dependencias de CocoaPods
- ❌ Verás errores de compilación
- ❌ Los plugins de Flutter no funcionarán

---

## ✅ Verificación: ¿Se Abrió Correctamente?

Cuando Xcode se abra, deberías ver:

### En el Navegador Izquierdo:

```
Runner
├── Pods                    ← Debe aparecer esta carpeta
├── Runner
│   ├── AppDelegate.swift
│   ├── Info.plist
│   └── ...
└── Products
```

**✅ Si ves la carpeta `Pods`:** Todo está bien

**❌ Si NO ves la carpeta `Pods`:** Abriste el archivo incorrecto

---

## 🔧 Si No Existe el Workspace

### Crear el Workspace

Si el archivo `Runner.xcworkspace` no existe, necesitas instalar las dependencias primero:

```bash
cd ~/Desktop/playas_rd_flutter
cd ios
pod install
cd ..
```

Esto creará automáticamente el archivo `.xcworkspace`.

Luego abre:
```bash
open ios/Runner.xcworkspace
```

---

## 🛠️ Configuración Inicial en Xcode

### 1. Seleccionar el Target

1. En Xcode, haz clic en el proyecto **Runner** (icono azul, parte superior izquierda)
2. Selecciona el target **Runner** (no el proyecto)
3. Ve a la pestaña **General**

### 2. Configurar Bundle Identifier

1. En **Identity**, busca **Bundle Identifier**
2. Debe ser: `com.playasrd.playasrd`
3. Si no coincide, cámbialo

### 3. Configurar Signing

1. Ve a la pestaña **Signing & Capabilities**
2. Marca **✅ Automatically manage signing**
3. En **Team**, selecciona tu cuenta de Apple:
   - Si no aparece, haz clic en **Add Account...**
   - Ingresa tu Apple ID

### 4. Seleccionar Dispositivo

1. En la parte superior de Xcode, verás un selector de dispositivos
2. Selecciona:
   - **Simulador iOS** (para probar sin dispositivo)
   - O tu **iPhone/iPad** conectado (para probar en dispositivo físico)

---

## 📱 Ejecutar desde Xcode

### Opción 1: Botón Play

1. Selecciona un simulador o dispositivo
2. Haz clic en el botón **▶️ Play** (esquina superior izquierda)
3. O presiona **Cmd + R**

### Opción 2: Desde Terminal (Recomendado para Flutter)

```bash
cd ~/Desktop/playas_rd_flutter
flutter run -d ios
```

Este método es mejor porque:
- ✅ Mantiene el Hot Reload de Flutter
- ✅ Muestra logs de Flutter
- ✅ Permite usar comandos de Flutter

---

## 🔍 Solución de Problemas

### Error: "No such file or directory: Runner.xcworkspace"

**Solución:**
```bash
cd ios
pod install
cd ..
open ios/Runner.xcworkspace
```

### Error: "Workspace was created with a newer version of Xcode"

**Solución:**
- Actualiza Xcode a la última versión desde App Store

### Error: "No signing certificate found"

**Solución:**
1. En Xcode: **Preferences** > **Accounts**
2. Agrega tu Apple ID
3. En **Signing & Capabilities**, selecciona tu Team

### No Aparece la Carpeta Pods

**Problema:** Abriste el `.xcodeproj` en lugar del `.xcworkspace`

**Solución:**
1. Cierra Xcode
2. Abre el archivo correcto: `Runner.xcworkspace`
3. Verifica que aparezca la carpeta Pods

### Xcode No Se Abre

**Solución:**
```bash
# Verificar que Xcode está instalado
xcode-select --print-path

# Si no está, instálalo desde App Store
# Luego ejecuta:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

---

## 📝 Comandos Rápidos de Referencia

```bash
# Navegar al proyecto
cd ~/Desktop/playas_rd_flutter

# Instalar dependencias iOS (si no lo has hecho)
cd ios && pod install && cd ..

# Abrir en Xcode (CORRECTO)
open ios/Runner.xcworkspace

# Compilar y ejecutar desde Terminal
flutter run -d ios

# Listar simuladores disponibles
xcrun simctl list devices

# Abrir simulador manualmente
open -a Simulator
```

---

## ✅ Checklist

Antes de abrir en Xcode, verifica:

- [ ] Proyecto descomprimido en Mac
- [ ] Flutter instalado (`flutter --version`)
- [ ] Xcode instalado
- [ ] CocoaPods instalado (`pod --version`)
- [ ] Dependencias instaladas (`cd ios && pod install`)
- [ ] Abres `Runner.xcworkspace` (NO `.xcodeproj`)
- [ ] Aparece la carpeta `Pods` en Xcode

---

## 🎯 Próximos Pasos Después de Abrir Xcode

1. **Configurar Bundle ID** (debe ser `com.playasrd.playasrd`)
2. **Configurar Signing** (seleccionar tu Team)
3. **Seleccionar simulador o dispositivo**
4. **Compilar** desde Terminal: `flutter run -d ios`

O si prefieres compilar desde Xcode:
1. Selecciona dispositivo/simulador
2. Clic en **▶️ Play** o **Cmd + R**

---

**¡Éxito abriendo en Xcode! 🎉**

Para más detalles sobre compilación, consulta: `GUIA_COMPILAR_MAC.md`

---

**Última actualización:** Enero 2025



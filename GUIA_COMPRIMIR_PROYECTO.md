# 📦 Guía: Comprimir Proyecto para Google Drive

**Proyecto:** Playas RD Flutter  
**Objetivo:** Preparar el proyecto para transferirlo a Mac vía Google Drive

---

## 🎯 Método Rápido (Recomendado)

### Usar el Script Automático

1. **Abre PowerShell** en la carpeta del proyecto:
   ```powershell
   cd D:\playas_rd_flutter
   ```

2. **Ejecuta el script:**
   ```powershell
   .\scripts\preparar_para_transferir.ps1
   ```

3. **El script hará:**
   - ✅ Crear una carpeta limpia del proyecto
   - ✅ Excluir archivos innecesarios
   - ✅ Mostrar el tamaño ahorrado
   - ✅ Opcionalmente comprimir en ZIP

4. **Sube el ZIP a Google Drive** y descárgalo en tu Mac

---

## 📋 Método Manual

Si prefieres hacerlo manualmente, sigue estos pasos:

### Paso 1: Crear Carpeta Limpia

Crea una nueva carpeta llamada `playas_rd_flutter_para_transferir`

### Paso 2: Copiar Archivos (Excluir lo siguiente)

#### ❌ **NO COPIES estas carpetas:**

```
build/                      # Builds (muy pesado, se regenera)
.dart_tool/                 # Herramientas de Dart (se regenera)
ios/Pods/                   # Dependencias CocoaPods (se reinstalan en Mac)
ios/.symlinks/              # Enlaces simbólicos (se regeneran)
ios/Flutter/Flutter.framework/  # Framework de Flutter (se descarga)
android/.gradle/            # Caché de Gradle (muy pesado, se regenera)
android/build/              # Builds de Android (se regenera)
android/app/build/          # Builds de la app Android (se regenera)
functions/node_modules/     # Node modules (se reinstalan)
.git/                       # Historial Git (opcional, puedes incluir si quieres)
```

#### ❌ **NO COPIES estos archivos:**

```
*.log                       # Archivos de log
*.iml                       # Archivos de IDE
.DS_Store                   # Archivos del sistema macOS
Thumbs.db                   # Archivos del sistema Windows
android/local.properties    # Configuración local (contiene rutas de Windows)
android/key.properties      # Credenciales (seguridad)
.env                        # Variables de entorno (puede tener secrets)
```

#### ✅ **SÍ COPIA estos archivos/carpetas:**

```
lib/                        # ✅ Todo tu código Dart
assets/                     # ✅ Assets de la app
android/                    # ✅ Configuración Android (sin build/)
ios/                        # ✅ Configuración iOS (sin Pods/)
web/                        # ✅ Configuración Web
pubspec.yaml                # ✅ Dependencias
pubspec.lock                # ✅ Versiones exactas
analysis_options.yaml       # ✅ Configuración de análisis
README.md                   # ✅ Documentación
*.md                        # ✅ Todas las guías
.gitignore                  # ✅ Ignorar archivos
functions/                  # ✅ Firebase Functions (sin node_modules/)
firebase.json               # ✅ Configuración Firebase
```

---

## 🗜️ Paso 3: Comprimir

### Opción A: Comprimir con Windows (Clic derecho)

1. **Selecciona la carpeta** `playas_rd_flutter_para_transferir`
2. **Clic derecho** > **Enviar a** > **Carpeta comprimida (en ZIP)**
3. **Espera** a que termine (puede tardar unos minutos)

### Opción B: Comprimir con PowerShell

```powershell
# Navega a la carpeta del proyecto
cd D:\playas_rd_flutter

# Comprimir la carpeta limpia
Compress-Archive -Path "playas_rd_flutter_para_transferir" -DestinationPath "playas_rd_flutter.zip" -Force
```

---

## 📊 Tamaños Aproximados

| Versión | Tamaño Estimado |
|---------|----------------|
| **Proyecto completo** (con builds) | ~500 MB - 2 GB |
| **Proyecto limpio** (sin builds) | ~50 - 150 MB |
| **ZIP comprimido** | ~20 - 50 MB |

**💡 Nota:** El tamaño exacto depende de cuántos builds tengas y el contenido de tus assets.

---

## ☁️ Paso 4: Subir a Google Drive

### Método Rápido (Navegador Web)

1. **Abre Google Drive** en tu navegador
2. **Arrastra el archivo ZIP** a Google Drive
3. **Espera** a que termine la subida
4. **Comparte el archivo** contigo mismo (si usas otra cuenta) o descárgalo en Mac

### Método con App de Google Drive

1. **Instala Google Drive** para Windows si no lo tienes
2. **Arrastra el ZIP** a la carpeta de Google Drive
3. Se sincronizará automáticamente
4. **Descarga en Mac** desde Google Drive

---

## 📥 Paso 5: En tu Mac

### Descomprimir

1. **Descarga el ZIP** desde Google Drive
2. **Descomprime** haciendo doble clic
3. **Renombra** la carpeta a `playas_rd_flutter` (sin el sufijo `_para_transferir`)

### Restaurar Dependencias

```bash
cd playas_rd_flutter

# Instalar dependencias de Flutter
flutter pub get

# Instalar dependencias de iOS
cd ios
pod install
cd ..

# Limpiar y verificar
flutter clean
flutter doctor
```

---

## ⚠️ Archivos Importantes a Verificar

Después de descomprimir en Mac, verifica que estos archivos existan:

- ✅ `ios/Runner/GoogleService-Info.plist` - Configuración Firebase iOS
- ✅ `android/app/google-services.json` - Configuración Firebase Android
- ✅ `ios/Podfile` - Dependencias iOS
- ✅ `pubspec.yaml` - Dependencias Flutter
- ✅ `.env` - Variables de entorno (si lo usas, créalo de nuevo)

---

## 🔒 Seguridad

### Archivos que NO debes incluir:

- ❌ `android/key.properties` - Credenciales de firma
- ❌ `*.keystore` o `*.jks` - Archivos de firma
- ❌ `.env` - Puede contener API keys
- ❌ Cualquier archivo con passwords o tokens

### Si necesitas estos archivos en Mac:

1. **Copia manualmente** usando un método seguro (USB, mensaje cifrado)
2. **O recrea** los archivos en Mac (como `.env`)

---

## 🚨 Solución de Problemas

### Error: "El ZIP es muy grande"

**Solución:**
- Asegúrate de excluir la carpeta `build/`
- Asegúrate de excluir `android/.gradle/`
- Asegúrate de excluir `ios/Pods/`
- Usa el script automático para asegurarte de excluir todo

### Error: "No se puede subir a Google Drive"

**Solución:**
- Google Drive tiene límite de 15 GB gratis
- Si el ZIP es muy grande, divídelo con 7-Zip:
  ```powershell
  # Instalar 7-Zip primero, luego:
  7z a -v100m playas_rd_flutter.zip playas_rd_flutter_para_transferir
  ```
- O usa otro servicio: Dropbox, OneDrive, etc.

### Error: "Falta GoogleService-Info.plist en Mac"

**Solución:**
- Este archivo SÍ debe incluirse en el ZIP
- Si no está, descárgalo de Firebase Console
- O cópialo manualmente después de transferir

---

## 📝 Checklist de Verificación

Antes de subir a Google Drive, verifica:

- [ ] La carpeta limpia tiene menos de 200 MB
- [ ] No incluye carpeta `build/`
- [ ] No incluye `android/.gradle/`
- [ ] No incluye `ios/Pods/`
- [ ] Incluye `lib/` con todo tu código
- [ ] Incluye `pubspec.yaml`
- [ ] Incluye `ios/Podfile`
- [ ] Incluye `android/app/google-services.json`
- [ ] Incluye `ios/Runner/GoogleService-Info.plist`
- [ ] El ZIP se creó correctamente
- [ ] El tamaño del ZIP es razonable (< 100 MB)

---

## 🎯 Resumen Rápido

```powershell
# 1. Ejecutar script de limpieza
.\scripts\preparar_para_transferir.ps1

# 2. Comprimir (si no se hizo automáticamente)
Compress-Archive -Path "playas_rd_flutter_para_transferir" -DestinationPath "playas_rd_flutter.zip"

# 3. Subir playas_rd_flutter.zip a Google Drive

# 4. En Mac: Descomprimir y ejecutar:
#    flutter pub get
#    cd ios && pod install && cd ..
```

---

**¡Éxito preparando tu proyecto! 🎉**

Si tienes problemas, revisa la sección "Solución de Problemas" o ejecuta el script automático que hace todo por ti.



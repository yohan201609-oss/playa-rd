# Solución Manual: Error "Failed to Strip Debug Symbols"

Este documento explica cómo resolver manualmente la advertencia sobre el stripping de símbolos de debug.

## 🔍 Problema

El error ocurre porque la ruta del Android SDK contiene espacios (`C:\Users\Johan Almanzar\AppData\Local\Android\sdk`), lo que causa problemas con las herramientas NDK al intentar eliminar símbolos de debug de las librerías nativas.

**Nota importante**: El bundle se genera correctamente a pesar de esta advertencia. Es solo un mensaje informativo.

## ✅ Soluciones Manuales

### Opción 1: Configurar Variables de Entorno del Sistema (Recomendada)

Esta es la solución más limpia y permanente. Configura las variables de entorno del sistema para que todas las herramientas usen la ruta sin espacios.

#### Método A: Usar el Script Automático (Más Fácil)

1. **Ejecutar PowerShell como Administrador:**
   - Busca "PowerShell" en el menú inicio
   - Haz clic derecho y selecciona "Ejecutar como administrador"

2. **Navegar al proyecto y ejecutar:**
   ```powershell
   cd D:\playas_rd_flutter
   .\configurar-android-sdk.ps1
   ```

3. **Reiniciar terminal/IDE:**
   - Cierra y vuelve a abrir todas las ventanas de PowerShell/CMD
   - Cierra y vuelve a abrir tu IDE (VS Code, Android Studio, etc.)

#### Método B: Configuración Manual

1. **Abrir las Variables de Entorno del Sistema:**
   - Presiona `Win + R`
   - Escribe: `sysdm.cpl` y presiona Enter
   - Ve a la pestaña "Opciones avanzadas"
   - Haz clic en "Variables de entorno"

2. **Agregar/Modificar Variables:**
   - En "Variables del sistema", busca `ANDROID_HOME` y `ANDROID_SDK_ROOT`
   - Si existen, edítalas. Si no existen, crea nuevas variables
   - Establece el valor a: `C:\Android\sdk`
   - Haz clic en "Aceptar" en todas las ventanas

3. **Reiniciar el terminal/IDE:**
   - Cierra y vuelve a abrir PowerShell/CMD
   - Cierra y vuelve a abrir tu IDE (VS Code, Android Studio, etc.)

4. **Verificar:**
   ```powershell
   echo $env:ANDROID_HOME
   echo $env:ANDROID_SDK_ROOT
   ```
   Deberían mostrar: `C:\Android\sdk`

### Opción 2: Deshabilitar Stripping de Símbolos en Gradle

Esta opción deshabilita completamente el stripping de símbolos, eliminando la advertencia. **Nota**: Esto hace que el bundle sea ligeramente más grande, pero no afecta la funcionalidad.

Ya está implementada en `android/app/build.gradle.kts` con `debugSymbolLevel = "NONE"`, pero podemos hacerlo más explícito.

### Opción 3: Mover el Android SDK (Más Compleja)

Si prefieres mover físicamente el SDK a una ruta sin espacios:

1. **Cerrar todas las aplicaciones** que usen el Android SDK (Android Studio, VS Code, etc.)

2. **Mover el SDK:**
   ```powershell
   # Crear directorio destino
   New-Item -ItemType Directory -Path "C:\Android" -Force
   
   # Mover el SDK (esto puede tardar varios minutos)
   Move-Item -Path "C:\Users\Johan Almanzar\AppData\Local\Android\sdk" -Destination "C:\Android\sdk"
   ```

3. **Actualizar configuraciones:**
   - `android/local.properties` (ya está actualizado)
   - Variables de entorno del sistema (ver Opción 1)
   - Android Studio: File → Settings → Appearance & Behavior → System Settings → Android SDK → Android SDK Location

4. **Eliminar el symlink anterior:**
   ```powershell
   Remove-Item "C:\Android\sdk" -Force  # Si es un symlink
   ```

## 🎯 Solución Implementada en el Proyecto

Actualmente el proyecto tiene:

1. ✅ **Symlink creado**: `C:\Android\sdk` → SDK real
2. ✅ **local.properties actualizado**: Usa la ruta sin espacios
3. ✅ **Script de build**: `build-appbundle.ps1` configura variables de entorno
4. ✅ **Configuración Gradle**: `debugSymbolLevel = "NONE"` en build.gradle.kts

## 📝 Recomendación

Para eliminar completamente la advertencia, sigue la **Opción 1** (configurar variables de entorno del sistema). Es la solución más limpia y permanente.

Si solo quieres que la advertencia desaparezca sin hacer cambios del sistema, la **Opción 2** ya está parcialmente implementada y podemos mejorarla.


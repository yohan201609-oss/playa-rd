# Guía: Eliminar iPad y Apple Watch - Solo iPhone

## 📋 Respuesta Rápida

**NO necesitas crear una nueva versión de la app**, pero **SÍ necesitas:**
1. Cambiar la configuración en Xcode (o archivo project.pbxproj)
2. Crear un **nuevo build** con esa configuración
3. Subir el nuevo build a App Store Connect

Los cambios de plataformas soportadas se reflejan automáticamente cuando subes el nuevo build.

---

## ✅ Paso 1: Configurar en Xcode (Recomendado)

### Opción A: Desde Xcode (Más Fácil)

1. **Abre el proyecto en Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Selecciona el proyecto "Runner"** en el navegador izquierdo

3. **Selecciona el target "Runner"**

4. **Ve a la pestaña "General"**

5. **En "Deployment Info":**
   - Busca **"Device"** o **"Targeted Device Families"**
   - Desmarca **iPad** y **Apple Watch**
   - Deja solo **iPhone** marcado

6. **Verifica en "Build Settings":**
   - Busca **"Targeted Device Family"** (puede estar en "All")
   - Debe decir solo **"iPhone"** (no "iPhone, iPad")

7. **Guarda los cambios**

---

## ✅ Paso 2: Modificar Archivo Directo (Alternativa)

Si prefieres editar el archivo directamente:

### Cambiar TARGETED_DEVICE_FAMILY

En el archivo `ios/Runner.xcodeproj/project.pbxproj`, busca las 3 ocurrencias de:
```
TARGETED_DEVICE_FAMILY = "1,2";
```

Y cámbialas a:
```
TARGETED_DEVICE_FAMILY = "1";
```

Donde:
- `1` = Solo iPhone
- `2` = iPad
- `1,2` = iPhone + iPad

También elimina las configuraciones específicas de iPad en `Info.plist` si existen.

---

## ✅ Paso 3: Eliminar Configuración de iPad en Info.plist

En `ios/Runner/Info.plist`, elimina o comenta esta sección:

```xml
<!-- ELIMINAR ESTO -->
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

---

## ✅ Paso 4: Limpiar y Recompilar

Después de hacer los cambios:

```bash
# Limpiar
flutter clean

# Reinstalar dependencias
cd ios
pod install
cd ..

# Recompilar
flutter build ios --release
```

---

## ✅ Paso 5: Crear Nuevo Build y Subir

1. **Archivar en Xcode:**
   - Abre `ios/Runner.xcworkspace`
   - Selecciona **"Any iOS Device"** (no simulador)
   - Ve a **Product** → **Archive**

2. **Subir el nuevo build:**
   - En Organizer, selecciona el nuevo archive
   - Haz clic en **Distribute App**
   - Selecciona **App Store Connect**
   - Sigue los pasos

3. **En App Store Connect:**
   - Ve a tu versión (1.0.1)
   - Selecciona el **nuevo build** que acabas de subir
   - Las pestañas de iPad y Apple Watch desaparecerán automáticamente cuando procese el build

---

## ⚠️ Importante

### Si Ya Tienes un Build Subido:

- **NO necesitas crear nueva versión** (1.0.2)
- Puedes usar la **misma versión** (1.0.1)
- Solo sube un **nuevo build** con número mayor (ej: 1.0.1+5)

### Si Aún No Has Subido Nada:

- Puedes hacer los cambios ahora
- Y subir el primer build ya configurado solo para iPhone

---

## 🎯 Resumen

1. ✅ Cambiar configuración en Xcode: Solo iPhone
2. ✅ Limpiar y recompilar
3. ✅ Crear nuevo build (misma versión, nuevo build number)
4. ✅ Subir a App Store Connect
5. ✅ Las pestañas iPad/Apple Watch desaparecerán automáticamente

---

## 📝 Nota sobre Versiones vs Builds

- **Versión de la app** (1.0.1): Lo que ven los usuarios
- **Build number** (4, 5, 6...): Identificador técnico del build

Puedes mantener la misma versión pero incrementar el build number. Por ejemplo:
- Versión anterior: `1.0.1+4`
- Nueva versión: `1.0.1+5` (mismo número de versión, nuevo build)

Para incrementar el build number, edita `pubspec.yaml`:
```yaml
version: 1.0.1+5  # Cambia el número después del +
```

---

## 🔍 Verificar que Funcionó

Después de subir el nuevo build y que Apple lo procese:

1. Ve a App Store Connect → Tu App → Versión
2. **NO deberías ver** las pestañas de "iPad" y "Apple Watch"
3. Solo deberías ver la pestaña de **"iPhone"**

Si aún aparecen, espera unos minutos (Apple tarda en procesar) o verifica que el build se haya subido correctamente.

---

**💡 Consejo:** Es mejor hacer estos cambios antes de publicar, así evitas confusiones. Pero si ya tienes un build, no es problema, solo sube uno nuevo.


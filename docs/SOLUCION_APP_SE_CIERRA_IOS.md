# 🔧 Solución: La App se Cierra al Desconectar el iPhone de la Mac

## ❌ Problema

La app funciona perfectamente cuando el iPhone está conectado a la Mac con Xcode, pero cuando desconectas el dispositivo, la app se cierra automáticamente al intentar abrirla.

## 🔍 Causas Comunes

1. **Certificado de desarrollo no confiado** en el dispositivo
2. **Perfil de aprovisionamiento** no instalado correctamente
3. **Dispositivo no registrado** en el perfil de desarrollo
4. **Certificado expirado** o inválido

---

## ✅ Solución Paso a Paso

### Solución 1: Confiar en el Certificado del Desarrollador (Más Común)

Cuando instalas una app de desarrollo por primera vez, iOS requiere que confíes explícitamente en el certificado.

#### Pasos:

1. **En tu iPhone**, ve a:
   ```
   Settings (Configuración) 
   → General (General) 
   → VPN & Device Management (VPN y Administración de Dispositivos)
   ```
   
   O si no ves "VPN & Device Management", busca:
   ```
   Settings → General → Device Management
   Settings → General → Profiles & Device Management
   Settings → General → Profiles
   ```

2. **Busca tu cuenta de desarrollador** (debería aparecer el nombre/email de la cuenta de Apple Developer que usaste en Xcode)

3. **Toca en la cuenta** y luego toca **"Trust [tu cuenta]"** (Confiar en [tu cuenta])

4. **Confirma** tocando "Trust" nuevamente en el diálogo

5. **Ahora intenta abrir la app** - debería funcionar sin estar conectada a la Mac

---

### Solución 2: Reinstalar con Perfil Correcto

Si la solución 1 no funciona, reinstala la app con el perfil correcto.

#### En Xcode:

1. **Abre tu proyecto** en Xcode:
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. **Verifica la configuración de firma**:
   - Selecciona el proyecto "Runner" en el navegador izquierdo
   - Selecciona el target "Runner"
   - Ve a la pestaña **"Signing & Capabilities"**
   
3. **Configuración recomendada**:
   - ✅ Marca **"Automatically manage signing"** (Gestionar automáticamente la firma)
   - Selecciona tu **Team** (equipo de desarrollador)
   - Verifica que el **Bundle Identifier** sea correcto: `com.playasrd.playasRdFlutter`

4. **Conecta tu iPhone** a la Mac

5. **Selecciona tu dispositivo** como destino (arriba en Xcode)

6. **Limpia el build anterior**:
   - Menú: `Product → Clean Build Folder` (o `Shift + Command + K`)

7. **Reinstala la app**:
   - Desde Xcode: `Product → Run` (o `Command + R`)
   - O desde Flutter: `flutter run --release`

8. **Desconecta el iPhone** y prueba abrir la app

---

### Solución 3: Verificar y Actualizar Perfiles en Xcode

A veces los perfiles están desactualizados.

1. **En Xcode**, ve a:
   ```
   Xcode → Settings (Preferences) 
   → Accounts (Cuentas)
   ```

2. **Selecciona tu cuenta** de Apple Developer

3. **Toca "Download Manual Profiles"** o **"Download All Profiles"**

4. **Espera** a que descargue los perfiles actualizados

5. **Vuelve a compilar e instalar** la app

---

### Solución 4: Compilar en Modo Release

El modo Debug puede tener restricciones. Prueba compilar en modo Release.

#### Desde Flutter:

```bash
# Compilar en modo release para iOS
flutter build ios --release

# Luego instalar desde Xcode
# Abre ios/Runner.xcworkspace en Xcode
# Product → Archive → Distribute App → Development
```

#### O directamente desde Xcode:

1. Cambia el **scheme** de "Debug" a **"Release"**:
   - Arriba en Xcode, junto al botón de play
   - Selecciona "Runner" → "Edit Scheme..."
   - En "Run", cambia "Build Configuration" de "Debug" a "Release"

2. **Compila e instala** nuevamente

---

### Solución 5: Registrar el Dispositivo Correctamente

Asegúrate de que tu iPhone esté registrado en tu cuenta de desarrollador.

1. **Obtén el UDID** de tu iPhone:
   - Conecta a la Mac
   - Abre Finder (o iTunes en versiones antiguas)
   - Selecciona tu iPhone
   - Haz clic en el número de serie para ver el UDID

2. **Registra el dispositivo**:
   - Ve a [Apple Developer Portal](https://developer.apple.com/account)
   - Certificates, Identifiers & Profiles → Devices
   - Agrega tu dispositivo con el UDID

3. **Xcode debería detectar automáticamente** el dispositivo cuando lo conectes

---

### Solución 6: Eliminar y Reinstalar la App

A veces hay conflictos con instalaciones anteriores.

1. **En tu iPhone**, elimina la app completamente:
   - Mantén presionado el ícono de la app
   - Toca "Remove App" → "Delete App"

2. **En Xcode**, limpia los perfiles:
   - Ve a: `~/Library/MobileDevice/Provisioning Profiles`
   - Elimina los perfiles antiguos (opcional, Xcode los regenerará)

3. **Limpia el build**:
   ```bash
   cd ios
   rm -rf build
   flutter clean
   ```

4. **Reinstala** desde Xcode o Flutter

---

## 🔍 Verificación Rápida

### Checklist:

- [ ] ¿Confiaste en el certificado del desarrollador en Settings?
- [ ] ¿Tu iPhone está registrado en Apple Developer?
- [ ] ¿El perfil de aprovisionamiento está actualizado?
- [ ] ¿Compilaste en modo Release?
- [ ] ¿Eliminaste e reinstalaste la app?

---

## 🚀 Método Más Rápido (Recomendado)

Si necesitas una solución rápida, sigue estos pasos en orden:

1. **Confiar en el certificado** (Solución 1) - Esto resuelve el 90% de los casos
2. Si no funciona, **reinstalar con perfil correcto** (Solución 2)
3. Si aún no funciona, **compilar en Release** (Solución 4)

---

## 📱 Compilar para Distribución Real (TestFlight/Ad-Hoc)

Si quieres una versión que funcione completamente independiente, compila para distribución:

```bash
# Compilar para TestFlight/App Store
flutter build ipa --release
```

Esta versión funcionará completamente independiente sin necesidad de conexión a la Mac.

---

## ❓ Preguntas Frecuentes

**P: ¿Por qué funciona conectada pero no desconectada?**
R: Porque cuando está conectada, Xcode puede verificar el certificado directamente. Cuando está desconectada, iOS necesita que hayas confiado explícitamente en el certificado del desarrollador.

**P: ¿Necesito hacer esto cada vez que instalo la app?**
R: No, solo la primera vez. Una vez que confías en el certificado, las futuras instalaciones funcionarán normalmente.

**P: ¿La app seguirá funcionando después de 7 días?**
R: Apps en modo Debug pueden expirar después de 7 días. Para una versión permanente, usa TestFlight o compila en Release con un perfil de distribución.

**P: ¿Puedo compartir esta app con otros usuarios?**
R: No directamente. Para compartir, usa TestFlight o distribución Ad-Hoc (ver `DISTRIBUCION_IOS.md`).

---

## 📞 Si Nada Funciona

Si ninguna solución funciona:

1. Verifica que tienes una **cuenta de desarrollador activa** ($99/año)
2. Verifica que tu **iPhone esté desbloqueado** y no tenga restricciones
3. Intenta en **otro dispositivo iOS** para ver si es específico del dispositivo
4. Considera usar **TestFlight** para distribución real

---

**Nota**: Este problema es muy común y la Solución 1 (confiar en el certificado) generalmente lo resuelve en la mayoría de los casos. 🎯











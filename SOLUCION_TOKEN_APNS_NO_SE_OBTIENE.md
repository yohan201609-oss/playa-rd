# Solución: Token APNS No Se Obtiene - Diagnóstico Paso a Paso

## 🔴 Problema Actual

Estás viendo este error repetidamente:
```
⚠️ Error obteniendo token FCM (intento X): [firebase_messaging/apns-token-not-set] 
APNS token has not been set yet. Please ensure the APNS token is available by calling getAPNSToken().
```

## ✅ Verificación: Estado Actual de tu Configuración

He verificado que tienes:
- ✅ `Runner.entitlements` existe y contiene `aps-environment: development`
- ✅ Clave APNS configurada en Firebase Console (Key ID: MIGTAgEAMB, Team ID: C3TZFSL98Z)
- ✅ `Info.plist` tiene `UIBackgroundModes` con `remote-notification`

## 🔍 Diagnóstico: Causas Más Comunes

### Causa 1: App Ejecutándose en el Simulador (MUY COMÚN)

**❌ PROBLEMA:** Las notificaciones push NO funcionan en el simulador de iOS. Solo funcionan en dispositivos físicos.

**✅ SOLUCIÓN:**
1. **Ejecuta la app en un dispositivo físico iOS**:
   ```bash
   # Conecta tu iPhone/iPad por USB
   flutter devices  # Verifica que aparezca tu dispositivo
   flutter run -d <device-id>  # Ejecuta en el dispositivo físico
   ```

2. **Verifica en Xcode:**
   - Abre `ios/Runner.xcworkspace` en Xcode
   - En la barra superior, asegúrate de seleccionar un **dispositivo físico** (no "iPhone Simulator")
   - Si solo ves simuladores, conecta tu dispositivo por USB

---

### Causa 2: Permisos de Notificación No Concedidos

**❌ PROBLEMA:** Si los permisos de notificación no están concedidos, iOS no generará el token APNS.

**✅ SOLUCIÓN:**

1. **Verifica en el dispositivo iOS:**
   - Ve a **Configuración** → **Playas RD** → **Notificaciones**
   - Asegúrate de que las notificaciones estén **HABILITADAS**
   - Los permisos deben estar en "Permitir notificaciones"

2. **Si los permisos están deshabilitados:**
   - Desinstala la app completamente del dispositivo
   - Reinstala la app: `flutter run`
   - Cuando la app solicite permisos de notificación, selecciona **"Permitir"**

3. **Verifica en los logs si se solicitan permisos:**
   - Busca en los logs: `✅ Permisos de notificación concedidos`
   - O: `❌ Permisos de notificación denegados`

---

### Causa 3: Capabilities No Configuradas Correctamente en Xcode

**❌ PROBLEMA:** Aunque el archivo `Runner.entitlements` existe, Xcode necesita que las Capabilities estén habilitadas en el proyecto.

**✅ SOLUCIÓN - Verificar en Xcode:**

1. **Abre el proyecto en Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ **IMPORTANTE:** Abre el `.xcworkspace`, NO el `.xcodeproj`

2. **En Xcode:**
   - Selecciona el proyecto **Runner** en el navegador izquierdo
   - Selecciona el target **Runner**
   - Ve a la pestaña **"Signing & Capabilities"**

3. **Verifica que estén habilitadas:**
   - ✅ **Push Notifications** debe aparecer en la lista de capabilities
   - ✅ **Background Modes** debe aparecer en la lista de capabilities
     - Dentro de Background Modes, debe estar marcado: **"Remote notifications"**

4. **Si NO están habilitadas:**
   - Haz clic en **"+ Capability"** (botón arriba a la izquierda)
   - Busca y agrega **"Push Notifications"**
   - Busca y agrega **"Background Modes"** (si no está)
   - Dentro de Background Modes, marca **"Remote notifications"**

5. **Verifica el archivo de entitlements:**
   - En el navegador de Xcode, deberías ver `Runner.entitlements`
   - Al seleccionarlo, debe mostrar:
     ```xml
     <key>aps-environment</key>
     <string>development</string>
     ```

---

### Causa 4: Firma de la App Incorrecta

**❌ PROBLEMA:** El entitlement `aps-environment` solo funciona si la app está firmada correctamente.

**✅ SOLUCIÓN - Verificar Firma:**

1. **En Xcode → Signing & Capabilities:**
   - ✅ **Automatically manage signing** debe estar marcado
   - ✅ **Team** debe estar seleccionado (debería mostrar: "C3TZFSL98Z" o tu nombre de equipo)
   - ✅ **Bundle Identifier** debe ser: `com.playasrd.playasrd`
   - ✅ **NO debe haber errores rojos** de signing

2. **Si hay errores de firma:**
   - Ve a **Xcode** → **Preferences** → **Accounts**
   - Selecciona tu cuenta de Apple Developer
   - Haz clic en **"Download Manual Profiles"**
   - Vuelve a **Signing & Capabilities**
   - Selecciona el **Team** correcto
   - Si persiste, intenta:
     - Desmarcar y volver a marcar **"Automatically manage signing"**
     - Limpiar el proyecto: **Product** → **Clean Build Folder** (⇧⌘K)

---

### Causa 5: App Recién Instalada o Primera Ejecución

**❌ PROBLEMA:** A veces el token APNS tarda unos segundos en generarse, especialmente en la primera ejecución.

**✅ SOLUCIÓN:**

1. **Espera 15-30 segundos** después de iniciar la app
2. **Verifica en los logs** si aparece el token después de un tiempo:
   - Busca: `✅ Token APNS obtenido (retrasado): [token]`
3. **Si no aparece después de 30 segundos**, revisa las otras causas

---

### Causa 6: Dispositivo Sin Conexión a Internet

**❌ PROBLEMA:** El token APNS requiere conexión a internet para comunicarse con los servidores de Apple.

**✅ SOLUCIÓN:**

1. **Verifica que el dispositivo tenga internet** (WiFi o datos móviles)
2. **Prueba abrir Safari** en el dispositivo para confirmar conexión
3. **Reejecuta la app** después de confirmar conexión

---

### Causa 7: Bundle ID No Coincide

**❌ PROBLEMA:** El Bundle ID en Xcode no coincide con el de Firebase o Apple Developer.

**✅ SOLUCIÓN - Verificar Bundle ID:**

1. **En Xcode → Signing & Capabilities:**
   - El **Bundle Identifier** debe ser exactamente: `com.playasrd.playasrd`

2. **En Firebase Console:**
   - Ve a **Project Settings** → **General**
   - Verifica que la app iOS tenga Bundle ID: `com.playasrd.playasrd`

3. **En Apple Developer Portal:**
   - Ve a [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list)
   - Verifica que el App ID sea: `com.playasrd.playasrd`
   - Y que tenga **Push Notifications** habilitado en las capabilities

---

## 📋 Checklist de Diagnóstico Rápido

Usa esta lista para identificar rápidamente el problema:

### ✅ Paso 1: Dispositivo Físico
- [ ] La app está ejecutándose en un **dispositivo físico iOS** (NO simulador)
- [ ] El dispositivo está conectado por USB
- [ ] El dispositivo aparece cuando ejecutas: `flutter devices`

### ✅ Paso 2: Permisos de Notificación
- [ ] En el dispositivo: **Configuración** → **Playas RD** → **Notificaciones** está **HABILITADO**
- [ ] Los logs muestran: `✅ Permisos de notificación concedidos`
- [ ] NO aparece: `❌ Permisos de notificación denegados`

### ✅ Paso 3: Xcode Capabilities
- [ ] **Push Notifications** capability está agregada en Xcode
- [ ] **Background Modes** capability está agregada
- [ ] Dentro de Background Modes, **"Remote notifications"** está marcado
- [ ] `Runner.entitlements` existe y muestra `aps-environment: development`

### ✅ Paso 4: Firma de la App
- [ ] **Automatically manage signing** está marcado
- [ ] **Team** está seleccionado correctamente
- [ ] **NO hay errores rojos** en Signing & Capabilities
- [ ] Bundle Identifier es: `com.playasrd.playasrd`

### ✅ Paso 5: Configuración en Firebase
- [ ] Clave APNS de desarrollo está configurada (✅ Ya la tienes: MIGTAgEAMB)
- [ ] Bundle ID en Firebase coincide: `com.playasrd.playasrd`
- [ ] `GoogleService-Info.plist` está en el proyecto

### ✅ Paso 6: Tiempo de Espera
- [ ] Esperaste **al menos 15-30 segundos** después de iniciar la app
- [ ] Revisaste los logs completos buscando el token APNS

### ✅ Paso 7: Conexión a Internet
- [ ] El dispositivo tiene conexión a internet (WiFi o datos)
- [ ] Puedes abrir Safari y navegar normalmente

---

## 🚀 Pasos para Resolver (En Orden de Prioridad)

### Paso 1: Verificar que Estás en Dispositivo Físico

```bash
# Listar dispositivos disponibles
flutter devices

# Si ves tu iPhone/iPad, ejecuta:
flutter run -d <device-id>

# Si solo ves simuladores, conecta tu dispositivo por USB y espera a que aparezca
```

### Paso 2: Verificar y Configurar Capabilities en Xcode

1. Abre Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Ve a **Signing & Capabilities**

3. Agrega las capabilities si faltan:
   - **Push Notifications**
   - **Background Modes** → Marca "Remote notifications"

4. Verifica que no haya errores de signing

### Paso 3: Limpiar y Recompilar

```bash
# Limpiar todo
flutter clean

# Reinstalar dependencias iOS
cd ios
pod install
cd ..

# Recompilar y ejecutar en dispositivo físico
flutter run
```

### Paso 4: Verificar Permisos en el Dispositivo

1. En tu iPhone/iPad:
   - Ve a **Configuración** → **Playas RD** → **Notificaciones**
   - Asegúrate de que estén **HABILITADAS**

2. Si no están habilitadas:
   - Desinstala la app
   - Reinstala: `flutter run`
   - Cuando pida permisos, selecciona **"Permitir"**

### Paso 5: Monitorear Logs Completos

Ejecuta la app y observa los logs. Deberías ver (en orden):

```
✅ Permisos de notificación concedidos
🍎 iOS detectado: obteniendo token APNS primero...
✅ Token APNS obtenido en intento X: [token]
📱 Token FCM: [token]
```

Si ves errores, identifica en qué paso falla y revisa la causa correspondiente arriba.

---

## 🔧 Comandos Útiles para Diagnóstico

### Ver Logs Detallados de Flutter
```bash
flutter run -v  # Modo verbose para ver más detalles
```

### Verificar Entitlements
```bash
# Verificar que el entitlement esté en el archivo
cat ios/Runner/Runner.entitlements

# Debería mostrar:
# <key>aps-environment</key>
# <string>development</string>
```

### Limpiar Build de iOS
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

---

## ⚠️ Notas Importantes

1. **Simulador iOS:** Las notificaciones push NO funcionan en el simulador. Debes usar un dispositivo físico.

2. **Primera ejecución:** El token APNS puede tardar 10-30 segundos en generarse, especialmente la primera vez.

3. **Permisos:** Si denegaste los permisos la primera vez, necesitas desinstalar y reinstalar la app para que vuelva a pedirlos.

4. **Build Configuration:** Asegúrate de que estás usando un build de desarrollo (no Release) para que coincida con `aps-environment: development`.

5. **Xcode Workspace:** Siempre abre `Runner.xcworkspace`, NO `Runner.xcodeproj` (el .workspace incluye las dependencias de CocoaPods).

---

## 📞 Si Nada Funciona

Si después de verificar todo lo anterior el problema persiste:

1. **Verifica los logs completos** de Xcode (no solo Flutter):
   - Abre Xcode → **Window** → **Devices and Simulators**
   - Selecciona tu dispositivo
   - Abre la consola de logs
   - Busca errores relacionados con APNS, entitlements, o signing

2. **Verifica en Apple Developer Portal:**
   - [developer.apple.com/account/resources/identifiers/list](https://developer.apple.com/account/resources/identifiers/list)
   - Asegúrate de que el App ID `com.playasrd.playasrd` existe
   - Y que tiene **Push Notifications** habilitado

3. **Prueba crear un nuevo perfil de provisioning:**
   - En Apple Developer Portal, crea un nuevo perfil de desarrollo
   - Descárgalo y úsalo en Xcode

4. **Considera usar TestFlight:**
   - A veces un build de TestFlight ayuda a diagnosticar problemas de configuración

---

**Recuerda:** El problema más común es ejecutar la app en el simulador. Asegúrate de estar usando un **dispositivo físico iOS**.


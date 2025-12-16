# ✅ Checklist Rápido: Token APNS No Se Obtiene

## 🔍 Diagnóstico Rápido - Verifica en Este Orden

### 1️⃣ ¿Estás usando un DISPOSITIVO FÍSICO?

**❌ PROBLEMA #1 MÁS COMÚN:** Las notificaciones push NO funcionan en el simulador iOS.

**Verificar:**
```bash
flutter devices
```

**Debes ver algo como:**
```
1 connected device:
iPhone de [Tu Nombre] (mobile) • [ID] • ios • iOS 17.0
```

**Si solo ves:**
```
iPhone 15 Pro Simulator (mobile) • [ID] • ios • iOS 17.0
```

**❌ Estás en el simulador. Las notificaciones NO funcionarán.**

**✅ SOLUCIÓN:**
1. Conecta tu iPhone/iPad por USB
2. Espera a que aparezca en `flutter devices`
3. Ejecuta: `flutter run -d <device-id>`

---

### 2️⃣ ¿Los PERMISOS de Notificación Están Concedidos?

**Verificar en el dispositivo iOS:**
1. Ve a **Configuración** → **Playas RD** → **Notificaciones**
2. Debe estar **HABILITADO** (verde)
3. Debe decir "Permitir notificaciones"

**Si NO están habilitados:**
1. **Desinstala la app** completamente del dispositivo
2. **Reinstala**: `flutter run`
3. Cuando la app pida permisos, selecciona **"Permitir"**

**Buscar en los logs:**
- ✅ Deberías ver: `✅ Permisos de notificación concedidos`
- ❌ Si ves: `❌ Permisos de notificación denegados` → Problema identificado

---

### 3️⃣ ¿Las CAPABILITIES Están Configuradas en Xcode?

**Abrir Xcode:**
```bash
open ios/Runner.xcworkspace
```

**Verificar:**
1. Selecciona proyecto **Runner** (navegador izquierdo)
2. Selecciona target **Runner**
3. Ve a pestaña **"Signing & Capabilities"**

**Debes ver:**
- ✅ **Push Notifications** en la lista de capabilities
- ✅ **Background Modes** en la lista de capabilities
  - Dentro de Background Modes, debe estar marcado: **"Remote notifications"**

**Si NO están:**
1. Haz clic en **"+ Capability"**
2. Agrega **"Push Notifications"**
3. Agrega **"Background Modes"** (si no está)
4. Dentro de Background Modes, marca **"Remote notifications"**

**Verificar entitlements:**
- En el navegador de Xcode, busca `Runner.entitlements`
- Debe contener:
  ```xml
  <key>aps-environment</key>
  <string>development</string>
  ```

---

### 4️⃣ ¿La App Está Firmada Correctamente?

**En Xcode → Signing & Capabilities:**
- ✅ **Automatically manage signing** debe estar marcado
- ✅ **Team** debe estar seleccionado (debería mostrar tu nombre o ID)
- ✅ **NO debe haber errores rojos** de signing

**Si hay errores:**
1. Ve a **Xcode** → **Preferences** → **Accounts**
2. Selecciona tu cuenta de Apple
3. Haz clic en **"Download Manual Profiles"**
4. Vuelve a **Signing & Capabilities** y selecciona el Team

---

### 5️⃣ ¿GoogleService-Info.plist Está en el Proyecto?

**Verificar:**
1. En Xcode, busca `GoogleService-Info.plist` en el navegador
2. Debe estar en la carpeta **Runner**
3. Al seleccionarlo, en el panel derecho (File Inspector):
   - **Target Membership** debe tener marcado **"Runner"**

**Si no está:**
1. Descárgalo de Firebase Console:
   - Firebase Console → Project Settings → General
   - Descarga `GoogleService-Info.plist` para iOS
2. Arrástralo a `ios/Runner/` en Xcode
3. Asegúrate de marcar "Copy items if needed" y "Runner" en Target Membership

---

### 6️⃣ ¿Has Limpiado y Recompilado?

**Después de hacer cambios en Xcode, SIEMPRE limpia:**

```bash
flutter clean
cd ios
pod install
cd ..
flutter run
```

---

## 🎯 Solución Rápida (Probable Causa)

**Basándome en tu error, lo más probable es:**

1. ✅ **Estás en el SIMULADOR** → Cambia a dispositivo físico
2. ✅ **Permisos NO concedidos** → Reinstala la app y concede permisos
3. ✅ **Capabilities NO configuradas** → Abre Xcode y agrega Push Notifications

---

## 📝 Logs Esperados (Si Todo Funciona)

Cuando todo esté configurado correctamente, deberías ver:

```
✅ Permisos de notificación concedidos
🍎 iOS detectado: obteniendo token APNS primero...
✅ Token APNS obtenido en intento X: [token_apns]
📱 Token FCM: [token_fcm]
✅ NotificationService inicializado correctamente
```

---

## ⚡ Comandos Útiles

### Ver dispositivos disponibles
```bash
flutter devices
```

### Limpiar y recompilar
```bash
flutter clean
cd ios && pod install && cd ..
flutter run
```

### Ver logs detallados
```bash
flutter run -v
```

### Abrir en Xcode
```bash
open ios/Runner.xcworkspace
```

---

## 🆘 Si Nada Funciona

1. **Verifica los logs completos de Xcode:**
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

---

**💡 Consejo:** El 90% de los casos se resuelven verificando los 3 primeros puntos (dispositivo físico, permisos, y capabilities en Xcode).


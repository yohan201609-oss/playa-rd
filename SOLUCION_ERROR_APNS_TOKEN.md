# Solución: Error "APNS token has not been set yet" y "aps-environment"

## 🔴 Problemas Detectados

De los logs veo estos errores críticos:

1. ❌ `no se encontró ninguna cadena de autorización "aps-environment" para la app`
2. ❌ `APNS token has not been set yet. Please ensure the APNS token is available by calling getAPNSToken()`
3. ❌ `Could not locate configuration file: 'GoogleService-Info.plist'`
4. ❌ No aparece el token FCM en los logs

## ✅ Solución 1: Configurar Entitlement de APNS en Xcode (CRÍTICO)

El error `aps-environment` se soluciona configurando el entitlement en Xcode:

### Paso 1: Abrir el Proyecto en Xcode

1. Abre `ios/Runner.xcodeproj` en Xcode
2. Selecciona el proyecto **Runner** en el navegador izquierdo
3. Selecciona el target **Runner**
4. Ve a la pestaña **Signing & Capabilities**

### Paso 2: Agregar Push Notifications Capability

1. Haz clic en **"+ Capability"** (botón en la esquina superior izquierda)
2. Busca y agrega **"Push Notifications"**
3. Esto automáticamente agregará el entitlement `aps-environment`

### Paso 3: Verificar Background Modes

1. En la misma pestaña, verifica que **"Background Modes"** esté habilitado
2. Si no está, agrégalo también
3. Dentro de Background Modes, marca:
   - ✅ **Remote notifications**

### Paso 4: Verificar que se Creó el Entitlement

1. Deberías ver un archivo `Runner.entitlements` en el navegador de Xcode
2. Debe contener:
   ```xml
   <key>aps-environment</key>
   <string>development</string>
   ```
   O para producción:
   ```xml
   <key>aps-environment</key>
   <string>production</string>
   ```

---

## ✅ Solución 2: Verificar GoogleService-Info.plist

El error indica que no se encuentra `GoogleService-Info.plist`:

### Verificar Ubicación

1. El archivo debe estar en: `ios/Runner/GoogleService-Info.plist`
2. Abre Xcode y verifica que el archivo esté en el proyecto
3. Si no está, descárgalo de Firebase Console:
   - Ve a Firebase Console → Project Settings → General
   - Descarga el `GoogleService-Info.plist` para iOS
   - Arrástralo a `ios/Runner/` en Xcode
   - Asegúrate de que esté agregado al target "Runner"

### Verificar que Está en el Target

1. Selecciona `GoogleService-Info.plist` en Xcode
2. En el panel derecho, ve a **File Inspector**
3. Verifica que **"Target Membership"** tenga marcado **"Runner"**

---

## ✅ Solución 3: Deshabilitar App Check Temporalmente

Mientras solucionas DeviceCheck, deshabilita App Check para que las notificaciones funcionen:

1. Ve a Firebase Console → **App Check**
2. Encuentra **"Playas RD IOS"**
3. Haz clic en el menú (⋮) → **"Unenforce"** o **"No aplicar"**

Esto permitirá que la app funcione sin App Check mientras solucionas el problema de DeviceCheck.

---

## ✅ Solución 4: Verificar Firma de la App

El entitlement `aps-environment` solo funciona si la app está firmada correctamente:

### En Xcode

1. Ve a **Signing & Capabilities**
2. Verifica:
   - ✅ **Automatically manage signing** está marcado
   - ✅ **Team** está seleccionado (C3TZFSL98Z)
   - ✅ **Bundle Identifier** es `com.playasrd.playasrd`
   - ✅ No hay errores de firma

### Si hay Errores de Firma

1. Ve a **Preferences** → **Accounts**
2. Selecciona tu cuenta de Apple
3. Haz clic en **Download Manual Profiles**
4. Vuelve a **Signing & Capabilities**
5. Selecciona el perfil correcto

---

## 🔧 Código Actualizado

Ya actualicé el código en `notification_service.dart` para:
- Intentar obtener el token APNS primero (requerido en iOS)
- Manejar errores de manera más robusta
- Intentar obtener el token FCM con retraso si falla la primera vez

---

## 📋 Checklist de Verificación

Después de aplicar las soluciones, verifica:

- [ ] **Push Notifications** capability agregada en Xcode
- [ ] **Background Modes** con **Remote notifications** habilitado
- [ ] `Runner.entitlements` contiene `aps-environment`
- [ ] `GoogleService-Info.plist` está en `ios/Runner/` y agregado al target
- [ ] La app está firmada correctamente (sin errores en Signing & Capabilities)
- [ ] App Check deshabilitado temporalmente (o configurado correctamente)

---

## 🚀 Después de Aplicar las Soluciones

1. **Limpia y recompila**:
   ```bash
   flutter clean
   cd ios
   pod install
   cd ..
   flutter run
   ```

2. **Revisa los logs** - Deberías ver:
   - ✅ `Token APNS obtenido: [token]`
   - ✅ `Token FCM: [token]`
   - ✅ Sin errores de `aps-environment`
   - ✅ Sin errores de `GoogleService-Info.plist`

3. **Prueba las notificaciones** desde Firebase Console

---

## ⚠️ Notas Importantes

1. **aps-environment**:
   - `development`: Para builds de desarrollo y TestFlight (con builds de desarrollo)
   - `production`: Para builds de producción y TestFlight (con builds de producción)

2. **GoogleService-Info.plist**: Debe estar siempre en el proyecto y agregado al target. Sin él, Firebase no puede inicializar correctamente.

3. **App Check**: Aunque deshabilitado temporalmente, es recomendable solucionarlo para producción. Pero para pruebas de notificaciones, puedes dejarlo deshabilitado.

---

**El problema más crítico es el entitlement `aps-environment`. Sin él, las notificaciones push NO funcionarán en iOS.**

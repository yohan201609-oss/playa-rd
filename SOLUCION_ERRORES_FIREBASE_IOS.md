# Solución: Errores de Firebase en iOS

## 🔴 Problemas Detectados en los Logs

### 1. **Error Crítico: Falta GoogleService-Info.plist**

```
Could not locate configuration file: 'GoogleService-Info.plist'
```

**Causa:** El archivo de configuración de Firebase para iOS no está presente en el proyecto.

**Solución:**

1. **Descargar GoogleService-Info.plist desde Firebase Console:**
   - Ve a [Firebase Console](https://console.firebase.google.com)
   - Selecciona tu proyecto: **playas-rd-2b475**
   - Haz clic en el ícono de configuración (⚙️) → **Configuración del proyecto**
   - En la sección "Tus apps", encuentra la app iOS: **Playas RD iOS**
   - Haz clic en **"Descargar GoogleService-Info.plist"**

2. **Agregar el archivo al proyecto:**
   - Copia el archivo descargado a: `/Users/gabrielsaladin/Desktop/playa-rd/ios/Runner/`
   - Abre Xcode
   - Arrastra el archivo `GoogleService-Info.plist` al proyecto en Xcode
   - Asegúrate de que esté marcado para el target "Runner"
   - Verifica que esté en el grupo "Runner" (no en otro grupo)

3. **Verificar que esté incluido en el build:**
   - En Xcode, selecciona el archivo `GoogleService-Info.plist`
   - En el panel derecho, verifica que "Target Membership" tenga marcado "Runner"

---

### 2. **Error de App Check: HTTP 403**

```
AppCheck failed: HTTP status code: 403
Token: 496414DA-728C-4611-821B-CB2FB3FC96EE
```

**Causa:** El token de depuración de App Check no está registrado en Firebase Console.

**Solución:**

1. **Registrar el Debug Token en Firebase Console:**
   - Ve a [Firebase Console](https://console.firebase.google.com)
   - Selecciona tu proyecto: **playas-rd-2b475**
   - Ve a **App Check** → **Apps**
   - Encuentra **"Playas RD iOS"**
   - Haz clic en el menú (⋮) junto a **"DeviceCheck"**
   - Selecciona **"Administrar tokens de depuración"** (Manage debug tokens)
   - Haz clic en **"Agregar token de depuración"** o **"Add debug token"**
   - Pega el token: `496414DA-728C-4611-821B-CB2FB3FC96EE`
   - Haz clic en **"Guardar"** o **"Save"**

2. **Verificar que funcione:**
   - Recompila la app: `flutter clean && flutter run`
   - El error 403 debería desaparecer

---

### 3. **Advertencia: Falta aps-environment**

```
no se encontró ninguna cadena de autorización "aps-environment"
```

**Causa:** Falta la configuración de notificaciones push en los entitlements de iOS.

**Solución:**

1. **Verificar/Crear el archivo de entitlements:**
   - Abre Xcode
   - En el proyecto, ve a **Runner** → **Signing & Capabilities**
   - Verifica que **"Push Notifications"** esté habilitado
   - Si no está, haz clic en **"+ Capability"** y agrega **"Push Notifications"**

2. **O manualmente, editar el archivo de entitlements:**
   - Busca el archivo `Runner.entitlements` o crea uno nuevo
   - Agrega:
   ```xml
   <key>aps-environment</key>
   <string>development</string>
   ```
   - Para producción, usa `<string>production</string>`

3. **Verificar en Info.plist:**
   - El archivo `Info.plist` ya tiene `UIBackgroundModes` con `remote-notification`, lo cual está correcto.

---

### 4. **AdMob no inicializado (Normal)**

```
⚠️ AdMob no está inicializado. Esperando inicialización...
```

**Esto es normal.** AdMob se inicializa después de 3 segundos del arranque de la app (configurado en `app_initializer.dart`). No es un error.

---

### 5. **⚠️ IMPORTANTE: Token de App Check vs Token FCM**

**NO confundas estos dos tokens:**

#### Token de App Check (`496414DA-728C-4611-821B-CB2FB3FC96EE`)
- **Propósito:** Validar que la app es legítima
- **NO se usa para enviar notificaciones**
- Solo se registra en Firebase Console → App Check → Debug Tokens

#### Token FCM (Firebase Cloud Messaging)
- **Propósito:** Identificar el dispositivo para enviar notificaciones push
- **SÍ se usa para enviar notificaciones desde Firebase Console**
- Se obtiene automáticamente cuando la app se ejecuta
- Se imprime en los logs con el formato: `📱 Token FCM: [token_aquí]`

**Para probar notificaciones desde Firebase Console:**

1. **Obtener el Token FCM:**
   - Ejecuta la app: `flutter run`
   - Busca en los logs de la consola el mensaje:
     ```
     📱 Token FCM: [AQUÍ_ESTÁ_TU_TOKEN_FCM]
     ```
   - O espera a que aparezca: `📱 Token FCM obtenido (retrasado): [token]`

2. **Enviar notificación de prueba desde Firebase Console:**
   - Ve a [Firebase Console](https://console.firebase.google.com)
   - Selecciona tu proyecto: **playas-rd-2b475**
   - Ve a **Cloud Messaging** → **Enviar mensaje de prueba**
   - Pega el **Token FCM** (NO el token de App Check)
   - Escribe un título y mensaje
   - Haz clic en **"Probar"**

**Nota:** El token FCM puede tardar unos segundos en generarse, especialmente si el token APNS aún no está disponible. Si no aparece inmediatamente, espera unos segundos y busca en los logs.

---

## 📋 Checklist de Verificación

Después de aplicar las soluciones, verifica:

- [ ] `GoogleService-Info.plist` está en `ios/Runner/` y agregado al proyecto en Xcode
- [ ] El Debug Token de App Check está registrado en Firebase Console
- [ ] Push Notifications está habilitado en Signing & Capabilities
- [ ] El archivo de entitlements tiene `aps-environment` configurado
- [ ] La app compila sin errores de Firebase

---

## 🔄 Pasos para Aplicar las Soluciones

1. **Descargar y agregar GoogleService-Info.plist:**
   ```bash
   # Descarga el archivo desde Firebase Console y colócalo en:
   # ios/Runner/GoogleService-Info.plist
   ```

2. **Registrar el Debug Token:**
   - Token: `496414DA-728C-4611-821B-CB2FB3FC96EE`
   - Regístralo en Firebase Console → App Check

3. **Configurar Push Notifications en Xcode:**
   - Abre `ios/Runner.xcworkspace` en Xcode
   - Ve a Signing & Capabilities
   - Agrega "Push Notifications" si no está

4. **Limpiar y recompilar:**
   ```bash
   flutter clean
   cd ios
   pod install
   cd ..
   flutter run
   ```

---

## 📝 Notas Importantes

1. **GoogleService-Info.plist es crítico:** Sin este archivo, Firebase no funcionará correctamente.

2. **Debug Tokens son solo para desarrollo:** No uses debug tokens en builds de producción o TestFlight.

3. **Para producción:** Debes configurar DeviceCheck correctamente. Los debug tokens no funcionan en producción.

4. **Múltiples dispositivos:** Si pruebas en varios dispositivos, cada uno generará un debug token diferente. Necesitarás registrar cada uno.

---

## ✅ Resultado Esperado

Después de aplicar estas soluciones, deberías ver en los logs:

- ✅ `Firebase inicializado correctamente`
- ✅ `✅ Servicio de notificaciones inicializado`
- ✅ `✅ AdMob inicializado correctamente`
- ❌ **NO deberías ver:**
  - `Could not locate configuration file: 'GoogleService-Info.plist'`
  - `AppCheck failed: HTTP status code: 403`
  - `no se encontró ninguna cadena de autorización "aps-environment"`

# Solución: Error "APNS token has not been set yet"

## 🔴 Problema

Estás viendo este error en los logs:

```
⚠️ Error obteniendo token FCM: [firebase_messaging/apns-token-not-set] 
APNS token has not been set yet. Please ensure the APNS token is available 
by calling `getAPNSToken()`.
```

**Causa:** El token APNS (Apple Push Notification Service) no está disponible, lo que impide obtener el token FCM necesario para enviar notificaciones push.

---

## ✅ Solución Completa

### Paso 1: Verificar que el archivo de entitlements existe

He creado el archivo `ios/Runner/Runner.entitlements` con la configuración necesaria:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>development</string>
</dict>
</plist>
```

### Paso 2: Agregar el archivo de entitlements al proyecto en Xcode

1. **Abre Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Agregar el archivo de entitlements:**
   - En el navegador de archivos de Xcode, haz clic derecho en la carpeta "Runner"
   - Selecciona "Add Files to Runner..."
   - Navega a `ios/Runner/Runner.entitlements`
   - Asegúrate de que "Copy items if needed" esté **desmarcado**
   - Asegúrate de que "Add to targets: Runner" esté **marcado**
   - Haz clic en "Add"

3. **Configurar el archivo de entitlements en el proyecto:**
   - Selecciona el proyecto "Runner" en el navegador
   - Selecciona el target "Runner"
   - Ve a la pestaña "Signing & Capabilities"
   - Verifica que aparezca "Push Notifications" en las capabilities
   - Si no aparece, haz clic en "+ Capability" y agrega "Push Notifications"
   - En "Code Signing Entitlements", verifica que aparezca: `Runner/Runner.entitlements`

### Paso 3: Verificar configuración en Xcode

1. **En Signing & Capabilities:**
   - Debe aparecer "Push Notifications" como capability activa
   - El archivo de entitlements debe estar configurado

2. **En Build Settings:**
   - Busca "Code Signing Entitlements"
   - Debe estar configurado como: `Runner/Runner.entitlements`

### Paso 4: Verificar certificados de APNS

Para que las notificaciones push funcionen, necesitas:

1. **Certificado de APNS en Apple Developer:**
   - Ve a [Apple Developer](https://developer.apple.com/account)
   - Certificates, Identifiers & Profiles
   - Identifiers → Tu App ID
   - Verifica que "Push Notifications" esté habilitado
   - Si no está, habilítalo y regenera los certificados

2. **Subir certificado a Firebase:**
   - Ve a [Firebase Console](https://console.firebase.google.com)
   - Tu proyecto → Configuración del proyecto
   - Pestaña "Cloud Messaging"
   - En "Certificados APNs", sube tu certificado de desarrollo o producción

### Paso 5: Limpiar y recompilar

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 🔍 Verificación

Después de aplicar estos pasos, deberías ver en los logs:

✅ **Lo que deberías ver:**
```
✅ Token APNS obtenido: [token]
📱 TOKEN FCM PARA NOTIFICACIONES PUSH
📱 TOKEN FCM: [token_fcm_aquí]
```

❌ **Lo que NO deberías ver:**
```
⚠️ Token APNS no disponible aún
⚠️ Error obteniendo token FCM: [firebase_messaging/apns-token-not-set]
```

---

## 📝 Notas Importantes

1. **aps-environment:**
   - `development`: Para desarrollo y simulador
   - `production`: Para producción y TestFlight/App Store

2. **Dispositivo físico vs Simulador:**
   - Las notificaciones push **NO funcionan en el simulador de iOS**
   - Debes probar en un **dispositivo físico**

3. **Certificados:**
   - Para desarrollo: Usa certificado de desarrollo
   - Para producción: Usa certificado de producción
   - Los certificados deben estar subidos a Firebase Console

4. **Tiempo de espera:**
   - El token APNS puede tardar unos segundos en generarse
   - El código ya tiene retry automático después de 2-3 segundos

---

## 🚨 Si el problema persiste

1. **Verifica que estás usando un dispositivo físico** (no simulador)

2. **Verifica los certificados:**
   ```bash
   # Ver certificados instalados
   security find-identity -v -p codesigning
   ```

3. **Verifica que Push Notifications esté habilitado en Apple Developer:**
   - App ID → Push Notifications debe estar marcado

4. **Revisa los logs de Xcode:**
   - Busca errores relacionados con APNS o Push Notifications

5. **Regenera los certificados si es necesario:**
   - En Apple Developer, elimina y recrea los certificados de APNS
   - Súbelos nuevamente a Firebase Console

---

## ✅ Cambios Realizados

1. ✅ Creado `ios/Runner/Runner.entitlements` con `aps-environment`
2. ✅ Actualizado `AppDelegate.swift` para registrar notificaciones remotas
3. ✅ Agregado manejo de errores para el registro de APNS

**Próximo paso:** Abre Xcode y agrega el archivo de entitlements al proyecto siguiendo el Paso 2.

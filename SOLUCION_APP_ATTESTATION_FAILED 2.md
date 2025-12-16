# Solución: Error "App attestation failed" con DeviceCheck

## 🔴 Problema

Estás viendo este error:
```
AppCheck failed: App attestation failed.
HTTP status code: 403
Status: PERMISSION_DENIED
```

Este error ocurre cuando DeviceCheck no puede verificar la app correctamente.

## 🔍 Causas Comunes

1. **Bundle ID no coincide** entre Firebase y Xcode
2. **App no está firmada correctamente** con certificado de desarrollo
3. **DeviceCheck requiere configuración adicional** en Apple Developer
4. **Certificado de desarrollo expirado o inválido**

## ✅ Solución 1: Deshabilitar App Check Temporalmente (Más Rápido para Pruebas)

Para probar las notificaciones inmediatamente, puedes deshabilitar App Check:

### Paso 1: Ir a Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto: **playas-rd-2b475**
3. Ve a **App Check**

### Paso 2: Cambiar a "Unenforced"

1. En la lista de apps, encuentra **"Playas RD IOS"**
2. Haz clic en el menú de tres puntos (⋮) junto a la app
3. Selecciona **"Unenforce"** o **"No aplicar"**
4. Esto permitirá que la app funcione sin App Check (solo para desarrollo)

### Paso 3: Recompilar

```bash
flutter clean
cd ios
pod install
cd ..
flutter run
```

**Nota**: Esto desactiva la protección de App Check. Solo úsalo para pruebas. Para producción, deberías solucionar el problema de DeviceCheck.

---

## ✅ Solución 2: Usar Debug Token (Recomendado para Desarrollo)

Esta es la mejor opción para desarrollo mientras solucionas DeviceCheck:

### Paso 1: Obtener Debug Token

1. Ejecuta la app en tu dispositivo
2. En los logs de Xcode, busca un mensaje como:
   ```
   Firebase App Check debug token: [TOKEN_AQUI]
   ```
3. Si no aparece, agrega este código temporalmente en `lib/services/app_initializer.dart`:

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Agregar esto temporalmente para obtener debug token
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }
    
    print('✅ Firebase inicializado correctamente');
    return true;
  } catch (e) {
    print('⚠️ Firebase no configurado: $e');
    return false;
  }
}
```

4. Ejecuta la app y busca el debug token en los logs

### Paso 2: Registrar Debug Token en Firebase

1. Ve a Firebase Console → **App Check**
2. Selecciona **"Playas RD IOS"**
3. Haz clic en **"Manage debug tokens"** o **"Gestionar tokens de depuración"**
4. Haz clic en **"Add debug token"**
5. Pega el token que obtuviste
6. Guarda

### Paso 3: Configurar App Check con Debug Token

En `lib/services/app_initializer.dart`, agrega:

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configurar App Check con Debug Token para desarrollo
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    } else {
      // Para producción, usar DeviceCheck
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
    }
    
    print('✅ Firebase inicializado correctamente');
    return true;
  } catch (e) {
    print('⚠️ Firebase no configurado: $e');
    return false;
  }
}
```

---

## ✅ Solución 3: Verificar y Corregir Bundle ID

El Bundle ID debe coincidir exactamente entre Firebase y Xcode.

### Verificar Bundle ID en Firebase

1. Ve a Firebase Console → **Project Settings** → **General**
2. Busca la app iOS: **"Playas RD IOS"**
3. Verifica el **Bundle ID**: Debe ser `com.playasrd.playasrd`

### Verificar Bundle ID en Xcode

1. Abre `ios/Runner.xcodeproj` en Xcode
2. Selecciona el proyecto **Runner**
3. Selecciona el target **Runner**
4. Ve a la pestaña **General**
5. Verifica **Bundle Identifier**: Debe ser `com.playasrd.playasrd`

**⚠️ Nota**: Veo que en tu proyecto puede estar configurado como `com.playasrd.playasRdFlutter`. Si es así, necesitas cambiarlo a `com.playasrd.playasrd` para que coincida con Firebase.

### Cambiar Bundle ID en Xcode

1. En Xcode, selecciona el target **Runner**
2. Ve a **General** → **Bundle Identifier**
3. Cambia a: `com.playasrd.playasrd`
4. Guarda y recompila

---

## ✅ Solución 4: Verificar Firma de la App

DeviceCheck requiere que la app esté firmada correctamente:

### En Xcode

1. Abre `ios/Runner.xcodeproj` en Xcode
2. Selecciona el proyecto **Runner**
3. Selecciona el target **Runner**
4. Ve a **Signing & Capabilities**
5. Verifica:
   - ✅ **Automatically manage signing** está marcado
   - ✅ **Team** está seleccionado (C3TZFSL98Z)
   - ✅ **Bundle Identifier** es `com.playasrd.playasrd`
   - ✅ No hay errores de firma

### Si hay errores de firma

1. Ve a **Preferences** → **Accounts**
2. Selecciona tu cuenta de Apple
3. Haz clic en **Download Manual Profiles**
4. Vuelve a **Signing & Capabilities**
5. Selecciona el perfil correcto

---

## 🎯 Recomendación para Pruebas Rápidas

**Para probar notificaciones AHORA**:

1. **Deshabilita App Check temporalmente** (Solución 1)
2. Prueba las notificaciones
3. Luego configura correctamente DeviceCheck o Debug Token

**Para desarrollo a largo plazo**:

1. Usa **Debug Token** (Solución 2)
2. Es más seguro que deshabilitar App Check
3. Funciona en simulador y dispositivo físico

**Para producción**:

1. Configura **DeviceCheck correctamente** (Solución 3 y 4)
2. Asegúrate de que el Bundle ID coincida
3. Verifica que la app esté firmada correctamente

---

## 🔍 Verificar que Funciona

Después de aplicar una solución:

1. **Recompila la app**:
   ```bash
   flutter clean
   flutter run
   ```

2. **Revisa los logs**:
   - No deberías ver errores de App Check
   - Deberías ver: `✅ Firebase inicializado correctamente`
   - Deberías ver: `📱 Token FCM: [token]`

3. **Prueba las notificaciones** desde Firebase Console

---

## 📚 Recursos

- [Firebase App Check Debug Tokens](https://firebase.google.com/docs/app-check/ios/debug-token)
- [DeviceCheck Provider](https://firebase.google.com/docs/app-check/ios/device-check-provider)
- [Troubleshooting App Check](https://firebase.google.com/docs/app-check/troubleshooting)

---

**¿Cuál solución prefieres probar primero?** Te recomiendo la Solución 1 (deshabilitar temporalmente) para probar notificaciones rápidamente, y luego la Solución 2 (Debug Token) para desarrollo.

# Solución: Configurar Debug Token para App Check (iOS)

## 🔍 Situación

No encuentras la opción "Unenforce" en el menú de App Check. Esto es normal - Firebase ahora recomienda usar **Debug Tokens** para desarrollo en lugar de deshabilitar App Check completamente.

## ✅ Solución: Usar Debug Token

Los Debug Tokens permiten que tu app funcione durante desarrollo sin necesidad de DeviceCheck completo.

### Paso 1: Obtener el Debug Token desde la App

Primero, necesitamos modificar el código para obtener y mostrar el Debug Token.

#### Opción A: Agregar código temporal para obtener el token

Agrega esto temporalmente en `lib/services/app_initializer.dart`:

```dart
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configurar App Check con Debug Token para desarrollo
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,  // Esto generará un debug token
      );
      
      // Obtener y mostrar el debug token
      final token = await FirebaseAppCheck.instance.getToken();
      if (token != null) {
        print('🔑 DEBUG TOKEN (iOS): ${token.token}');
        print('⚠️ COPIA ESTE TOKEN Y REGÍSTRALO EN FIREBASE CONSOLE');
      }
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

#### Opción B: Verificar si ya tienes firebase_app_check configurado

Verifica si ya tienes el paquete `firebase_app_check` en `pubspec.yaml`. Si no lo tienes, agrégalo:

```yaml
dependencies:
  firebase_app_check: ^0.3.1+2
```

Luego ejecuta:
```bash
flutter pub get
```

### Paso 2: Ejecutar la App y Obtener el Token

1. Ejecuta la app en modo debug:
   ```bash
   flutter run
   ```

2. Busca en los logs de Xcode el mensaje:
   ```
   🔑 DEBUG TOKEN (iOS): [TOKEN_AQUI]
   ```

3. **Copia el token completo** (es una cadena larga)

### Paso 3: Registrar el Debug Token en Firebase Console

1. Ve a Firebase Console → **App Check** → **Apps**
2. Encuentra **"Playas RD iOS"**
3. Haz clic en el menú (⋮) junto a **"DeviceCheck"**
4. Selecciona **"Administrar tokens de depuración"** (Manage debug tokens)
5. Haz clic en **"Agregar token de depuración"** o **"Add debug token"**
6. Pega el token que copiaste del paso 2
7. Haz clic en **"Guardar"** o **"Save"**

### Paso 4: Verificar que Funciona

1. Recompila la app:
   ```bash
   flutter clean
   flutter run
   ```

2. Revisa los logs - **NO deberías ver**:
   - ❌ `AppCheck failed: App attestation failed`
   - ❌ `PERMISSION_DENIED`

3. Deberías ver:
   - ✅ `✅ Firebase inicializado correctamente`
   - ✅ `📱 Token FCM: [token]` (si ya configuraste APNS)

---

## 🔄 Alternativa: Deshabilitar App Check desde la Pestaña "APIs"

Si prefieres deshabilitar App Check completamente (no recomendado para producción):

1. Ve a Firebase Console → **App Check**
2. Haz clic en la pestaña **"APIs"** (en lugar de "Apps")
3. Busca las APIs que quieres deshabilitar (por ejemplo, "Cloud Firestore API")
4. Puede haber opciones para cambiar el estado de enforcement allí

---

## 📝 Notas Importantes

1. **Debug Tokens son solo para desarrollo**: No uses debug tokens en builds de producción o TestFlight.

2. **El token puede cambiar**: Si reinstalas la app o cambias el Bundle ID, necesitarás registrar un nuevo debug token.

3. **Para producción**: Debes solucionar DeviceCheck correctamente. Los debug tokens no funcionan en producción.

4. **Múltiples dispositivos**: Si pruebas en varios dispositivos, necesitarás registrar un debug token para cada uno.

---

## 🎯 Resumen de Pasos Rápidos

1. ✅ Agregar código para obtener debug token (Paso 1)
2. ✅ Ejecutar app y copiar el token de los logs (Paso 2)
3. ✅ Registrar token en Firebase Console → App Check → "Administrar tokens de depuración" (Paso 3)
4. ✅ Recompilar y verificar que funciona (Paso 4)

---

**¿Necesitas ayuda para agregar el código del Paso 1?** Puedo ayudarte a modificar `app_initializer.dart` para obtener el debug token automáticamente.

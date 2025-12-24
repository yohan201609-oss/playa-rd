# Guía de Configuración de Apple Sign In

## ✅ Cambios Implementados

Se han realizado los siguientes cambios automáticamente:

1. ✅ Agregado `sign_in_with_apple: ^6.1.1` al `pubspec.yaml`
2. ✅ Agregado método `signInWithApple()` en `firebase_service.dart`
3. ✅ Agregado método `signInWithApple()` en `auth_provider.dart`
4. ✅ Actualizado `login_screen.dart` para mostrar botón de Apple (solo en iOS)
5. ✅ Actualizado `Runner.entitlements` para habilitar Apple Sign In
6. ✅ Instaladas las dependencias con `flutter pub get`

## ⚠️ Configuraciones Pendientes (Manuales)

Para completar la integración, necesitas realizar los siguientes pasos manuales:

### 1. Configurar Apple Sign In en Xcode

1. Abre el proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. En el navegador de proyectos, selecciona el proyecto "Runner" (no el target)

3. Selecciona el target "Runner"

4. Ve a la pestaña **"Signing & Capabilities"**

5. Haz clic en el botón **"+ Capability"** (en la esquina superior izquierda)

6. Busca y selecciona **"Sign In with Apple"**

7. Esto agregará automáticamente la capacidad al proyecto

8. **Importante**: Asegúrate de que tu **App ID** en Apple Developer tenga habilitado "Sign In with Apple":
   - Ve a [Apple Developer](https://developer.apple.com/account/)
   - Identifiers → App IDs
   - Selecciona tu App ID
   - Verifica que "Sign In with Apple" esté habilitado

### 2. Habilitar Apple Sign In en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)

2. Selecciona tu proyecto

3. Ve a **Authentication** → **Sign-in method**

4. Busca **"Apple"** en la lista de proveedores

5. Haz clic en **"Apple"** y luego en **"Enable"**

6. Para apps móviles nativas iOS, solo necesitas habilitar el proveedor. Los siguientes campos son **OPCIONALES** y solo necesarios si planeas usar Apple Sign In en la web:
   - **Service ID**: (opcional, solo para autenticación web)
   - **Apple Team ID**: Tu Team ID de Apple Developer (opcional, solo para web)
   - **Key ID**: (opcional, solo para autenticación web)
   - **Private Key**: (opcional, solo para autenticación web)

7. **Importante**: Para iOS nativo, solo haz clic en **"Enable"** y luego **"Save"**. NO necesitas configurar los campos opcionales a menos que vayas a implementar Apple Sign In en la versión web.

8. **Nota sobre Redirect URIs**: La URL `https://playas-rd-2b475.firebaseapp.com/__/auth/handler` que ves en tu configuración de Firebase es para Google Sign In y autenticación web. Para Apple Sign In en iOS nativo, NO necesitas configurar redirect URIs porque usa la autenticación nativa de Apple directamente en el dispositivo.

### 3. Verificar la Configuración

1. **En Xcode**:
   - Verifica que en "Signing & Capabilities" aparezca "Sign In with Apple"
   - Asegúrate de que el Bundle Identifier coincida con el App ID configurado en Apple Developer

2. **En Apple Developer**:
   - Verifica que tu App ID tenga habilitado "Sign In with Apple"
   - Si no está habilitado, edita el App ID y marca la casilla

3. **En Firebase Console**:
   - Verifica que Apple esté habilitado en Authentication

### 4. Probar la Funcionalidad

1. Ejecuta la app en un dispositivo iOS físico o simulador con iOS 13+:
   ```bash
   flutter run
   ```

2. Ve a la pantalla de login

3. Deberías ver el botón "Apple" debajo del botón de Google (solo en iOS)

4. Al hacer clic en "Apple", debería aparecer el diálogo nativo de Apple Sign In

### 5. Notas Importantes

- **Apple Sign In solo funciona en iOS 13+**
- El botón solo se muestra en dispositivos iOS (está condicionado con `Platform.isIOS`)
- En simulador, es posible que necesites iniciar sesión con tu Apple ID primero
- En producción, necesitarás un dispositivo físico para probar completamente

### 6. Solución de Problemas

**Problema**: El botón de Apple no aparece
- ✅ Verifica que estés ejecutando en iOS (no Android)
- ✅ Verifica que el archivo `login_screen.dart` tenga el import de `dart:io`
- ✅ Verifica que `Platform.isIOS` esté funcionando correctamente

**Problema**: Error al intentar iniciar sesión con Apple
- ✅ Verifica que "Sign In with Apple" esté habilitado en Xcode Capabilities
- ✅ Verifica que el App ID tenga habilitado "Sign In with Apple" en Apple Developer
- ✅ Verifica que Apple esté habilitado en Firebase Console
- ✅ Verifica que estés usando un dispositivo físico o simulador con iOS 13+

**Problema**: Error "The operation couldn't be completed"
- ✅ Verifica que el Bundle Identifier coincida con el App ID configurado
- ✅ Verifica que el certificado de desarrollo esté válido
- ✅ Intenta limpiar el build: `flutter clean` y luego `flutter run`

### 7. Próximos Pasos

Una vez completada la configuración:

1. Prueba el flujo completo de inicio de sesión
2. Verifica que los datos del usuario se guarden correctamente en Firestore
3. Verifica que la foto de perfil y nombre se actualicen si Apple los proporciona
4. Si planeas usar esta funcionalidad en producción, asegúrate de tener la configuración correcta en App Store Connect

## 📝 Resumen

El código está listo. Solo necesitas:
1. ⚠️ Agregar la capacidad "Sign In with Apple" en Xcode
2. ⚠️ Habilitar Apple en Firebase Console
3. ✅ Probar en un dispositivo iOS

¡Listo para usar! 🎉

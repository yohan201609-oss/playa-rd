# 🔧 Solución: Error ApiException: 10 en Google Sign-In (Producción/Prueba Cerrada)

## 📋 Problema
Error al intentar iniciar sesión con Google en la **prueba cerrada de Google Play Console**:
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:, null, null)
```

## ✅ Verificaciones Realizadas

### SHA-1 Certificados en google-services.json
- ✅ **Debug SHA-1:** `72f17a530f1bebe00ddd1d920f565a8d2d0508e6` - Registrado
- ✅ **Release SHA-1:** `3b28ecd60c45155c9a6215344fbe771250f62486` - Registrado
- ✅ **Package Name:** `com.playasrd.playasrd` - Correcto
- ✅ **Server Client ID:** `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6.apps.googleusercontent.com` - Configurado

## 🎯 Solución: Configurar OAuth Consent Screen para Producción

El error `ApiException: 10` en producción generalmente se debe a que el **OAuth Consent Screen** no está publicado o no está correctamente configurado.

### Paso 1: Verificar OAuth Consent Screen

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **"APIs & Services"** > **"OAuth consent screen"**

### Paso 2: Configurar OAuth Consent Screen

**IMPORTANTE:** Si tu app está en modo "Testing" o "Internal", necesitas publicarla para que funcione en producción.

#### Opción A: Si es una app INTERNA (solo para tu organización)
1. En "User type", selecciona **"Internal"**
2. Completa todos los campos obligatorios:
   - **App name:** Playas RD
   - **User support email:** Tu email
   - **Developer contact information:** Tu email
3. Haz clic en **"Save and Continue"**
4. En "Scopes", verifica que estén:
   - `email`
   - `profile`
   - `openid`
5. Haz clic en **"Save and Continue"**
6. En "Test users" (si aplica), agrega los emails de prueba
7. Haz clic en **"Save and Continue"**
8. **Revisa y confirma** la configuración

#### Opción B: Si es una app EXTERNA (pública)
1. En "User type", selecciona **"External"**
2. Completa todos los campos obligatorios
3. En "Scopes", agrega:
   - `email`
   - `profile`
   - `openid`
4. En "Test users", agrega los emails de los testers de la prueba cerrada
5. **PUBLICA LA APP:**
   - Ve a la pestaña **"Publishing status"**
   - Haz clic en **"PUBLISH APP"**
   - Confirma la publicación

⚠️ **NOTA IMPORTANTE:** Si la app está en modo "Testing", solo funcionará para usuarios agregados como "Test users". Para que funcione en producción, debes publicarla.

### Paso 3: Verificar Google Sign-In API

1. En Google Cloud Console, ve a **"APIs & Services"** > **"Library"**
2. Busca **"Google Sign-In API"**
3. Asegúrate de que esté **HABILITADA**
4. Si no está habilitada, haz clic en **"Enable"**

### Paso 4: Verificar OAuth 2.0 Client ID (Web)

1. Ve a **"APIs & Services"** > **"Credentials"**
2. Busca el OAuth client con ID: `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6`
3. Verifica que:
   - ✅ Tipo: **Web application**
   - ✅ Estado: **Habilitado**
   - ✅ **Authorized JavaScript origins:** (puede estar vacío para apps móviles)
   - ✅ **Authorized redirect URIs:** Debe incluir:
     - `com.googleusercontent.apps.360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6:/`
     - O el formato correcto para tu app

### Paso 5: Verificar Firebase Authentication

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **"Authentication"** > **"Sign-in method"**
4. Verifica que **"Google"** esté:
   - ✅ **Habilitado**
   - ✅ **Web SDK configuration** tenga el Client ID correcto
   - ✅ **Web client ID:** `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6.apps.googleusercontent.com`

### Paso 6: Verificar que el SHA-1 de Release esté en Firebase

1. En Firebase Console, ve a **"Project Settings"** (⚙️)
2. En la pestaña **"General"**, busca la app Android
3. Verifica que el **SHA-1 de release** esté agregado:
   - `3B:28:EC:D6:0C:45:15:5C:9A:62:15:34:4F:BE:77:12:50:F6:24:86`
4. Si no está, haz clic en **"Add fingerprint"** y agrégalo
5. Descarga el nuevo `google-services.json`
6. Reemplaza el archivo en: `android/app/google-services.json`

## 🔄 Después de los Cambios

### 1. Regenerar App Bundle

Después de hacer cambios en Google Cloud Console o Firebase:

```bash
# Limpiar
flutter clean

# Obtener dependencias
flutter pub get

# Generar nuevo App Bundle
flutter build appbundle --release
```

### 2. Subir Nueva Versión a Prueba Cerrada

1. Incrementa el `versionCode` en `pubspec.yaml`:
   ```yaml
   version: 1.0.2+5  # Incrementa el número después del +
   ```

2. Genera el nuevo App Bundle

3. Sube la nueva versión a Google Play Console > Pruebas Cerradas

## ⏱️ Tiempos de Propagación

- ⚠️ Los cambios en **OAuth Consent Screen** pueden tardar **hasta 24 horas** en aplicarse
- ⚠️ Los cambios en **Firebase Console** pueden tardar **5-10 minutos**
- ⚠️ Los cambios en **Google Cloud Console** pueden tardar **5-10 minutos**

## 🆘 Si el Problema Persiste

### Verificar Logs en Producción

1. Usa **Firebase Crashlytics** o **Google Play Console** para ver logs detallados
2. Busca el error completo con stack trace

### Verificar que el Dispositivo Tenga Google Play Services

El error 10 también puede ocurrir si:
- Google Play Services no está actualizado
- El dispositivo no tiene Google Play Services instalado

### Probar con Usuario de Prueba

Si la app está en modo "Testing":
1. Agrega el email del tester como "Test user" en OAuth Consent Screen
2. El usuario debe aceptar los permisos la primera vez
3. Después de aceptar, debería funcionar

## ✅ Checklist Final para Producción

- [ ] OAuth Consent Screen configurado y **PUBLICADO** (si es app externa)
- [ ] OAuth Consent Screen en modo "Internal" o "Testing" con test users agregados
- [ ] Google Sign-In API habilitada en Google Cloud Console
- [ ] OAuth 2.0 Client ID (Web) configurado correctamente
- [ ] Firebase Authentication > Google habilitado
- [ ] SHA-1 de release registrado en Firebase Console
- [ ] `serverClientId` configurado en el código
- [ ] Scopes correctos: `email`, `profile`, `openid`
- [ ] App Bundle regenerado después de cambios
- [ ] Nueva versión subida a prueba cerrada

## 📝 Notas Importantes

1. **App en Modo Testing:**
   - Solo funcionará para usuarios agregados como "Test users"
   - Cada usuario debe aceptar los permisos la primera vez
   - Para producción real, debes publicar la app

2. **App Publicada:**
   - Funciona para todos los usuarios
   - Requiere verificación de Google (puede tardar días)
   - Mejor para apps en producción

3. **SHA-1 de Release:**
   - Debe estar registrado ANTES de generar el App Bundle
   - Si lo agregas después, necesitas regenerar el bundle

## 🔗 Enlaces Útiles

- [Google Cloud Console](https://console.cloud.google.com/)
- [Firebase Console](https://console.firebase.google.com/)
- [OAuth Consent Screen](https://console.cloud.google.com/apis/credentials/consent)
- [Google Sign-In API](https://console.cloud.google.com/apis/library/signin.googleapis.com)



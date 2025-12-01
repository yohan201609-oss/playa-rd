# 🔧 Solución: Error ApiException: 10 en Google Sign-In

## 📋 Problema
Error al intentar iniciar sesión con Google:
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:, null, null)
```

El código de error **10** corresponde a `DEVELOPER_ERROR`, que indica un problema de configuración.

## ✅ Verificaciones Realizadas

### SHA-1 Certificados
- ✅ **Debug SHA-1:** `72f17a530f1bebe00ddd1d920f565a8d2d0508e6` - Registrado en Firebase
- ✅ **Release SHA-1:** `3b28ecd60c45155c9a6215344fbe771250f62486` - Registrado en Firebase
- ✅ **Package Name:** `com.playasrd.playasrd` - Correcto
- ✅ **Server Client ID:** `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6.apps.googleusercontent.com` - Configurado

## 🔍 Solución: Verificar Configuración en Google Cloud Console

El error persiste porque necesitas verificar y habilitar correctamente el OAuth client en Google Cloud Console.

### Paso 1: Acceder a Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **"APIs & Services"** > **"Credentials"**

### Paso 2: Verificar OAuth 2.0 Client IDs

Busca el OAuth client con ID: `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6.apps.googleusercontent.com`

**Verifica que:**
- ✅ Tipo: **Web application**
- ✅ Estado: **Habilitado**
- ✅ Tiene las APIs correctas habilitadas

### Paso 3: Habilitar Google Sign-In API

1. En Google Cloud Console, ve a **"APIs & Services"** > **"Library"**
2. Busca **"Google Sign-In API"**
3. Asegúrate de que esté **HABILITADA**
4. Si no está habilitada, haz clic en **"Enable"**

### Paso 4: Verificar Firebase Authentication

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **"Authentication"** > **"Sign-in method"**
4. Verifica que **"Google"** esté habilitado
5. Verifica que el **Web SDK configuration** tenga el Client ID correcto:
   - `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6.apps.googleusercontent.com`

### Paso 5: Verificar OAuth Consent Screen

1. En Google Cloud Console, ve a **"APIs & Services"** > **"OAuth consent screen"**
2. Verifica que:
   - ✅ El tipo de usuario sea correcto (Internal o External)
   - ✅ Los scopes incluyan: `email`, `profile`, `openid`
   - ✅ El estado de publicación sea correcto

### Paso 6: Regenerar google-services.json (Opcional)

Si después de verificar todo lo anterior el problema persiste:

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **"Project Settings"** (⚙️)
4. En la pestaña **"General"**, busca la app Android
5. Haz clic en **"Download google-services.json"**
6. Reemplaza el archivo en: `android/app/google-services.json`
7. **NO olvides** agregar el SHA-1 de debug si no está incluido

## 🔄 Después de los Cambios

1. **Limpiar y reconstruir:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Probar Google Sign-In nuevamente**

## 📝 Notas Importantes

- ⏱️ Los cambios en Google Cloud Console pueden tardar **5-10 minutos** en propagarse
- 🔄 Si cambias algo en Firebase Console, espera unos minutos antes de probar
- 📱 Asegúrate de estar probando con el mismo certificado (debug o release) que está registrado
- 🔐 El `serverClientId` debe ser el **Web Client ID**, no el Android Client ID

## 🆘 Si el Problema Persiste

1. **Verifica los logs completos:**
   - Revisa la consola de Flutter para ver el error completo
   - Revisa Logcat en Android Studio para más detalles

2. **Verifica que el dispositivo tenga Google Play Services:**
   - El error 10 también puede ocurrir si Google Play Services no está actualizado

3. **Prueba con un dispositivo físico:**
   - A veces los emuladores tienen problemas con Google Sign-In

4. **Verifica la versión de google_sign_in:**
   - Asegúrate de usar una versión compatible: `^6.2.1`

## ✅ Checklist Final

- [ ] Google Sign-In API habilitada en Google Cloud Console
- [ ] OAuth 2.0 Client ID (Web) configurado correctamente
- [ ] Firebase Authentication > Google habilitado
- [ ] SHA-1 de debug registrado en Firebase
- [ ] SHA-1 de release registrado en Firebase
- [ ] Package name correcto: `com.playasrd.playasrd`
- [ ] `serverClientId` configurado en el código
- [ ] OAuth Consent Screen configurado
- [ ] App reconstruida después de cambios



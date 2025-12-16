# ✅ Verificación: Configuración OAuth para Producción

## 📋 Estado Actual (Confirmado)

### Firebase Console - SHA Certificates
✅ **SHA-1 Fingerprints registrados:**
- `39:c9:f9:9e:e2:d5:03:03:51:7e:c0:ca:0a:8a:17:a4:48:d8:c0:ef`
- `72:f1:7a:53:0f:1b:eb:e0:0d:dd:1d:92:0f:56:5a:8d:2d:05:08:e6` (Debug)
- `3b:28:ec:d6:0c:45:15:5c:9a:62:15:34:4f:be:77:12:50:f6:24:86` (Release) ✅

✅ **SHA-256 Fingerprint:**
- `48:3b:9e:72:02:9b:34:fd:06:5c:18:45:e8:2b:5d:53:42:a7:df:45:b4:a5:c6:b5:fd:a1:54:ca:68:0d:db:29`

✅ **Package Name:** `com.playasrd.playasrd`

## 🎯 Problema Identificado

Como los SHA-1 están correctamente registrados, el error `ApiException: 10` en producción se debe a:

1. **OAuth Consent Screen** no publicado o mal configurado
2. **OAuth Client ID (Web)** no tiene los redirect URIs correctos
3. **Google Sign-In API** no habilitada
4. **Test users** no agregados (si está en modo Testing)

## 🔧 Pasos de Verificación y Corrección

### Paso 1: Verificar OAuth Consent Screen

**URL Directa:** https://console.cloud.google.com/apis/credentials/consent?project=playas-rd-2b475

1. **Estado de Publicación:**
   - ✅ Si está en **"Testing"**: Agrega los emails de los testers
   - ✅ Si está en **"In production"**: Debe funcionar para todos

2. **Scopes Verificados:**
   - ✅ `email`
   - ✅ `profile`
   - ✅ `openid`

3. **Test Users (si está en Testing):**
   - Agrega los emails de los usuarios de la prueba cerrada
   - Cada usuario debe aceptar los permisos la primera vez

### Paso 2: Verificar OAuth 2.0 Client IDs

**URL Directa:** https://console.cloud.google.com/apis/credentials?project=playas-rd-2b475

#### A. Web Client ID (usado como serverClientId)
- **Client ID:** `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6.apps.googleusercontent.com`
- **Tipo:** Web application
- **Estado:** Debe estar habilitado
- **Authorized redirect URIs:** Debe incluir:
  ```
  com.googleusercontent.apps.360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6:/
  ```

#### B. Android Client IDs
Verifica que existan los 3 client IDs de Android con sus SHA-1 correspondientes:
- `360714035813-7kf5qc8udg90ffa8f297btugkg3gop1b` → SHA-1: `39c9f99ee2d50303517ec0ca0a8a17a448d8c0ef`
- `360714035813-p297q6mhuaj4dkhs165ltfm9pvjf5bsh` → SHA-1: `3b28ecd60c45155c9a6215344fbe771250f62486` (Release) ✅
- `360714035813-umnuvivqscumck27106qu5e8v9v1vben` → SHA-1: `72f17a530f1bebe00ddd1d920f565a8d2d0508e6` (Debug)

### Paso 3: Habilitar Google Sign-In API

**URL Directa:** https://console.cloud.google.com/apis/library/signin.googleapis.com?project=playas-rd-2b475

1. Verifica que esté **HABILITADA**
2. Si no está habilitada, haz clic en **"Enable"**

### Paso 4: Verificar Firebase Authentication

**URL Directa:** https://console.firebase.google.com/project/playas-rd-2b475/authentication/providers

1. Ve a **Authentication** > **Sign-in method**
2. Verifica que **Google** esté:
   - ✅ **Habilitado**
   - ✅ **Web SDK configuration** tenga el Client ID: `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6.apps.googleusercontent.com`

## 🔄 Acciones Requeridas

### Si OAuth Consent Screen está en "Testing":

1. **Agregar Test Users:**
   - Ve a OAuth Consent Screen
   - En la sección "Test users", agrega los emails de los testers
   - Guarda los cambios

2. **Verificar que los usuarios acepten permisos:**
   - La primera vez que un tester use Google Sign-In, verá una pantalla de consentimiento
   - Debe aceptar los permisos
   - Después de aceptar, funcionará normalmente

### Si OAuth Consent Screen está en "In production":

1. **Verificar publicación:**
   - La app debe estar publicada
   - Puede requerir verificación de Google (proceso que puede tardar días)

2. **Verificar scopes:**
   - Asegúrate de que solo uses scopes necesarios
   - Scopes sensibles requieren verificación

## 📝 Checklist de Verificación

- [ ] OAuth Consent Screen configurado correctamente
- [ ] OAuth Consent Screen publicado O test users agregados
- [ ] Google Sign-In API habilitada
- [ ] Web Client ID configurado con redirect URI correcto
- [ ] Android Client IDs con SHA-1 correctos (✅ ya verificado)
- [ ] Firebase Authentication > Google habilitado
- [ ] SHA-1 de release en Firebase (✅ ya verificado)

## ⚠️ Notas Importantes

1. **Tiempos de Propagación:**
   - Cambios en OAuth Consent Screen: **hasta 24 horas**
   - Cambios en Google Cloud Console: **5-10 minutos**
   - Cambios en Firebase: **5-10 minutos**

2. **Modo Testing vs Production:**
   - **Testing:** Solo funciona para test users agregados
   - **Production:** Funciona para todos, pero requiere verificación

3. **Primera Vez:**
   - Los usuarios deben aceptar los permisos la primera vez
   - Después de aceptar, funcionará automáticamente

## 🆘 Si el Problema Persiste

1. **Verifica los logs:**
   - Revisa Firebase Crashlytics
   - Revisa Google Play Console > Pre-launch report

2. **Verifica el dispositivo:**
   - Google Play Services actualizado
   - Conexión a internet estable

3. **Prueba con usuario de prueba:**
   - Agrega tu email como test user
   - Prueba en un dispositivo físico
   - Verifica que aceptes los permisos

## 🔗 Enlaces Directos

- **OAuth Consent Screen:** https://console.cloud.google.com/apis/credentials/consent?project=playas-rd-2b475
- **Credentials:** https://console.cloud.google.com/apis/credentials?project=playas-rd-2b475
- **Google Sign-In API:** https://console.cloud.google.com/apis/library/signin.googleapis.com?project=playas-rd-2b475
- **Firebase Authentication:** https://console.firebase.google.com/project/playas-rd-2b475/authentication/providers



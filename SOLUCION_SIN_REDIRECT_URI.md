# ✅ Solución: Google Sign-In sin Redirect URI Custom

## 📋 Situación

Google Cloud Console está rechazando el custom scheme `com.googleusercontent.apps.[ID]:/` porque espera `http` o `https`.

## ✅ Buena Noticia

**Para Android con Firebase Authentication, NO necesitas agregar ese redirect URI en Google Cloud Console.**

El `serverClientId` (Web Client ID) es suficiente cuando se usa con Firebase Authentication. El redirect URI custom scheme es manejado automáticamente por Firebase.

## 🎯 Solución: Verificar Otras Configuraciones

En lugar de agregar el redirect URI, verifica estas configuraciones:

### Paso 1: Verificar OAuth Consent Screen

1. Ve a: https://console.cloud.google.com/apis/credentials/consent?project=playas-rd-2b475
2. Verifica:
   - **Estado:** "Testing" o "In production"
   - **Scopes:** Debe incluir `email`, `profile`, `openid`
   - **Test users:** Si está en "Testing", agrega los emails de los testers

### Paso 2: Verificar Google Sign-In API

1. Ve a: https://console.cloud.google.com/apis/library/signin.googleapis.com?project=playas-rd-2b475
2. Asegúrate de que esté **HABILITADA**

### Paso 3: Verificar Firebase Authentication

1. Ve a: https://console.firebase.google.com/project/playas-rd-2b475/authentication/providers
2. Verifica que **Google** esté:
   - ✅ **Habilitado**
   - ✅ **Web SDK configuration** tenga el Client ID correcto

### Paso 4: Dejar el Redirect URI como está

**NO necesitas agregar el custom scheme.** Deja los redirect URIs que ya tienes:
- `https://playas-rd-2b475.firebaseapp.com/__/auth/handler` ✅

## 🔍 Por qué funciona sin el custom scheme

Cuando usas Firebase Authentication con Google Sign-In en Android:
1. Firebase maneja automáticamente el flujo de autenticación
2. El `serverClientId` (Web Client ID) es suficiente para obtener el `idToken`
3. Firebase usa su propio sistema de redirects internos
4. El custom scheme solo sería necesario si NO usaras Firebase

## ✅ Checklist de Verificación

- [ ] OAuth Consent Screen configurado y publicado (o test users agregados)
- [ ] Google Sign-In API habilitada
- [ ] Firebase Authentication > Google habilitado
- [ ] `serverClientId` configurado en el código (✅ ya está)
- [ ] SHA-1 de release en Firebase (✅ ya está)
- [ ] **NO necesitas el custom scheme redirect URI**

## 🔄 Después de Verificar

1. **Espera 5-10 minutos** para que los cambios se propaguen
2. **Prueba Google Sign-In** en la app
3. Si el error persiste, verifica los logs para ver el error específico

## 📝 Nota Importante

El error `ApiException: 10` en producción generalmente se debe a:
1. ❌ OAuth Consent Screen no publicado o sin test users
2. ❌ Google Sign-In API no habilitada
3. ❌ Firebase Authentication > Google no habilitado

**NO se debe a la falta del custom scheme redirect URI.**



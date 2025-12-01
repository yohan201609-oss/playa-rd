# 🔍 Solución: API No Encontrada

## ❌ Problema

No aparece "Google Sign-In API" ni "Identity Platform API" en la búsqueda.

## ✅ Solución: Firebase Authentication Maneja las APIs

Si usas **Firebase Authentication**, Firebase puede habilitar automáticamente las APIs necesarias. Sin embargo, necesitamos verificar la configuración.

## 🎯 Verificaciones Alternativas

### Opción 1: Verificar APIs Habilitadas

1. Ve a: https://console.cloud.google.com/apis/dashboard?project=playas-rd-2b475
2. Revisa la lista completa de APIs habilitadas
3. Busca si alguna de estas está habilitada:
   - Firebase Authentication API
   - Google+ API
   - Identity Toolkit API
   - Cloud Identity API

### Opción 2: Habilitar Firebase Authentication API

1. Ve a: https://console.cloud.google.com/apis/library?project=playas-rd-2b475
2. Busca: **"Firebase Authentication API"**
3. O busca: **"Firebase"** y busca APIs relacionadas con Authentication

### Opción 3: Verificar en Firebase Console

Firebase puede habilitar automáticamente las APIs. Verifica:

1. Ve a: https://console.firebase.google.com/project/playas-rd-2b475/authentication/providers
2. Verifica que **Google** esté habilitado
3. Firebase debería habilitar automáticamente las APIs necesarias

### Opción 4: Habilitar Google+ API (Alternativa)

Aunque está deprecada, Google+ API aún funciona para Google Sign-In:

1. Ve a: https://console.cloud.google.com/apis/library?project=playas-rd-2b475
2. Busca: **"Google+ API"**
3. Si aparece, habilítala

## 🔧 Solución: Verificar Configuración de Firebase

El problema puede no ser la API, sino la configuración de Firebase Authentication.

### Paso 1: Verificar Firebase Authentication

1. Ve a: https://console.firebase.google.com/project/playas-rd-2b475/authentication/providers
2. Verifica que **Google** esté:
   - ✅ **Habilitado** (toggle verde)
   - ✅ **Web SDK configuration** tenga el Client ID correcto

### Paso 2: Verificar Web Client ID

1. Ve a: https://console.cloud.google.com/apis/credentials?project=playas-rd-2b475
2. Busca el **Web client**
3. Verifica que:
   - ✅ Esté **habilitado**
   - ✅ El Client ID sea: `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6`

### Paso 3: Regenerar google-services.json

A veces regenerar el archivo ayuda:

1. Ve a: https://console.firebase.google.com/project/playas-rd-2b475/settings/general
2. En la sección de apps Android, haz clic en **"Descargar google-services.json"**
3. Reemplaza el archivo en: `android/app/google-services.json`
4. Reconstruye la app

## 🎯 Solución Más Probable

Si no encuentras la API, es probable que:

1. **Firebase Authentication** ya maneje las APIs automáticamente
2. El problema sea la configuración del **Web Client ID** en Firebase
3. Necesites **regenerar google-services.json**

## ✅ Acción Inmediata

1. **Verifica Firebase Authentication > Google** está habilitado
2. **Verifica el Web Client ID** en Firebase Authentication
3. **Regenera google-services.json** y reconstruye la app

## 📝 Nota

Con Firebase Authentication, no siempre necesitas habilitar APIs manualmente. Firebase las gestiona automáticamente. El error `ApiException: 10` puede deberse a:

1. Web Client ID incorrecto en Firebase Authentication
2. google-services.json desactualizado
3. SHA-1 no registrado (pero ya verificamos que está)

## 🔗 Enlaces Directos

- **Firebase Authentication:** https://console.firebase.google.com/project/playas-rd-2b475/authentication/providers
- **Firebase Settings:** https://console.firebase.google.com/project/playas-rd-2b475/settings/general
- **APIs Dashboard:** https://console.cloud.google.com/apis/dashboard?project=playas-rd-2b475



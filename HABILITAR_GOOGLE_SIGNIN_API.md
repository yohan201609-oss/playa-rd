# 🔧 Habilitar Google Sign-In API

## ❌ Problema

Google Sign-In API no aparece o no está habilitada en Google Cloud Console.

## ✅ Solución: Habilitar la API

### Paso 1: Buscar la API

1. Ve a: https://console.cloud.google.com/apis/library?project=playas-rd-2b475
2. En el buscador, escribe: **"Google Sign-In API"**
3. O busca directamente: **"signin"**

### Paso 2: Si no aparece "Google Sign-In API"

La API puede tener un nombre diferente. Busca estas alternativas:

#### Opción A: Identity Platform API
- Busca: **"Identity Platform API"**
- Esta es la API moderna que incluye Google Sign-In

#### Opción B: Google+ API (Deprecated pero aún funciona)
- Busca: **"Google+ API"**
- ⚠️ Esta API está deprecada pero aún funciona para Google Sign-In

#### Opción C: Firebase Authentication
- La autenticación puede estar manejada por Firebase directamente
- Verifica en Firebase Console

### Paso 3: Habilitar la API

1. Haz clic en la API que encuentres
2. Haz clic en el botón **"ENABLE"** o **"HABILITAR"**
3. Espera a que se habilite (puede tardar unos segundos)

## 🔍 Verificación Alternativa

### Verificar APIs Habilitadas

1. Ve a: https://console.cloud.google.com/apis/dashboard?project=playas-rd-2b475
2. Revisa la lista de APIs habilitadas
3. Busca:
   - Identity Platform API
   - Google+ API
   - Firebase Authentication API
   - Google Sign-In API

### Verificar en Firebase Console

1. Ve a: https://console.firebase.google.com/project/playas-rd-2b475/settings/general
2. En la sección "Your apps", verifica que la app Android esté configurada
3. Firebase puede habilitar automáticamente las APIs necesarias

## 🎯 Solución Recomendada: Habilitar Identity Platform API

La API moderna para Google Sign-In es **Identity Platform API**:

1. Ve a: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=playas-rd-2b475
2. Haz clic en **"ENABLE"** o **"HABILITAR"**
3. Espera a que se habilite

## 📝 Nota Importante

Si usas **Firebase Authentication**, Firebase puede manejar las APIs automáticamente. Sin embargo, es recomendable habilitar explícitamente:

1. **Identity Platform API** (recomendado)
2. O **Google+ API** (si Identity Platform no está disponible)

## ✅ Después de Habilitar

1. **Espera 5-10 minutos** para que los cambios se propaguen
2. **Prueba Google Sign-In** en la app
3. El error `ApiException: 10` debería desaparecer

## 🔗 Enlaces Directos

- **APIs Library:** https://console.cloud.google.com/apis/library?project=playas-rd-2b475
- **Identity Platform API:** https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=playas-rd-2b475
- **APIs Dashboard:** https://console.cloud.google.com/apis/dashboard?project=playas-rd-2b475



# 🔐 Configurar Restricciones de API Keys - Guía Paso a Paso

## 📋 Información de tu Aplicación

### Package Name (Nombre del Paquete)
```
com.playasrd.playasrd
```

### SHA-1 Certificate Fingerprints (Huellas Digitales)

**⚠️ IMPORTANTE:** Debes agregar AMBOS SHA-1 en las restricciones para que funcione tanto en debug como en release.

#### SHA-1 de Debug (para desarrollo y testing)
```
72F17A530F1BEBE00DDD1D920F565A8D2D0508E6
```
- Se usa cuando ejecutas `flutter run` o pruebas en modo debug
- **DEBES agregarlo** si quieres probar la app durante el desarrollo

#### SHA-1 de Release (para producción)
```
3B28ECD60C45155C9A6215344FBE771250F62486
```
- Se usa cuando compilas con `flutter build apk --release` o publicas en Play Store
- **DEBES agregarlo** para que funcione en producción

**⚠️ IMPORTANTE:** 
- Usa estos SHA-1 SIN los dos puntos (`:`) al configurar en Google Cloud Console
- Puedes agregar múltiples SHA-1 en la misma API Key (haz clic en "+ Add an item" para cada uno)

### API Keys a Configurar

1. **Google Maps API Key**: `AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus`
2. **Android key** (Firebase): Se crea automáticamente por Firebase

---

## 🚀 Pasos para Configurar las Restricciones

### Paso 1: Acceder a Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **Playas RD** (playas-rd-2b475)
3. Ve a **APIs & Services** > **Credentials** (Credenciales)

---

## 🔑 Configurar API Key 1: Google Maps API Key

### Identificación
- **Nombre:** `MAPS_API_KEY` o busca la key: `AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus`
- **Uso:** Google Maps SDK y Geocoding API

### Pasos Detallados:

#### 1. Editar la API Key
- Haz clic en el nombre de la API Key (enlace morado/azul)
- O busca la key por su valor: `AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus`

#### 2. Configurar Restricciones de Aplicación
En la sección **"Application restrictions"**:

1. Selecciona **"Android apps"** (Apps para Android)
2. **Agrega el SHA-1 de DEBUG primero** (para poder probar durante desarrollo):
   - Haz clic en **"+ Add an item"** o **"+ Agregar un elemento"**
   - **Package name:** `com.playasrd.playasrd`
   - **SHA-1 certificate fingerprint:** `72F17A530F1BEBE00DDD1D920F565A8D2D0508E6`
     - ⚠️ **SIN los dos puntos** (`:`)
     - ⚠️ **Todo en mayúsculas**
   - Haz clic en **"Add"** o **"Agregar"**
3. **Agrega el SHA-1 de RELEASE** (para producción):
   - Haz clic en **"+ Add an item"** nuevamente
   - **Package name:** `com.playasrd.playasrd` (el mismo)
   - **SHA-1 certificate fingerprint:** `3B28ECD60C45155C9A6215344FBE771250F62486`
     - ⚠️ **SIN los dos puntos** (`:`)
     - ⚠️ **Todo en mayúsculas**
   - Haz clic en **"Add"** o **"Agregar"**

**✅ Resultado:** Deberías ver 2 elementos en la lista, ambos con el mismo package name pero diferentes SHA-1.

#### 3. Configurar Restricciones de API
En la sección **"API restrictions"**:

1. Selecciona **"Restrict key"** (Restringir clave)
2. Marca SOLO estas APIs (no todas):
   - ✅ **Maps SDK for Android**
   - ✅ **Geocoding API**
   - ✅ **Places API** (si la usas en tu app)
3. **NO marques** otras APIs que no uses

#### 4. Guardar
- Haz clic en **"Save"** (Guardar) - botón azul en la parte inferior
- Espera 1-2 minutos para que los cambios se propaguen

---

## 🔑 Configurar API Key 2: Android key (Firebase)

### Identificación
- **Nombre:** `Android key` (creada automáticamente por Firebase)
- **Uso:** Servicios de Firebase (Authentication, Firestore, Storage, Messaging, etc.)

### Pasos Detallados:

#### 1. Encontrar la Android key
- En la lista de credenciales, busca **"Android key"**
- O busca una key que tenga "24 API" o muchas APIs de Firebase habilitadas

#### 2. Configurar Restricciones de Aplicación
En la sección **"Application restrictions"**:

1. Selecciona **"Android apps"** (Apps para Android)
2. **Agrega el SHA-1 de DEBUG primero** (para poder probar durante desarrollo):
   - Haz clic en **"+ Add an item"** o **"+ Agregar un elemento"**
   - **Package name:** `com.playasrd.playasrd`
   - **SHA-1 certificate fingerprint:** `72F17A530F1BEBE00DDD1D920F565A8D2D0508E6`
     - ⚠️ **SIN los dos puntos** (`:`)
     - ⚠️ **Todo en mayúsculas**
   - Haz clic en **"Add"** o **"Agregar"**
3. **Agrega el SHA-1 de RELEASE** (para producción):
   - Haz clic en **"+ Add an item"** nuevamente
   - **Package name:** `com.playasrd.playasrd` (el mismo)
   - **SHA-1 certificate fingerprint:** `3B28ECD60C45155C9A6215344FBE771250F62486`
     - ⚠️ **SIN los dos puntos** (`:`)
     - ⚠️ **Todo en mayúsculas**
   - Haz clic en **"Add"** o **"Agregar"**

**✅ Resultado:** Deberías ver 2 elementos en la lista, ambos con el mismo package name pero diferentes SHA-1.

#### 3. Configurar Restricciones de API
En la sección **"API restrictions"**:

1. Selecciona **"Restrict key"** (Restringir clave)
2. Marca las APIs de Firebase que uses:
   - ✅ **Firebase Cloud Messaging API**
   - ✅ **Firebase Authentication API**
   - ✅ **Cloud Firestore API**
   - ✅ **Firebase Storage API**
   - ✅ **Firebase App Check API** (si lo usas)
   - ✅ Cualquier otra API de Firebase que uses

#### 4. Guardar
- Haz clic en **"Save"** (Guardar) - botón azul en la parte inferior
- Espera 1-2 minutos para que los cambios se propaguen

---

## ✅ Verificación

### 1. Verificar que las APIs estén Habilitadas

1. Ve a **APIs & Services** > **Library**
2. Verifica que estén **habilitadas** (Enabled):
   - ✅ **Maps SDK for Android**
   - ✅ **Geocoding API**
   - ✅ **Places API** (si la usas)
   - ✅ **Firebase Cloud Messaging API**
   - ✅ **Firebase Authentication API**
   - ✅ **Cloud Firestore API**
   - ✅ **Firebase Storage API**

### 2. Probar la Aplicación

1. **Espera 1-2 minutos** después de guardar los cambios
2. **Compila la app en modo release:**
   ```powershell
   flutter build apk --release
   ```
3. **Instala y prueba:**
   - Abre la app
   - Verifica que los mapas funcionen
   - Verifica que Firebase funcione (autenticación, base de datos, etc.)
   - Verifica que la geocodificación funcione

---

## 🆘 Solución de Problemas

### ❌ Problema: "La app no funciona cuando pongo las restricciones para aplicaciones Android"

**🔍 Causa del Problema:**
Este es el problema más común. Ocurre porque:
- Cuando ejecutas `flutter run` o pruebas la app, Android usa el **keystore de DEBUG**
- El keystore de DEBUG tiene un SHA-1 diferente al de RELEASE
- Si solo agregaste el SHA-1 de RELEASE en las restricciones, la app en modo DEBUG será rechazada

**✅ Solución:**
Debes agregar **AMBOS SHA-1** en las restricciones:
1. **SHA-1 de DEBUG:** `72F17A530F1BEBE00DDD1D920F565A8D2D0508E6` (para desarrollo)
2. **SHA-1 de RELEASE:** `3B28ECD60C45155C9A6215344FBE771250F62486` (para producción)

Sigue los pasos en las secciones anteriores para agregar ambos SHA-1 en cada API Key.

---

### Error: "API Key no autorizada" o "This IP, site or mobile application is not authorized"

**Causas posibles:**
1. ❌ **Solo configuraste el SHA-1 de release pero estás probando en debug** (más común)
2. El SHA-1 no coincide exactamente
3. El package name es incorrecto
4. Las restricciones aún no se han propagado (espera 2-3 minutos)

**Soluciones:**

#### Solución 1: Verificar que Tienes Ambos SHA-1
- ✅ Verifica que hayas agregado **AMBOS** SHA-1 en las restricciones:
  - SHA-1 de DEBUG: `72F17A530F1BEBE00DDD1D920F565A8D2D0508E6`
  - SHA-1 de RELEASE: `3B28ECD60C45155C9A6215344FBE771250F62486`
- ✅ Verifica que el package name sea exactamente: `com.playasrd.playasrd`

#### Solución 2: Verificar que los SHA-1 Estén Correctos
Si ya agregaste ambos SHA-1 pero aún no funciona:

1. Verifica que copiaste los SHA-1 **SIN los dos puntos** (`:`)
   - ✅ Correcto: `72F17A530F1BEBE00DDD1D920F565A8D2D0508E6`
   - ❌ Incorrecto: `72:F1:7A:53:0F:1B:EB:E0:0D:DD:1D:92:0F:56:5A:8D:2D:05:08:E6`

2. Verifica que estén en **mayúsculas**

3. Verifica que el package name sea exactamente el mismo en ambos elementos: `com.playasrd.playasrd`

#### Solución 3: Verificar Restricciones de API
- Asegúrate de que todas las APIs necesarias estén marcadas en "API restrictions"
- Si falta alguna API, la funcionalidad relacionada no funcionará

#### Solución 4: Temporalmente Quitar Restricciones (Solo para Debug)
⚠️ **SOLO PARA DESARROLLO - NO USAR EN PRODUCCIÓN**

1. En Google Cloud Console, edita la API Key
2. En **"Application restrictions"**, selecciona **"None"**
3. Guarda los cambios
4. Espera 1-2 minutos
5. Prueba la app

**⚠️ IMPORTANTE:** Vuelve a configurar las restricciones antes de publicar en producción.

---

## 📝 Resumen de Configuración

### Google Maps API Key
- ✅ **Application restrictions:** Android apps
  - Package name: `com.playasrd.playasrd`
  - SHA-1 de DEBUG: `72F17A530F1BEBE00DDD1D920F565A8D2D0508E6` ⚠️ **OBLIGATORIO para desarrollo**
  - SHA-1 de RELEASE: `3B28ECD60C45155C9A6215344FBE771250F62486` ⚠️ **OBLIGATORIO para producción**
- ✅ **API restrictions:** Restrict key
  - Maps SDK for Android
  - Geocoding API
  - Places API (si la usas)

### Android key (Firebase)
- ✅ **Application restrictions:** Android apps
  - Package name: `com.playasrd.playasrd`
  - SHA-1 de DEBUG: `72F17A530F1BEBE00DDD1D920F565A8D2D0508E6` ⚠️ **OBLIGATORIO para desarrollo**
  - SHA-1 de RELEASE: `3B28ECD60C45155C9A6215344FBE771250F62486` ⚠️ **OBLIGATORIO para producción**
- ✅ **API restrictions:** Restrict key
  - Firebase Cloud Messaging API
  - Firebase Authentication API
  - Cloud Firestore API
  - Firebase Storage API
  - Otras APIs de Firebase que uses

---

## ⚠️ Notas Importantes

1. **Tiempo de propagación:** Los cambios pueden tardar 1-5 minutos en aplicarse
2. **SHA-1 de Release vs Debug:** 
   - Para producción, usa el SHA-1 de release: `3B28ECD60C45155C9A6215344FBE771250F62486`
   - Para testing, puedes agregar también el SHA-1 de debug
3. **Seguridad:** Las restricciones mejoran la seguridad al limitar quién puede usar tus API Keys
4. **Múltiples SHA-1:** Puedes agregar múltiples SHA-1 en la misma API Key (útil para debug y release)

---

## 🔄 Actualizar SHA-1 en el Futuro

Si cambias el keystore o necesitas agregar un nuevo SHA-1:

1. Obtén el nuevo SHA-1:
   ```powershell
   keytool -list -v -keystore "ruta/a/tu/keystore.jks" -alias tu_alias -storepass tu_password -keypass tu_password
   ```

2. Copia el SHA-1 (sin los dos puntos)

3. En Google Cloud Console, edita la API Key y agrega el nuevo SHA-1 en "Application restrictions"

---

**Última actualización:** Noviembre 2025


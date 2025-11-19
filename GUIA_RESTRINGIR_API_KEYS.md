# 🔐 Guía: Restringir API Keys en Google Cloud Console

## 📍 Ubicación

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **Playas RD** (playas-rd-2b475)
3. Ve a **APIs & Services** > **Credentials** (Credenciales)

---

## 🔑 API Key 1: Google Maps API Key

### Identificación
- **Nombre:** `MAPS_API_KEY`
- **Fecha de creación:** 12 nov 2025
- **Restricciones actuales:** "Apps para Android, 10 API"

### Pasos para Restringir:

1. **Haz clic en el nombre** `MAPS_API_KEY` (enlace morado)

2. **En "Restricciones de aplicación":**
   - Selecciona **"Apps para Android"**
   - Haz clic en **"+ Agregar un elemento"** o **"Add an item"**
   - **Nombre del paquete:** `com.playasrd.playasrd`
   - **Huella digital SHA-1:** `3B28ECD60C45155C9A6215344FBE771250F62486`
   - Haz clic en **"Agregar"**

3. **En "Restricciones de API":**
   - Selecciona **"Restringir clave"**
   - Marca solo estas APIs:
     - ✅ Maps SDK for Android
     - ✅ Geocoding API
     - ✅ Places API (opcional, si la usas)

4. **Haz clic en "Guardar"** (botón azul abajo)

---

## 🔑 API Key 2: Firebase Android Key

### Identificación
- **Nombre:** `Android key` (auto created by Firebase)
- **Fecha de creación:** 17 oct 2025
- **Restricciones actuales:** "24 API"

### Pasos para Restringir:

1. **Haz clic en el nombre** `Android key` (enlace morado)

2. **En "Restricciones de aplicación":**
   - Selecciona **"Apps para Android"**
   - Haz clic en **"+ Agregar un elemento"** o **"Add an item"**
   - **Nombre del paquete:** `com.playasrd.playasrd`
   - **Huella digital SHA-1:** `3B28ECD60C45155C9A6215344FBE771250F62486`
   - Haz clic en **"Agregar"**

3. **En "Restricciones de API":**
   - Selecciona **"Restringir clave"**
   - Marca las APIs de Firebase que uses:
     - ✅ Firebase Cloud Messaging API
     - ✅ Firebase Authentication API
     - ✅ Cloud Firestore API
     - ✅ Firebase Storage API
     - (O simplemente deja "24 API" si ya están todas marcadas)

4. **Haz clic en "Guardar"** (botón azul abajo)

---

## 📋 Información Necesaria

### Package Name (Nombre del Paquete)
```
com.playasrd.playasrd
```

### SHA-1 Certificate Fingerprint (Huella Digital)
```
3B28ECD60C45155C9A6215344FBE771250F62486
```

**⚠️ IMPORTANTE:** 
- Copia el SHA-1 **SIN los dos puntos** (`:`)
- Este es el SHA-1 del keystore de **release**, no del de debug

---

## ✅ Verificación

Después de configurar las restricciones:

1. **Espera unos minutos** para que los cambios se propaguen
2. **Prueba la app** en modo release:
   ```bash
   flutter build apk --release
   ```
3. **Instala y prueba** que los mapas y Firebase funcionen correctamente

---

## 🆘 Solución de Problemas

### Error: "API Key restringida"

**Causa:** El SHA-1 no coincide o el package name es incorrecto.

**Solución:**
1. Verifica que el package name sea exactamente: `com.playasrd.playasrd`
2. Verifica que el SHA-1 sea correcto (sin los dos puntos)
3. Si estás probando en debug, agrega también el SHA-1 de debug temporalmente

### Obtener SHA-1 de Debug (para testing)

```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Luego agrega este SHA-1 también en las restricciones (puedes tener múltiples SHA-1).

---

## 📝 Notas Importantes

- ⚠️ **Las restricciones pueden tardar unos minutos en aplicarse**
- ⚠️ **Si agregas restricciones muy estrictas, la app puede dejar de funcionar**
- ⚠️ **Para testing, puedes agregar temporalmente el SHA-1 de debug**
- ✅ **Las restricciones mejoran la seguridad de tus API Keys**

---

**Última actualización:** $(date)


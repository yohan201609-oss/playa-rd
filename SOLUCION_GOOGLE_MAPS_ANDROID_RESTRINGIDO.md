# 🔧 Solución: Google Maps Restringido en Android

## 📋 Problema

La clave de Google Maps para Android está restringida y no funciona, pero en iOS funciona correctamente.

**Clave de Android:** `AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus`  
**Clave de iOS:** `AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`

---

## ✅ Solución 1: Configurar Restricciones Correctamente (RECOMENDADO)

Esta es la solución correcta y segura. Necesitas agregar las restricciones correctas con el package name y SHA-1.

### Paso 1: Obtener el SHA-1 de Debug

Para desarrollo y testing, necesitas el SHA-1 del keystore de debug:

```powershell
cd android
.\gradlew signingReport
```

O usando keytool directamente:

```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Busca la línea `SHA1:`** y copia el valor (sin los dos puntos).

### Paso 2: Obtener el SHA-1 de Release (si tienes keystore)

Si ya tienes un keystore de release configurado:

```powershell
keytool -list -v -keystore "ruta/a/tu/keystore.jks" -alias tu_alias
```

### Paso 3: Configurar Restricciones en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Credentials**
4. Busca la API Key: `AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus`
5. Haz clic en el nombre de la API Key para editarla

#### Configurar Application Restrictions:

1. En **"Application restrictions"**, selecciona **"Android apps"**
2. Haz clic en **"+ Add an item"**
3. Agrega el SHA-1 de **DEBUG** (para desarrollo):
   - **Package name:** `com.playasrd.playasrd`
   - **SHA-1 certificate fingerprint:** [Pega el SHA-1 que obtuviste, SIN los dos puntos]
   - Ejemplo: `72F17A530F1BEBE00DDD1D920F565A8D2D0508E6`
4. Si tienes keystore de release, haz clic en **"+ Add an item"** nuevamente:
   - **Package name:** `com.playasrd.playasrd` (el mismo)
   - **SHA-1 certificate fingerprint:** [SHA-1 de release, SIN los dos puntos]

#### Configurar API Restrictions:

1. En **"API restrictions"**, selecciona **"Restrict key"**
2. Marca SOLO estas APIs:
   - ✅ **Maps SDK for Android**
   - ✅ **Geocoding API**
   - ✅ **Places API** (si la usas)
3. Haz clic en **"Save"**
4. Espera 1-2 minutos para que los cambios se propaguen

---

## ✅ Solución 2: Quitar Restricciones Temporalmente (SOLO PARA DESARROLLO)

⚠️ **ADVERTENCIA:** Esta solución es solo para desarrollo. NO uses esto en producción.

### Pasos:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Credentials**
4. Busca la API Key: `AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus`
5. Haz clic en el nombre de la API Key para editarla
6. En **"Application restrictions"**, selecciona **"None"**
7. Haz clic en **"Save"**
8. Espera 1-2 minutos

**⚠️ IMPORTANTE:** Vuelve a configurar las restricciones antes de publicar en producción.

---

## ✅ Solución 3: Usar la Misma Clave Sin Restricciones (NO RECOMENDADO)

Si quieres usar la misma clave que funciona en iOS para Android:

1. En `android/app/src/main/AndroidManifest.xml`, reemplaza la clave de Android con la de iOS:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4" />
```

⚠️ **ADVERTENCIA:** Esto no es recomendado porque:
- La clave de iOS puede tener restricciones para iOS apps
- No es una buena práctica de seguridad
- Puede causar problemas en el futuro

---

## 🔍 Verificar que Funciona

Después de aplicar cualquiera de las soluciones:

1. Espera 1-2 minutos para que los cambios se propaguen
2. Limpia el proyecto:
   ```powershell
   flutter clean
   flutter pub get
   ```
3. Compila y prueba:
   ```powershell
   flutter run
   ```
4. Verifica que el mapa se muestre correctamente en Android

---

## 📝 Información Importante

### Package Name
```
com.playasrd.playasrd
```

### SHA-1 Verificados (obtenidos de tu sistema)

**SHA-1 de Debug:**
```
72F17A530F1BEBE00DDD1D920F565A8D2D0508E6
```
*(Formato con dos puntos: `72:F1:7A:53:0F:1B:EB:E0:0D:DD:1D:92:0F:56:5A:8D:2D:05:08:E6`)*

**SHA-1 de Release:**
```
3B28ECD60C45155C9A6215344FBE771250F62486
```
*(Formato con dos puntos: `3B:28:EC:D6:0C:45:15:5C:9A:62:15:34:4F:BE:77:12:50:F6:24:86`)*

✅ **Estos son los SHA-1 que debes usar en Google Cloud Console (SIN los dos puntos).**

---

## 🆘 Solución de Problemas

### ❌ "API Key no autorizada" después de configurar restricciones

**Causas posibles:**
1. El SHA-1 no coincide exactamente
2. El package name es incorrecto
3. Solo agregaste el SHA-1 de release pero estás probando en debug
4. Las restricciones aún no se han propagado

**Soluciones:**
- Verifica que agregaste **AMBOS** SHA-1 (debug y release)
- Verifica que el package name sea exactamente: `com.playasrd.playasrd`
- Verifica que copiaste el SHA-1 **SIN los dos puntos** (`:`)
- Espera 2-3 minutos más

### ❌ El mapa sigue sin funcionar

1. Verifica que las APIs estén habilitadas:
   - Ve a **APIs & Services** > **Library**
   - Verifica que estén habilitadas:
     - ✅ Maps SDK for Android
     - ✅ Geocoding API
     - ✅ Places API (si la usas)

2. Verifica que la clave esté correcta en `AndroidManifest.xml`

3. Limpia y reconstruye:
   ```powershell
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

---

## 📚 Referencias

- [Documentación de restricciones de API Keys](https://cloud.google.com/docs/authentication/api-keys#restricting_apis)
- [Configurar Google Maps para Android](https://developers.google.com/maps/documentation/android-sdk/start)
- Ver también: `CONFIGURAR_RESTRICCIONES_API_KEYS.md`

---

**Última actualización:** Diciembre 2024


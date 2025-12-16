# 🔐 Instrucciones para Completar la Configuración del Keystore

## ✅ Paso 1: Completar el archivo `android/key.properties`

1. Abre el archivo `android/key.properties`
2. Reemplaza `TU_CONTRASEÑA` con la contraseña que usaste al crear el keystore (la misma en ambas líneas)
3. Guarda el archivo

**Ejemplo:**
```properties
storePassword=MiPassword123!
keyPassword=MiPassword123!
keyAlias=playas-rd
storeFile=C:\\Users\\Johan Almanzar\\playas-rd-release-key.jks
```

## ✅ Paso 2: Obtener el SHA-1 del Keystore

Ejecuta este comando en PowerShell (te pedirá la contraseña):

```powershell
keytool -list -v -keystore "C:\Users\Johan Almanzar\playas-rd-release-key.jks" -alias playas-rd
```

**Busca la línea que dice `SHA1:`** y copia el valor (sin los dos puntos).

**Ejemplo de salida:**
```
Certificate fingerprints:
     SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```

**Copia solo el valor:** `ABCDEF1234567890ABCDEF1234567890ABCDEF12`

## ✅ Paso 3: Usar el SHA-1 para Restricciones de API Keys

Necesitarás este SHA-1 para configurar las restricciones de API Keys en Google Cloud Console:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto: **playas-rd-2b475**
3. Ve a **APIs & Services** > **Credentials**
4. Edita la API Key de Google Maps
5. En **Application restrictions** > **Android apps**:
   - Package name: `com.playasrd.playasrd`
   - SHA-1: Pega el SHA-1 que obtuviste

## ✅ Paso 4: Probar el Build

Una vez completado `key.properties`, prueba generar el App Bundle:

```bash
flutter build appbundle --release
```

Si todo está correcto, deberías ver:
```
✓ Built build/app/outputs/bundle/release/app-release.aab
```

## ⚠️ Recordatorios Importantes

- **Guarda el keystore en un lugar seguro** (haz backup)
- **Guarda la contraseña** en un gestor de contraseñas
- **Si pierdes el keystore**, no podrás actualizar tu app en Google Play
- El archivo `key.properties` ya está en `.gitignore`, así que no se subirá al repositorio

---

**Ubicación del keystore:** `C:\Users\Johan Almanzar\playas-rd-release-key.jks`


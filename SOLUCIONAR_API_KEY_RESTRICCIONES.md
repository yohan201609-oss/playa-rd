# 🔧 Solucionar Error: "API Key no autorizada"

## Problema

Si ves este error en la consola:
```
❌ API Key rechazada por Google: This IP, site or mobile application is not authorized to use this API key
```

Significa que la API Key tiene restricciones que bloquean las solicitudes desde tu aplicación.

## Solución Rápida (Para Desarrollo) ✅ FUNCIONA

### Opción 1: Quitar Restricciones de Aplicación (Temporal) - SOLUCIÓN CONFIRMADA

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto "Playas RD"
3. Ve a **APIs & Services** > **Credentials**
4. Haz clic en tu API Key para editarla
5. En **"Application restrictions"**:
   - Selecciona **"None"** (Ninguna)
   - Haz clic en **"Save"**
6. Espera 1-2 minutos para que se apliquen los cambios
7. Reinicia la app

⚠️ **Advertencia:** Esto permite que cualquier aplicación use tu API Key. Solo úsalo para desarrollo.

✅ **Esta solución ha sido probada y funciona correctamente.**

### Opción 2: Configurar Restricciones Correctas (Recomendado)

#### Para Android:

1. Obtén el SHA-1 de tu aplicación:

   **Windows (PowerShell):**
   ```powershell
   cd $env:USERPROFILE\.android
   keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

   **O desde el proyecto:**
   ```bash
   cd android
   ./gradlew signingReport
   ```

2. Copia el SHA-1 (formato: `AA:BB:CC:DD:EE:FF:...`)

3. En Google Cloud Console:
   - Ve a tu API Key
   - En **"Application restrictions"**, selecciona **"Android apps"**
   - Haz clic en **"Add an item"**
   - Agrega:
     - **Package name**: `com.playasrd.playasrd`
     - **SHA-1 certificate fingerprint**: Pega el SHA-1 que copiaste
   - Haz clic en **"Save"**

#### Para iOS:

1. Obtén el Bundle Identifier:
   - Abre `ios/Runner.xcodeproj` en Xcode
   - Ve a la pestaña "Signing & Capabilities"
   - Copia el "Bundle Identifier" (ej: `com.playasrd.playasrd`)

2. En Google Cloud Console:
   - Ve a tu API Key
   - En **"Application restrictions"**, selecciona **"iOS apps"**
   - Haz clic en **"Add an item"**
   - Agrega el Bundle Identifier
   - Haz clic en **"Save"**

## Verificar Restricciones de API

Asegúrate de que estas APIs estén habilitadas y permitidas:

1. En Google Cloud Console, ve a tu API Key
2. En **"API restrictions"**:
   - Selecciona **"Restrict key"**
   - Verifica que estén seleccionadas:
     - ✅ **Geocoding API** (requerida)
     - ✅ **Places API** (recomendada)
     - ✅ **Maps SDK for Android** (si usas mapas)
     - ✅ **Maps SDK for iOS** (si usas mapas en iOS)

3. O temporalmente selecciona **"Don't restrict key"** para pruebas

## Verificar que las APIs estén Habilitadas

1. Ve a **APIs & Services** > **Library**
2. Busca y verifica que estén **habilitadas**:
   - **Geocoding API** - Debe estar habilitada
   - **Places API** - Recomendada
   - **Maps SDK for Android** - Si usas mapas
   - **Maps SDK for iOS** - Si usas mapas en iOS

## Obtener SHA-1 en Windows

### Método 1: Usando keytool (Debug)

```powershell
cd $env:USERPROFILE\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Método 2: Desde Gradle (Más preciso)

```bash
cd android
./gradlew signingReport
```

Busca en la salida:
```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
MD5: ...
SHA1: AA:BB:CC:DD:EE:FF:...  ← Este es el que necesitas
SHA-256: ...
```

### Método 3: Si tienes un keystore de release

```bash
keytool -list -v -keystore ruta/a/tu/keystore.jks -alias tu_alias
```

## Pasos Completos

1. ✅ Obtén el SHA-1 de tu aplicación
2. ✅ Ve a Google Cloud Console > Credentials
3. ✅ Edita tu API Key
4. ✅ Configura "Application restrictions" > "Android apps"
5. ✅ Agrega Package name y SHA-1
6. ✅ Verifica "API restrictions" > Geocoding API y Places API están seleccionadas
7. ✅ Guarda los cambios
8. ✅ Espera 1-2 minutos para que se apliquen los cambios
9. ✅ Reinicia la app y prueba de nuevo

## Verificar Package Name

El package name debe coincidir exactamente con el de tu aplicación:

**Android:** Verifica en `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.playasrd.playasrd"  // ← Este es el package name
    }
}
```

**iOS:** Verifica en `ios/Runner/Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.playasrd.playasrd</string>  // ← Este es el bundle ID
```

## Después de Configurar

1. Reinicia completamente la app (stop y start)
2. Verifica en la consola que no aparezca el error de autorización
3. Prueba la funcionalidad de actualizar coordenadas

## Troubleshooting

### Error persiste después de configurar

1. Verifica que el SHA-1 sea correcto (sin espacios, formato correcto)
2. Verifica que el Package name sea exactamente el mismo
3. Espera 2-3 minutos después de guardar los cambios
4. Verifica que las APIs estén habilitadas en el proyecto
5. Verifica que no haya restricciones de IP adicionales

### No encuentro el SHA-1

- Asegúrate de que el keystore exista
- Si es la primera vez que ejecutas la app, el debug.keystore se crea automáticamente
- Verifica la ruta: `C:\Users\TuUsuario\.android\debug.keystore`

### La API Key funciona en el navegador pero no en la app

- Las restricciones de aplicación son específicas para móvil
- Asegúrate de haber configurado las restricciones para Android/iOS, no solo para HTTP referrers


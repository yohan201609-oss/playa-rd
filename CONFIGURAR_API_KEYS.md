# 🔐 Guía: Configurar API Keys de forma segura

## ⚠️ Importante: Seguridad de API Keys

**NUNCA** subas claves API directamente en el código fuente. GitHub detecta automáticamente secretos expuestos y puede revocar las claves comprometidas.

## 📱 Configuración para iOS

### Google Maps API Key

1. **Copia el archivo template:**
   ```bash
   cd ios/Runner
   cp GoogleMaps-API-Key.h.template GoogleMaps-API-Key.h
   ```

2. **Edita el archivo `GoogleMaps-API-Key.h`:**
   - Abre el archivo en tu editor
   - Reemplaza `YOUR_API_KEY_HERE` con tu clave API real de Google Maps
   - Guarda el archivo

3. **Verifica que el archivo está en .gitignore:**
   - El archivo `GoogleMaps-API-Key.h` NO debe aparecer en `git status`
   - Solo el archivo `.template` debe estar en el repositorio

### Estructura de archivos:

```
ios/Runner/
├── GoogleMaps-API-Key.h.template  ✅ Se sube al repositorio
└── GoogleMaps-API-Key.h          ❌ NO se sube (en .gitignore)
```

## 🤖 Configuración para Android

### Google Maps API Key

Para Android, la clave se configura en `AndroidManifest.xml`. Si necesitas moverla a un archivo de configuración local:

1. **Crea el archivo de configuración:**
   ```bash
   mkdir -p android/app/src/main/res/values
   ```

2. **Crea `api_keys.xml` (NO se sube al repositorio):**
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <resources>
       <string name="google_maps_api_key">TU_API_KEY_AQUI</string>
   </resources>
   ```

3. **Actualiza `AndroidManifest.xml` para usar la clave:**
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="@string/google_maps_api_key" />
   ```

## 🔄 Rotar claves comprometidas

Si GitHub detectó que una clave fue expuesta:

1. **Ve a Google Cloud Console:**
   - https://console.cloud.google.com/apis/credentials

2. **Encuentra la clave comprometida**

3. **Rótala (crea una nueva y elimina la antigua):**
   - Crea una nueva clave API
   - Actualiza el archivo de configuración local con la nueva clave
   - Elimina o restringe la clave antigua

4. **Verifica las restricciones de la nueva clave:**
   - Limita por aplicación (Android/iOS)
   - Limita por IP si es necesario
   - Limita por referrer para web

## ✅ Verificación

Antes de hacer commit, verifica que no hay secretos:

```bash
# Verifica qué archivos se van a subir
git status

# Asegúrate de que GoogleMaps-API-Key.h NO aparece
# Solo debe aparecer GoogleMaps-API-Key.h.template
```

## 📚 Recursos adicionales

- [GitHub: Secret scanning](https://docs.github.com/en/code-security/secret-scanning)
- [Google Cloud: API Keys best practices](https://cloud.google.com/docs/authentication/api-keys)
- [Flutter: Environment variables](https://docs.flutter.dev/deployment/environment-variables)


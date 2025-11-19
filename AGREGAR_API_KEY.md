# 🔑 Cómo Agregar tu API Key de Google Maps

## Pasos Rápidos

### 1. Obtener tu API Key de Google Maps

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto (o crea uno nuevo)
3. Ve a **APIs & Services** > **Credentials**
4. Haz clic en **Create Credentials** > **API Key**
5. Copia la API Key generada

### 2. Habilitar las APIs necesarias

En Google Cloud Console, habilita:
- **Geocoding API** (requerida)
- **Places API** (recomendada, más precisa)

**Pasos:**
1. Ve a **APIs & Services** > **Library**
2. Busca "Geocoding API" y haz clic en **Enable**
3. Busca "Places API" y haz clic en **Enable**

### 3. Agregar la API Key al archivo .env

1. Abre el archivo `.env` en la raíz del proyecto
2. Reemplaza `tu_api_key_aqui` con tu API Key real:

```env
OPENWEATHER_API_KEY=d66b4180476d327226625ebd7ed46a99

GOOGLE_MAPS_API_KEY=AIzaSy...tu_api_key_real_aqui
```

**Importante:**
- ❌ NO uses comillas: `GOOGLE_MAPS_API_KEY="tu_key"` (incorrecto)
- ✅ SIN comillas: `GOOGLE_MAPS_API_KEY=tu_key` (correcto)
- ❌ NO uses espacios: `GOOGLE_MAPS_API_KEY = tu_key` (incorrecto)
- ✅ SIN espacios: `GOOGLE_MAPS_API_KEY=tu_key` (correcto)

### 4. Verificar que funciona

1. Ejecuta la app:
   ```bash
   flutter run
   ```

2. Busca en la consola:
   ```
   ✅ Google Maps API Key encontrada en .env
   ✅ Geocoding API disponible para actualizar coordenadas
   ```

3. Si ves esto, ¡está funcionando! 🎉

## Solución de Problemas

### Error: "API Key no encontrada"
- Verifica que el archivo `.env` esté en la raíz del proyecto (mismo nivel que `pubspec.yaml`)
- Verifica que la variable se llame exactamente `GOOGLE_MAPS_API_KEY` (mayúsculas)
- Verifica que no haya espacios alrededor del signo `=`

### Error: "REQUEST_DENIED"
- Verifica que las APIs estén habilitadas en Google Cloud Console
- Verifica que la API key tenga permisos para Geocoding API
- Verifica las restricciones de la API key (IP, referrer, etc.)

### Error: "API Key inválida"
- Verifica que la API key esté completa (no cortada)
- Verifica que no haya espacios al inicio o final
- Verifica que la API key no esté en comillas

## Ejemplo de archivo .env correcto

```env
# OpenWeather API Key (para el clima)
OPENWEATHER_API_KEY=d66b4180476d327226625ebd7ed46a99

# Google Maps API Key (para geocodificación)
GOOGLE_MAPS_API_KEY=AIzaSyCFt87v-m5pkKXVyPNLZ_EPCtxJH_p810Q
```

## Después de agregar la API Key

Una vez que agregues la API Key correcta:

1. **Reinicia la app** para que cargue la nueva variable
2. Ve a **Perfil** > **Actualizar Coordenadas**
3. Confirma la actualización
4. Las coordenadas se actualizarán usando Google Geocoding API

## Notas de Seguridad

- ⚠️ **NUNCA** subas el archivo `.env` a Git
- ⚠️ El archivo `.env` está en `.gitignore` (no se subirá)
- ⚠️ Mantén tu API Key segura y no la compartas públicamente
- ⚠️ Configura restricciones de API en Google Cloud Console para mayor seguridad


# 🔧 Solución: Error "No file or variants found for asset: .env"

## ❌ Problema

Al compilar en iOS (o cualquier plataforma), aparece el error:
```
No file or variants found for asset: .env
Target debug_ios_bundle_flutter_assets failed
Command PhaseScriptExecution failed with a nonzero exit code
```

## 🔍 Causa

El archivo `.env` está listado en `pubspec.yaml` como asset, pero el archivo no existe en el sistema de archivos. Flutter intenta incluirlo en el bundle y falla.

## ✅ Solución Rápida (Mac)

Ejecuta este comando en la terminal desde la raíz del proyecto:

```bash
# Crear el archivo .env vacío
cat > .env << 'EOF'
# Variables de entorno para Playas RD
OPENWEATHER_API_KEY=
MAPS_API_KEY=
GOOGLE_MAPS_API_KEY=
GOOGLE_API_KEY=
API_BASE_URL=
FIREBASE_API_KEY=
EOF
```

O usa el script incluido:

```bash
# Dar permisos de ejecución
chmod +x scripts/crear_env.sh

# Ejecutar el script
./scripts/crear_env.sh
```

## ✅ Solución Rápida (Windows)

Ejecuta este comando en PowerShell desde la raíz del proyecto:

```powershell
# Ejecutar el script
.\scripts\crear_env.ps1
```

O crea el archivo manualmente:

1. Crea un archivo llamado `.env` en la raíz del proyecto
2. Agrega este contenido:

```env
# Variables de entorno para Playas RD
OPENWEATHER_API_KEY=
MAPS_API_KEY=
GOOGLE_MAPS_API_KEY=
GOOGLE_API_KEY=
API_BASE_URL=
FIREBASE_API_KEY=
```

## 📝 Configurar API Keys (Opcional)

El archivo `.env` puede estar vacío y la app funcionará. Si necesitas configurar API keys:

### OpenWeatherMap (para clima)

1. Ve a https://openweathermap.org/api
2. Crea una cuenta gratuita
3. Obtén tu API Key
4. Agrega al `.env`:
   ```env
   OPENWEATHER_API_KEY=tu_clave_aqui
   ```

### Google Maps

Las claves de Google Maps están configuradas directamente en:
- **iOS**: `ios/Runner/GoogleMaps-API-Key.h`
- **Android**: `android/app/src/main/AndroidManifest.xml`

No necesitas configurarlas en `.env` a menos que uses servicios adicionales.

## ✅ Verificación

Después de crear el archivo, verifica:

```bash
# Verificar que el archivo existe
ls -la .env

# En Mac/Linux
cat .env

# En Windows PowerShell
Get-Content .env
```

Luego intenta compilar de nuevo:

```bash
flutter clean
flutter pub get
flutter build ios --no-codesign
```

## 🔒 Seguridad

**IMPORTANTE:** El archivo `.env` está en `.gitignore` y **NO se sube al repositorio**. Esto es correcto y seguro.

- ✅ El archivo `.env` es local
- ✅ Puede contener API keys sensibles
- ✅ No se sube a Git
- ✅ Cada desarrollador crea su propio `.env`

## 🆘 Si el Error Persiste

1. **Limpia el build:**
   ```bash
   flutter clean
   ```

2. **Verifica que el archivo existe:**
   ```bash
   ls -la .env
   ```

3. **Verifica pubspec.yaml:**
   - El archivo `.env` debe estar en la sección `assets:`
   - Debe estar en la raíz del proyecto

4. **Reconstruye:**
   ```bash
   flutter pub get
   flutter build ios --no-codesign
   ```

## 📚 Referencias

- Ver `GUIA_CONFIGURACIONES_PRODUCCION.md` para más detalles sobre configuración
- Ver `CONFIGURAR_API_KEYS.md` para configuración de API keys


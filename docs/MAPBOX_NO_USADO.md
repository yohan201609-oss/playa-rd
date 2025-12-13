# 🗑️ Mapbox No Se Está Usando - Configuraciones Residuales

**Fecha:** $(Get-Date -Format "yyyy-MM-dd")  
**Estado:** ❌ Mapbox NO se usa actualmente en el proyecto

---

## 📋 Análisis

### ✅ Lo que SÍ se usa:
- **Google Maps** (`google_maps_flutter: ^2.5.3`)
  - Usado en `lib/screens/map_screen.dart`
  - Usado en `lib/screens/beach_detail_screen.dart`
  - API Key configurada en `AndroidManifest.xml`
  - API Key configurada en `.env` como `GOOGLE_MAPS_API_KEY`

### ❌ Lo que NO se usa (residual):
- **Mapbox** - No hay ninguna importación en el código Dart
- Configuraciones residuales encontradas (pueden eliminarse)

---

## 🗂️ Archivos Residuales de Mapbox

### 1. `android/app/src/main/res/values/mapbox_access_token.xml`
- **Contenido:** Token de Mapbox hardcoded
- **Token:** `pk.eyJ1Ijoiam9oYW4yNCIsImEiOiJjbWc0Znl6bnQxaGpjMndwdnlrdnBvbWFnIn0.E9INeyqu0C6gboE0V1ubpQ`
- **Acción:** Eliminar (no se usa)

### 2. `web/index.html`
- **Línea 24:** `<meta name="MAPBOX_ACCESS_TOKEN" content="...">`
- **Acción:** Eliminar meta tag (no se usa)

### 3. `.mapbox_token`
- **Ubicación:** Raíz del proyecto
- **Contenido:** Token de Mapbox
- **Acción:** Eliminar (no se usa, además debería estar en `.gitignore`)

### 4. `android/build.gradle.kts`
- **Líneas 5-16:** Repositorio Maven de Mapbox
- **Acción:** Eliminar repositorio Maven (no se usa)

### 5. `android/gradle.properties`
- **Línea 29:** `MAPBOX_DOWNLOADS_TOKEN=your_mapbox_downloads_token_here`
- **Acción:** Eliminar o comentar (no se usa)

---

## ✅ Recomendación

**Eliminar todas las configuraciones residuales de Mapbox** ya que:
1. No se están usando en el código
2. Representan un riesgo de seguridad (tokens expuestos)
3. Crean confusión sobre qué servicio de mapas se usa
4. Aumentan el tamaño innecesario del proyecto

---

## 🔧 Pasos para Limpiar

1. ✅ Eliminar `android/app/src/main/res/values/mapbox_access_token.xml`
2. ✅ Eliminar meta tag de Mapbox en `web/index.html`
3. ✅ Eliminar `.mapbox_token` de la raíz
4. ✅ Eliminar repositorio Maven de Mapbox en `android/build.gradle.kts`
5. ✅ Eliminar/Comentar `MAPBOX_DOWNLOADS_TOKEN` en `android/gradle.properties`

---

**Nota:** El README.md menciona Mapbox pero está desactualizado. El proyecto usa Google Maps actualmente.


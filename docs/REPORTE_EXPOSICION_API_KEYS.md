# 🔒 Reporte de Exposición de API Keys y Credenciales

**Fecha:** $(Get-Date -Format "yyyy-MM-dd")  
**Proyecto:** Playas RD Flutter  
**Prioridad:** 🔴 ALTA

---

## 📋 Resumen Ejecutivo

Se han identificado múltiples credenciales sensibles expuestas directamente en el código fuente. Esto representa un riesgo de seguridad significativo, especialmente si el código está en un repositorio público.

---

## 🚨 Credenciales Expuestas

### 1. **Google Maps API Key** - CRÍTICO ⚠️

**Valor:** `AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus`

**Ubicaciones:**
- ✅ `android/app/src/main/AndroidManifest.xml` (línea 51)
- ✅ `lib/services/google_places_service.dart` (línea 23 - hardcoded como fallback)
- ✅ `lib/services/google_geocoding_service.dart` (línea 56 - hardcoded como fallback)

**Riesgo:** ALTO - Puede ser extraída del APK y usada por terceros, generando costos no autorizados.

---

### 2. **Mapbox Access Token** - CRÍTICO ⚠️

**Valor:** `pk.eyJ1Ijoiam9oYW4yNCIsImEiOiJjbWc0Znl6bnQxaGpjMndwdnlrdnBvbWFnIn0.E9INeyqu0C6gboE0V1ubpQ`

**Ubicaciones:**
- ✅ `android/app/src/main/res/values/mapbox_access_token.xml` (línea 3)
- ✅ `web/index.html` (línea 24)
- ✅ `.mapbox_token` (archivo raíz)

**Riesgo:** ALTO - Token de acceso público de Mapbox, puede ser usado por terceros.

---

### 3. **Firebase API Keys** - INFORMATIVO ℹ️

**Valores expuestos:**
- Web: `AIzaSyDM9AnOHCBlyKJ98jNI_5r1y-xfAcJYLgI`
- Android: `AIzaSyDFS0POsHWn9azaDIAviZM8FlUSjf8_fVs`
- iOS/macOS: `AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`

**Ubicaciones:**
- ✅ `lib/firebase_options.dart` (líneas 45, 56, 65, 77, 89)
- ✅ `web/firebase-messaging-sw.js` (línea 7)
- ✅ `ios/Runner/GoogleService-Info.plist` (línea 10)

**Riesgo:** BAJO-MEDIO - Las Firebase API Keys están diseñadas para ser públicas, pero deben tener restricciones configuradas en Firebase Console.

**Recomendación:** Verificar que las restricciones estén configuradas correctamente en Firebase Console.

---

### 4. **AdMob App IDs** - INFORMATIVO ℹ️

**Valores:**
- Android: `ca-app-pub-2612958934827252~9650417470`
- iOS: `ca-app-pub-2612958934827252~4943084922`

**Ubicaciones:**
- ✅ `android/app/src/main/AndroidManifest.xml` (línea 56)
- ✅ `ios/Runner/Info.plist` (línea 68)
- ✅ `lib/services/admob_service.dart` (líneas 26, 28, 35, 37)

**Riesgo:** BAJO - Los App IDs de AdMob son públicos por diseño, pero deben estar protegidos por restricciones en Google AdMob.

---

### 5. **Mapbox Downloads Token** - INFORMATIVO ℹ️

**Ubicación:**
- ✅ `android/gradle.properties` (línea 29) - Actualmente es un placeholder

**Valor actual:** `your_mapbox_downloads_token_here`

**Riesgo:** NINGUNO - Es un placeholder, pero debe asegurarse de usar variables de entorno cuando se configure.

---

## 🛠️ Soluciones Recomendadas

### Solución 1: Variables de Entorno (Recomendado)

**Para Google Maps API Key:**

1. **Mover a archivo .env:**
   ```env
   GOOGLE_MAPS_API_KEY=AIzaSyBnUosAkC0unrpG6zCfL9JbFTrhW4VKHus
   ```

2. **Eliminar hardcoded values:**
   - Remover del `AndroidManifest.xml` (usar BuildConfig o recursos)
   - Eliminar fallbacks hardcoded de los servicios Dart

3. **Cargar desde recursos:**
   - Android: Usar `BuildConfig` o recursos desde `res/values/api_keys.xml` (que debe estar en `.gitignore`)

**Para Mapbox Token:**

1. **Mover a archivo .env o variable de entorno:**
   ```env
   MAPBOX_ACCESS_TOKEN=pk.eyJ1Ijoiam9oYW4yNCIsImEiOiJjbWc0Znl6bnQxaGpjMndwdnlrdnBvbWFnIn0.E9INeyqu0C6gboE0V1ubpQ
   ```

2. **Para Android:** Generar `res/values/api_keys.xml` en tiempo de build o desde CI/CD

3. **Para Web:** Cargar desde variable de entorno en el servidor o usar secrets del hosting

---

### Solución 2: Restricciones en Consolas (CRÍTICO)

**Google Cloud Console:**
1. Ir a [Google Cloud Console](https://console.cloud.google.com/)
2. Seleccionar el proyecto
3. Navegar a "APIs & Services" > "Credentials"
4. Para cada API Key:
   - Agregar **restricciones de aplicación** (package name, bundle ID)
   - Agregar **restricciones de API** (solo las APIs necesarias)
   - Configurar **restricciones HTTP referrers** para web

**Mapbox Account:**
1. Ir a [Mapbox Account](https://account.mapbox.com/)
2. Navegar a "Access tokens"
3. Configurar restricciones de URL y scopes
4. Considerar usar tokens diferentes para desarrollo y producción

**Firebase Console:**
1. Verificar que las API Keys tengan restricciones configuradas
2. Revisar reglas de seguridad de Firestore y Storage
3. Configurar App Check para prevenir uso no autorizado

---

### Solución 3: Archivos de Configuración Excluidos

**Asegurar que `.gitignore` incluya:**
```
# Ya está configurado correctamente:
.env
.env.local
android/app/src/main/res/values/api_keys.xml
.mapbox_token
```

**Crear archivos de ejemplo:**
- `.env.example` - con placeholders
- `android/app/src/main/res/values/api_keys.xml.example` - con placeholders

---

## ✅ Checklist de Acciones Inmediatas

### Prioridad Alta 🔴
- [ ] Rotar Google Maps API Key y aplicar restricciones
- [ ] Rotar Mapbox Access Token y aplicar restricciones
- [ ] Eliminar valores hardcoded de los servicios Dart
- [ ] Mover credenciales a variables de entorno
- [ ] Verificar que `.gitignore` protege archivos sensibles

### Prioridad Media 🟡
- [ ] Revisar y configurar restricciones en Firebase Console
- [ ] Crear archivos `.env.example` para documentación
- [ ] Configurar CI/CD para inyectar variables de entorno
- [ ] Revisar historial de Git y considerar rotar todas las credenciales expuestas

### Prioridad Baja 🟢
- [ ] Documentar proceso de configuración de credenciales
- [ ] Implementar validación de credenciales en tiempo de ejecución
- [ ] Considerar usar secrets management (Azure Key Vault, AWS Secrets Manager, etc.)

---

## 📝 Notas Importantes

1. **Firebase API Keys:** Aunque están expuestas, esto es normal. Lo importante es tener restricciones configuradas.

2. **AdMob App IDs:** Son públicos por diseño, pero deben estar asociados a tu cuenta de Google AdMob.

3. **Google Maps API Key:** Esta es la más crítica. Si ya está comprometida, debe rotarse inmediatamente.

4. **Historial de Git:** Si el código está en un repositorio público, considerar:
   - Rotar TODAS las credenciales expuestas
   - Revisar si alguien las ha usado sin autorización
   - Considerar limpiar el historial (requiere cuidado)

---

## 🔗 Recursos Útiles

- [Google Cloud Console - API Credentials](https://console.cloud.google.com/apis/credentials)
- [Mapbox Account - Access Tokens](https://account.mapbox.com/access-tokens/)
- [Firebase Console - Project Settings](https://console.firebase.google.com/)
- [Flutter - Environment Variables](https://docs.flutter.dev/development/tools/flutter-tool#environment-variables)
- [Android - Build Config](https://developer.android.com/studio/build/gradle-tips#share-custom-fields-and-resource-values-with-your-app-code)

---

**Generado automáticamente**  
**Última revisión:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")


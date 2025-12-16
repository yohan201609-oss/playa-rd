# 🔧 Solución: Error AdMob "No ad to show" (Código 1)

**Proyecto:** Playas RD Flutter  
**Error:** `Request Error: No ad to show.` (Código: 1)

---

## 📋 Problema

En los logs de la consola aparece:

```
❌ Error cargando anuncio banner:
Código: 1
Dominio: com.google.admob
Mensaje: Request Error: No ad to show.
▲ Solicitud inválida - Verifica el Ad Unit ID
```

El **código 1** corresponde a `ERROR_CODE_INVALID_REQUEST`, que indica un problema con la configuración del Ad Unit ID.

---

## 🔍 Causas Posibles

1. **Ad Unit ID no existe o no está activo** en AdMob
2. **Ad Unit ID incorrecto** o mal copiado
3. **App no vinculada correctamente** a AdMob
4. **Ad Unit ID de producción** pero la app está en modo desarrollo
5. **No hay anuncios disponibles** para ese Ad Unit ID (puede tardar hasta 24 horas)

---

## ✅ Solución Paso a Paso

### Paso 1: Verificar Ad Unit IDs en el Código

Abre el archivo `lib/services/admob_service.dart` y verifica:

```dart
// IDs de producción (líneas 23-24)
static const String _productionBannerAdUnitId = 'ca-app-pub-2612958934827252/5832453782';
static const String _productionInterstitialAdUnitId = 'ca-app-pub-2612958934827252/7996540555';
```

**Verifica que estos IDs sean correctos.**

---

### Paso 2: Verificar en AdMob Console

1. **Accede a AdMob Console:**
   - Ve a: https://apps.admob.com/
   - Inicia sesión con tu cuenta de Google

2. **Verifica tu App:**
   - Ve a **Apps** en el menú lateral
   - Busca tu app: **Playas RD** (o el nombre que le diste)
   - Verifica que el **App ID** sea: `ca-app-pub-2612958934827252~9650417470`

3. **Verifica las Ad Units:**
   - Haz clic en tu app
   - Ve a la pestaña **Ad units**
   - Busca las siguientes Ad Units:
     - **Banner:** `ca-app-pub-2612958934827252/5832453782`
     - **Interstitial:** `ca-app-pub-2612958934827252/7996540555`

4. **Verifica el Estado:**
   - Cada Ad Unit debe estar **"Ready"** o **"Active"**
   - Si dice **"Getting ready"**, espera hasta 24 horas
   - Si dice **"Error"** o **"Paused"**, hay un problema

---

### Paso 3: Verificar Configuración de la App

#### Para iOS:

Verifica que en `ios/Runner/Info.plist` esté configurado:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-2612958934827252~9650417470</string>
```

#### Para Android:

Verifica que en `android/app/src/main/AndroidManifest.xml` esté configurado:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-2612958934827252~9650417470"/>
```

---

### Paso 4: Usar Ad Unit IDs de Prueba (Temporal)

Si quieres verificar que AdMob funciona correctamente, puedes usar los IDs de prueba temporalmente:

1. **Abre:** `lib/services/admob_service.dart`

2. **Cambia temporalmente a modo test:**
   ```dart
   // Línea 14 - Cambiar de false a true
   bool _isTestMode = true; // Cambiar a true para usar IDs de prueba
   ```

3. **Los IDs de prueba son:**
   ```dart
   // Banner de prueba: ca-app-pub-3940256099942544/6300978111
   // Interstitial de prueba: ca-app-pub-3940256099942544/1033173712
   ```

4. **Ejecuta la app:**
   ```bash
   flutter run
   ```

5. **Si los anuncios de prueba funcionan:**
   - El problema está en tus Ad Unit IDs de producción
   - Vuelve a cambiar `_isTestMode = false`
   - Continúa con el siguiente paso

---

### Paso 5: Crear Nuevas Ad Units (Si no existen)

Si las Ad Units no existen en AdMob:

1. **En AdMob Console:**
   - Ve a tu app: **Playas RD**
   - Haz clic en **Ad units** > **Add ad unit**

2. **Crear Banner Ad Unit:**
   - **Tipo:** Banner
   - **Nombre:** "Banner Principal" (o el que prefieras)
   - **Formato:** Standard
   - **Copia el nuevo Ad Unit ID**

3. **Crear Interstitial Ad Unit:**
   - **Tipo:** Interstitial
   - **Nombre:** "Interstitial Principal"
   - **Copia el nuevo Ad Unit ID**

4. **Actualizar el código:**
   - Abre `lib/services/admob_service.dart`
   - Reemplaza los IDs en las líneas 23-24:
   ```dart
   static const String _productionBannerAdUnitId = 'TU_NUEVO_BANNER_ID';
   static const String _productionInterstitialAdUnitId = 'TU_NUEVO_INTERSTITIAL_ID';
   ```

---

### Paso 6: Verificar que la App esté Vinculada

1. **En AdMob Console:**
   - Ve a **Apps** > Tu app
   - Verifica que el **Bundle ID** (iOS) o **Package name** (Android) coincida:
     - iOS: `com.playasrd.playasrd`
     - Android: `com.playasrd.playasrd`

2. **Si no coincide:**
   - Edita la app en AdMob
   - Actualiza el Bundle ID/Package name
   - O crea una nueva app con el Bundle ID correcto

---

### Paso 7: Esperar Propagación (Si acabas de crear las Ad Units)

**⚠️ IMPORTANTE:** Si acabas de crear las Ad Units, pueden tardar hasta **24 horas** en estar completamente activas y mostrar anuncios.

Durante este tiempo:
- Los anuncios pueden no mostrarse
- Puedes ver el error "No ad to show"
- Esto es **normal** y se resolverá automáticamente

---

### Paso 8: Verificar Políticas de AdMob

Asegúrate de que tu app cumpla con las políticas de AdMob:

1. **Ve a:** AdMob Console > **Policy center**
2. **Verifica** que no haya violaciones
3. **Si hay violaciones**, corrígelas antes de que los anuncios funcionen

---

## 🔄 Solución Rápida: Usar Modo Test Temporalmente

Si necesitas verificar que todo funciona mientras esperas que las Ad Units de producción estén listas:

1. **Edita:** `lib/services/admob_service.dart`
2. **Línea 14:** Cambia a `bool _isTestMode = true;`
3. **Ejecuta:** `flutter run`
4. **Verifica** que los anuncios de prueba se muestren
5. **Vuelve a cambiar** a `false` cuando las Ad Units de producción estén listas

---

## ✅ Verificación Final

Después de seguir los pasos, verifica:

- [ ] App ID configurado correctamente en `Info.plist` (iOS) y `AndroidManifest.xml` (Android)
- [ ] Ad Unit IDs existen en AdMob Console
- [ ] Ad Unit IDs están en estado "Ready" o "Active"
- [ ] Bundle ID/Package name coincide en AdMob y en el código
- [ ] Código actualizado con los Ad Unit IDs correctos
- [ ] App cumple con políticas de AdMob

---

## 🆘 Si el Problema Persiste

### Opción 1: Verificar Logs Detallados

Agrega más logs en `admob_service.dart`:

```dart
void _loadBannerAd() {
  final adUnitId = widget.adUnitId ?? adService.bannerAdUnitId;
  print('🔍 Intentando cargar anuncio con ID: $adUnitId');
  print('🔍 Modo: ${adService._isTestMode ? "TEST" : "PRODUCCIÓN"}');
  // ... resto del código
}
```

### Opción 2: Contactar Soporte de AdMob

Si después de 24-48 horas los anuncios no funcionan:

1. Ve a: https://support.google.com/admob/
2. Crea un ticket de soporte
3. Incluye:
   - App ID
   - Ad Unit IDs
   - Bundle ID/Package name
   - Logs del error

### Opción 3: Verificar Configuración de Firebase

Asegúrate de que AdMob esté vinculado a Firebase:

1. Ve a: Firebase Console > Tu proyecto
2. Verifica que AdMob esté habilitado
3. Si no está, habilítalo desde Firebase Console

---

## 📝 Notas Importantes

- **Tiempo de propagación:** Las nuevas Ad Units pueden tardar hasta 24 horas en estar activas
- **Anuncios de prueba:** Siempre funcionan inmediatamente
- **Código 1:** Generalmente significa que el Ad Unit ID no existe o no está activo
- **Código 3:** Significa "No fill" (no hay anuncios disponibles en este momento, pero la configuración está correcta)

---

## 🔗 Referencias

- [Documentación de AdMob](https://developers.google.com/admob)
- [Troubleshooting AdMob](https://developers.google.com/admob/ios/troubleshooting)
- [Ad Unit IDs de Prueba](https://developers.google.com/admob/ios/test-ads)

---

**Última actualización:** Enero 2025


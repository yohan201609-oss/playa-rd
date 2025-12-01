# 📱 Guía: Crear Ad Units para iOS en AdMob

**Proyecto:** Playas RD Flutter  
**Objetivo:** Crear Ad Units específicos para iOS en AdMob Console

---

## 📋 Pasos para Crear Ad Units en AdMob

### Paso 1: Acceder a AdMob Console

1. Ve a: https://apps.admob.com/
2. Inicia sesión con tu cuenta de Google
3. Asegúrate de estar en el proyecto correcto

---

### Paso 2: Seleccionar o Crear la App iOS

#### Si ya tienes la app iOS:

1. Ve a **Apps** en el menú lateral
2. Busca tu app iOS: **Playas RD** (iOS)
3. Haz clic en ella

#### Si NO tienes la app iOS:

1. Ve a **Apps** > **Add app**
2. Selecciona **iOS**
3. Completa la información:
   - **App name:** Playas RD
   - **Bundle ID:** `com.playasrd.playasrd`
   - **App Store:** (opcional, puedes dejarlo en blanco por ahora)
4. Haz clic en **Add app**

---

### Paso 3: Crear Banner Ad Unit

1. En la página de tu app iOS, haz clic en **Ad units** > **Add ad unit**

2. **Configuración del Banner:**
   - **Ad format:** Selecciona **Banner**
   - **Ad unit name:** "Banner Principal iOS" (o el nombre que prefieras)
   - **Ad size:** Standard (320x50) - Recomendado
   - Haz clic en **Create ad unit**

3. **Copia el Ad Unit ID:**
   - Se mostrará algo como: `ca-app-pub-2612958934827252/XXXXXXXXXX`
   - **Copia este ID completo**

---

### Paso 4: Crear Interstitial Ad Unit

1. Haz clic en **Add ad unit** nuevamente

2. **Configuración del Interstitial:**
   - **Ad format:** Selecciona **Interstitial**
   - **Ad unit name:** "Interstitial Principal iOS"
   - Haz clic en **Create ad unit**

3. **Copia el Ad Unit ID:**
   - Se mostrará otro ID diferente
   - **Copia este ID completo**

---

### Paso 5: Actualizar el Código

1. **Abre el archivo:** `lib/services/admob_service.dart`

2. **Busca las líneas 25-27** (IDs de producción para iOS):

```dart
// IDs de producción para iOS
static const String _productionBannerAdUnitIdIOS = 'ca-app-pub-2612958934827252/XXXXXXXXXX';
static const String _productionInterstitialAdUnitIdIOS = 'ca-app-pub-2612958934827252/XXXXXXXXXX';
```

3. **Reemplaza los IDs:**

```dart
// IDs de producción para iOS
static const String _productionBannerAdUnitIdIOS = 'TU_BANNER_ID_IOS_AQUI';
static const String _productionInterstitialAdUnitIdIOS = 'TU_INTERSTITIAL_ID_IOS_AQUI';
```

**Ejemplo:**
```dart
// IDs de producción para iOS
static const String _productionBannerAdUnitIdIOS = 'ca-app-pub-2612958934827252/1234567890';
static const String _productionInterstitialAdUnitIdIOS = 'ca-app-pub-2612958934827252/0987654321';
```

4. **Guarda el archivo**

---

### Paso 6: Verificar que el Código Funciona

El código ya está configurado para detectar automáticamente la plataforma:

```dart
String get bannerAdUnitId {
  if (_isTestMode) {
    return _testBannerAdUnitId; // IDs de prueba funcionan en todas las plataformas
  }
  return Platform.isIOS ? _productionBannerAdUnitIdIOS : _productionBannerAdUnitIdAndroid;
}
```

Esto significa que:
- ✅ En **Android**: Usará los IDs de Android
- ✅ En **iOS**: Usará los IDs de iOS
- ✅ En **modo test**: Usará los IDs de prueba (funcionan en todas las plataformas)

---

## ⚠️ Tiempo de Activación

**IMPORTANTE:** Las nuevas Ad Units pueden tardar hasta **24 horas** en estar completamente activas y mostrar anuncios.

Durante este tiempo:
- Puedes ver el error "No ad to show"
- Esto es **normal** y se resolverá automáticamente
- Puedes usar el modo test mientras esperas

---

## 🧪 Probar con Anuncios de Prueba

Mientras esperas que las Ad Units de producción estén activas:

1. **Abre:** `lib/services/admob_service.dart`
2. **Línea 14:** Cambia a `bool _isTestMode = true;`
3. **Ejecuta:** `flutter run -d ios`
4. **Verifica** que los anuncios de prueba se muestren

Los anuncios de prueba funcionan inmediatamente y en todas las plataformas.

---

## ✅ Verificación Final

Después de crear los Ad Units y actualizar el código:

1. **Verifica en AdMob Console:**
   - [ ] App iOS creada con Bundle ID: `com.playasrd.playasrd`
   - [ ] Banner Ad Unit creado y copiado
   - [ ] Interstitial Ad Unit creado y copiado
   - [ ] Estado de las Ad Units: "Ready" o "Getting ready"

2. **Verifica en el código:**
   - [ ] IDs actualizados en `admob_service.dart`
   - [ ] IDs tienen el formato correcto: `ca-app-pub-XXXXXXXXXX/XXXXXXXXXX`
   - [ ] No hay espacios o caracteres extra

3. **Prueba la app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d ios
   ```

---

## 📝 Estructura de Ad Units

Después de crear todo, deberías tener:

### Android:
- Banner: `ca-app-pub-2612958934827252/5832453782`
- Interstitial: `ca-app-pub-2612958934827252/7996540555`

### iOS:
- Banner: `ca-app-pub-2612958934827252/TU_BANNER_ID_IOS`
- Interstitial: `ca-app-pub-2612958934827252/TU_INTERSTITIAL_ID_IOS`

---

## 🔍 Ubicación de los IDs en el Código

Los IDs están en `lib/services/admob_service.dart`:

```dart
// Líneas 16-20: IDs de prueba (no cambiar)
static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

// Líneas 22-24: IDs de producción para Android (ya configurados)
static const String _productionBannerAdUnitIdAndroid = 'ca-app-pub-2612958934827252/5832453782';
static const String _productionInterstitialAdUnitIdAndroid = 'ca-app-pub-2612958934827252/7996540555';

// Líneas 25-27: IDs de producción para iOS (AQUÍ DEBES PONER TUS IDs)
static const String _productionBannerAdUnitIdIOS = 'ca-app-pub-2612958934827252/XXXXXXXXXX';
static const String _productionInterstitialAdUnitIdIOS = 'ca-app-pub-2612958934827252/XXXXXXXXXX';
```

---

## 🆘 Solución de Problemas

### Error: "No ad to show" después de crear los Ad Units

**Solución:** Espera hasta 24 horas. Las nuevas Ad Units necesitan tiempo para activarse.

### Error: "Invalid Ad Unit ID"

**Solución:** 
1. Verifica que copiaste el ID completo
2. Verifica que no hay espacios
3. Verifica que el ID empieza con `ca-app-pub-`

### Los anuncios no se muestran en iOS pero sí en Android

**Solución:**
1. Verifica que creaste la app iOS en AdMob
2. Verifica que el Bundle ID coincide: `com.playasrd.playasrd`
3. Verifica que actualizaste los IDs en el código

---

## 📚 Referencias

- [Documentación de AdMob](https://developers.google.com/admob)
- [Crear Ad Units](https://support.google.com/admob/answer/3054058)
- [Ad Unit IDs de Prueba](https://developers.google.com/admob/ios/test-ads)

---

**Última actualización:** Enero 2025


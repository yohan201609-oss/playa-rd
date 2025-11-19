# Guía de Configuración de AdMob

Esta guía te ayudará a configurar Google AdMob en tu aplicación Flutter "Playas RD".

## 📋 Requisitos Previos

1. Una cuenta de Google AdMob (https://admob.google.com/)
2. Una aplicación Flutter configurada
3. Firebase configurado (ya lo tienes configurado)

## 🚀 Pasos de Configuración

### 1. Crear una Cuenta de AdMob

1. Visita [Google AdMob](https://admob.google.com/)
2. Inicia sesión con tu cuenta de Google
3. Acepta los términos y condiciones
4. Completa el proceso de registro

### 2. Crear una Aplicación en AdMob

1. En la consola de AdMob, ve a **Aplicaciones** > **Añadir aplicación**
2. Selecciona la plataforma (Android o iOS)
3. Ingresa el nombre de tu aplicación: **Playas RD**
4. Selecciona si tu aplicación está en Google Play Store o App Store
   - Si ya está publicada, selecciona **Sí** y busca tu aplicación
   - Si no está publicada, selecciona **No, aún no**
5. Copia el **App ID** que se te proporciona

### 3. Configurar App ID en Android

1. Abre el archivo `android/app/src/main/AndroidManifest.xml`
2. Busca la sección de AdMob App ID:
```xml
<!-- AdMob App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```
3. Reemplaza `ca-app-pub-3940256099942544~3347511713` con tu **App ID real de AdMob**
4. El formato debe ser: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`

### 4. Configurar App ID en iOS

1. Abre el archivo `ios/Runner/Info.plist`
2. Busca la sección de AdMob App ID:
```xml
<!-- AdMob App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```
3. Reemplaza `ca-app-pub-3940256099942544~1458002511` con tu **App ID real de AdMob**
4. El formato debe ser: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`

### 5. Crear Unidades de Anuncios

#### Para Android:
1. En AdMob, ve a **Aplicaciones** > Selecciona tu app Android
2. Haz clic en **Añadir unidad de anuncios**
3. Selecciona el tipo de anuncio:
   - **Banner**: Para anuncios en la parte inferior/superior
   - **Intersticial**: Para anuncios de pantalla completa
   - **Recompensado**: Para anuncios con recompensas
4. Configura la unidad de anuncios:
   - Nombre: Ej. "Banner Home"
   - Tipo: Banner
5. Copia el **Ad Unit ID** que se te proporciona

#### Para iOS:
1. Repite el proceso para iOS
2. Crea las mismas unidades de anuncios
3. Copia los **Ad Unit IDs** de iOS

### 6. Configurar Ad Unit IDs en el Código

1. Abre el archivo `lib/services/admob_service.dart`
2. Busca las constantes de producción:
```dart
// IDs de producción (configurar estos después de crear anuncios en AdMob)
static const String _productionBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _productionInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _productionRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```
3. Reemplaza los valores con tus **Ad Unit IDs reales**:
   - `_productionBannerAdUnitId`: ID del anuncio banner
   - `_productionInterstitialAdUnitId`: ID del anuncio intersticial
   - `_productionRewardedAdUnitId`: ID del anuncio con recompensa

### 7. Modo de Prueba vs Producción

El servicio de AdMob está configurado para usar **anuncios de prueba** automáticamente cuando la app está en modo debug. Los anuncios de prueba tienen estos IDs:

- **Banner**: `ca-app-pub-3940256099942544/6300978111`
- **Intersticial**: `ca-app-pub-3940256099942544/1033173712`
- **Recompensado**: `ca-app-pub-3940256099942544/5224354917`

Para cambiar a modo producción, modifica el código en `lib/services/admob_service.dart`:

```dart
bool _isTestMode = false; // Cambiar a false para producción
```

**⚠️ IMPORTANTE**: No uses anuncios reales durante el desarrollo. Siempre usa anuncios de prueba hasta que estés listo para publicar.

### 8. Instalar Dependencias

Ejecuta el siguiente comando para instalar las dependencias:

```bash
flutter pub get
```

### 9. Configurar iOS (Solo para iOS)

Si estás desarrollando para iOS, necesitas agregar el SDK de AdMob:

1. Abre `ios/Podfile`
2. Verifica que el target iOS sea 11.0 o superior:
```ruby
platform :ios, '11.0'
```
3. Ejecuta:
```bash
cd ios
pod install
cd ..
```

### 10. Probar la Configuración

1. Ejecuta la aplicación en modo debug:
```bash
flutter run
```
2. Verifica que los anuncios de prueba se muestren correctamente
3. Revisa los logs en la consola para confirmar que AdMob se inicializó correctamente

## 📱 Uso de Anuncios en la Aplicación

### Anuncios Banner

Los anuncios banner ya están integrados en la pantalla de inicio (`HomeScreen`). Aparecerán al final de la lista de playas.

Para agregar un banner en otra pantalla:

```dart
import '../services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// En tu widget:
BannerAdWidget(
  adSize: AdSize.banner,
)
```

### Anuncios Intersticiales

Para mostrar un anuncio intersticial (pantalla completa):

```dart
import '../services/admob_service.dart';

// Cargar el anuncio
final interstitialAd = InterstitialAdHelper();
await interstitialAd.loadInterstitialAd();

// Mostrar el anuncio cuando esté listo
if (interstitialAd.isAdReady) {
  await interstitialAd.showInterstitialAd();
}
```

### Anuncios con Recompensa

Para mostrar un anuncio con recompensa:

```dart
import '../services/admob_service.dart';

// Cargar el anuncio
final rewardedAd = RewardedAdHelper();
await rewardedAd.loadRewardedAd();

// Mostrar el anuncio cuando esté listo
if (rewardedAd.isAdReady) {
  await rewardedAd.showRewardedAd(
    onRewarded: (reward) {
      print('Recompensa: ${reward.amount} ${reward.type}');
      // Dar la recompensa al usuario
    },
    onAdFailedToShow: () {
      print('Error mostrando anuncio');
    },
  );
}
```

## 🎯 Mejores Prácticas

1. **No muestres anuncios durante acciones críticas**: Evita mostrar anuncios cuando el usuario está realizando una acción importante (como guardar datos).

2. **Usa anuncios de prueba durante el desarrollo**: Siempre usa los IDs de prueba durante el desarrollo para evitar problemas con tu cuenta de AdMob.

3. **Maneja errores correctamente**: El servicio maneja errores automáticamente, pero siempre verifica si el anuncio se cargó correctamente antes de mostrarlo.

4. **No abuses de los anuncios**: Demasiados anuncios pueden afectar la experiencia del usuario negativamente.

5. **Respeta las políticas de AdMob**: Asegúrate de seguir las políticas de AdMob para evitar que tu cuenta sea suspendida.

## 🔧 Solución de Problemas

### Los anuncios no se muestran

1. Verifica que AdMob esté inicializado correctamente (revisa los logs)
2. Verifica que los App IDs y Ad Unit IDs sean correctos
3. Asegúrate de estar usando anuncios de prueba en modo debug
4. Verifica tu conexión a Internet

### Error al inicializar AdMob

1. Verifica que el App ID sea correcto en `AndroidManifest.xml` y `Info.plist`
2. Asegúrate de que Firebase esté configurado correctamente
3. Verifica que las dependencias estén instaladas (`flutter pub get`)

### Anuncios no cargan

1. Verifica que los Ad Unit IDs sean correctos
2. Asegúrate de tener conexión a Internet
3. Revisa los logs para ver el error específico
4. Verifica que los anuncios estén activos en la consola de AdMob

## 📚 Recursos Adicionales

- [Documentación de Google Mobile Ads para Flutter](https://pub.dev/packages/google_mobile_ads)
- [Guía de AdMob](https://support.google.com/admob/)
- [Políticas de AdMob](https://support.google.com/admob/answer/6128543)

## ✅ Checklist de Configuración

- [ ] Cuenta de AdMob creada
- [ ] Aplicación creada en AdMob (Android)
- [ ] Aplicación creada en AdMob (iOS)
- [ ] App ID configurado en `AndroidManifest.xml`
- [ ] App ID configurado en `Info.plist`
- [ ] Unidades de anuncios creadas en AdMob
- [ ] Ad Unit IDs configurados en `admob_service.dart`
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Anuncios de prueba funcionando
- [ ] Listo para cambiar a modo producción

## 🎉 ¡Listo!

Una vez completados todos los pasos, tu aplicación estará lista para mostrar anuncios de AdMob. Recuerda cambiar a modo producción solo cuando estés listo para publicar la aplicación.

**Nota**: Los IDs de ejemplo en el código son IDs de prueba de Google. Debes reemplazarlos con tus IDs reales antes de publicar la aplicación.

# Configuración de AdMob para Anuncios de Hoteles y Restaurantes

## 📋 Resumen

Se ha configurado AdMob en la aplicación Playas RD para mostrar anuncios relevantes de hoteles y restaurantes utilizando palabras clave y targeting de contenido personalizado.

## ✅ Configuración Completada

### 1. Servicio de AdMob (`lib/services/admob_service.dart`)

Se ha agregado el método `createHotelRestaurantAdRequest()` que crea solicitudes de anuncios con palabras clave específicas para hoteles y restaurantes:

- **Palabras clave en español**: hotel, hoteles, restaurante, restaurantes, turismo, viajes, vacaciones, alojamiento, hospedaje, comida, gastronomía, reservas, booking, playa, playas, república dominicana, caribe, viaje, reservación
- **Palabras clave en inglés**: travel, tourism, accommodation, dining, restaurant, hotel booking, caribbean, dominican republic

### 2. Widgets Actualizados

Todos los widgets y helpers de anuncios ahora usan el targeting de hoteles y restaurantes por defecto:

- **`BannerAdWidget`**: Muestra anuncios banner con targeting de hoteles y restaurantes
- **`InterstitialAdHelper`**: Anuncios intersticiales con targeting personalizado
- **`RewardedAdHelper`**: Anuncios con recompensa con targeting personalizado

### 3. Uso Actual

El `BannerAdWidget` ya está implementado en:
- `lib/screens/home_screen.dart` (línea 98-107)

## 🔧 Configuración en AdMob Dashboard

Para optimizar los anuncios de hoteles y restaurantes, sigue estos pasos en tu cuenta de AdMob:

### 1. Crear Unidades de Anuncios

1. Ve a [AdMob Console](https://admob.google.com)
2. Selecciona tu app "Playas RD"
3. Ve a **Unidades de anuncios** → **Crear unidad de anuncios**
4. Crea unidades para:
   - Banner
   - Intersticial
   - Recompensado (opcional)

### 2. Configurar Targeting de Contenido

En cada unidad de anuncios, puedes configurar:

1. **Categorías de contenido**: Selecciona "Viajes y turismo"
2. **Palabras clave**: Las palabras clave ya están configuradas en el código
3. **Ubicación**: República Dominicana (si aplica)

### 3. Actualizar IDs de Producción

Una vez que tengas los IDs reales de AdMob, actualiza el archivo `lib/services/admob_service.dart`:

```dart
// Reemplazar estos valores con tus IDs reales
static const String _productionBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _productionInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _productionRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

### 4. Actualizar AndroidManifest.xml

El `AndroidManifest.xml` ya tiene configurado el App ID de AdMob. Si necesitas actualizarlo:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

## 📱 Cómo Funciona

### Targeting Automático

Por defecto, todos los anuncios usan el targeting de hoteles y restaurantes. El método `createHotelRestaurantAdRequest()` incluye:

1. **Palabras clave relevantes**: Más de 20 palabras clave relacionadas con turismo, hoteles y restaurantes
2. **Idiomas**: Español e inglés para cubrir ambos mercados
3. **Contexto geográfico**: Referencias a República Dominicana y el Caribe

### Personalización

Si necesitas desactivar el targeting en algún lugar específico:

```dart
// Desactivar targeting personalizado
BannerAdWidget(
  useHotelRestaurantTargeting: false,
)

// O para helpers
InterstitialAdHelper(useHotelRestaurantTargeting: false)
RewardedAdHelper(useHotelRestaurantTargeting: false)
```

### Agregar Palabras Clave Adicionales

Puedes agregar palabras clave específicas cuando creas el AdRequest:

```dart
final adService = AdMobService();
final adRequest = adService.createHotelRestaurantAdRequest(
  additionalKeywords: ['resort', 'spa', 'all-inclusive'],
  contentUrl: 'https://playasrd.com/beach/123',
);
```

## 🎯 Mejores Prácticas

1. **Testing**: Usa los IDs de prueba en modo debug (ya configurado)
2. **Monitoreo**: Revisa el rendimiento de los anuncios en AdMob Dashboard
3. **Optimización**: Ajusta las palabras clave según el rendimiento
4. **Ubicación**: Considera agregar información de ubicación del usuario si tienes permisos

## 📊 Métricas a Monitorear

En AdMob Dashboard, revisa:
- **CTR (Click-Through Rate)**: Tasa de clics en anuncios
- **RPM (Revenue Per Mille)**: Ingresos por cada 1000 impresiones
- **Fill Rate**: Porcentaje de solicitudes que resultan en anuncios mostrados
- **Categorías de anuncios**: Verifica que los anuncios sean relevantes

## 🔍 Verificación

Para verificar que todo funciona:

1. Ejecuta la app en modo debug (usará anuncios de prueba)
2. Verifica en los logs que aparezca: `✅ Anuncio banner cargado (hoteles y restaurantes)`
3. Revisa que los anuncios se muestren correctamente en la pantalla principal

## 📝 Notas Importantes

- Los anuncios de prueba se muestran automáticamente en modo debug
- Los IDs de producción deben configurarse antes de publicar en producción
- El targeting funciona mejor cuando hay suficiente inventario de anuncios relevantes
- Google AdMob selecciona automáticamente los mejores anuncios basándose en las palabras clave

## 🆘 Solución de Problemas

### Los anuncios no se muestran
- Verifica que AdMob esté inicializado correctamente
- Revisa los logs para errores
- Asegúrate de que los IDs de anuncios sean correctos

### Los anuncios no son relevantes
- Ajusta las palabras clave en `createHotelRestaurantAdRequest()`
- Verifica la configuración en AdMob Dashboard
- Considera agregar más palabras clave específicas

### Errores de carga
- Verifica la conexión a internet
- Revisa que el App ID en AndroidManifest.xml sea correcto
- Asegúrate de que la app esté registrada en AdMob


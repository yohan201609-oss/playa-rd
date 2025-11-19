# 🎯 Cómo Funciona el Targeting en AdMob

## ⚠️ Importante: AdMob y las Categorías

**AdMob NO ofrece una opción de "categorías de contenido" en el dashboard** para unidades de anuncios individuales. Esto es normal y esperado.

## ✅ La Solución: Palabras Clave (Keywords)

El targeting en AdMob se realiza principalmente mediante **palabras clave (keywords)** en el código, que es **la forma más efectiva** de segmentar anuncios.

### ¿Por qué las palabras clave funcionan mejor?

1. **Más específico**: Puedes definir exactamente qué términos quieres
2. **Más control**: Tú decides qué palabras usar
3. **Más flexible**: Puedes ajustar fácilmente sin cambiar configuraciones en el dashboard
4. **Funciona inmediatamente**: No hay período de espera

## 🔧 Configuración Actual

Tu aplicación ya está configurada con **más de 40 palabras clave** organizadas en categorías:

### ✅ Hoteles y Alojamiento
- hotel, hoteles, alojamiento, hospedaje, resort, accommodation, booking, reservas

### ✅ Restaurantes y Gastronomía
- restaurante, restaurantes, comida, gastronomía, dining, restaurant, cocina, chef

### ✅ Turismo y Viajes
- turismo, viajes, vacaciones, travel, tourism, vacation, trip

### ✅ Playas y Destinos
- playa, playas, beach, beaches, caribbean, caribe, república dominicana, tropical, paradise

## 📊 Cómo Funciona el Proceso

1. **Tu app solicita un anuncio** con las palabras clave configuradas
2. **Google AdMob analiza** las palabras clave y el contexto de la app
3. **AdMob busca anunciantes** que coincidan con esas palabras clave
4. **Se muestra el anuncio más relevante** de hoteles, restaurantes o turismo

## 🎯 Configuraciones Disponibles en AdMob Dashboard

Aunque no hay categorías de contenido, puedes configurar en el dashboard:

### 1. Tipo de Anuncio
- ✅ Texto, imagen y rich media
- ✅ Video

### 2. Actualización Automática
- ✅ Optimizada por Google (recomendado)

### 3. Límite Mínimo de eCPM
- ✅ Optimizada por Google (recomendado)

## 💡 Mejores Prácticas

### 1. Usa Palabras Clave Específicas
✅ **Bien**: "hotel", "restaurante", "playa", "turismo"
❌ **Evita**: palabras genéricas como "app", "móvil"

### 2. Combina Idiomas
✅ Incluye palabras en español e inglés para mayor cobertura

### 3. Contexto Geográfico
✅ Incluye ubicaciones relevantes: "republica dominicana", "caribbean"

### 4. Monitorea el Rendimiento
- Revisa en AdMob Dashboard → Informes
- Verifica qué tipos de anuncios se están mostrando
- Ajusta las palabras clave si es necesario

## 🔍 Verificar que Funciona

### En AdMob Dashboard:

1. Ve a **Informes** → **Análisis de anuncios**
2. Revisa las métricas:
   - **Categorías de anuncios**: Deberías ver anuncios relacionados con viajes, hoteles, restaurantes
   - **CTR**: Tasa de clics en anuncios
   - **RPM**: Ingresos por cada 1000 impresiones

### En los Logs de la App:

```
✅ AdMob inicializado correctamente
✅ Anuncio banner cargado (hoteles y restaurantes)
```

## 📈 Optimización Continua

### Si los anuncios no son relevantes:

1. **Agrega más palabras clave específicas**:
   ```dart
   final adRequest = AdMobService().createHotelRestaurantAdRequest(
     additionalKeywords: ['all-inclusive', 'spa', 'resort'],
   );
   ```

2. **Usa contexto de la playa**:
   ```dart
   final adRequest = AdMobService().createHotelRestaurantAdRequest(
     beachName: 'Bávaro',
     province: 'La Altagracia',
   );
   ```

3. **Monitorea y ajusta**: Revisa qué anuncios se muestran y ajusta las palabras clave

## ✅ Conclusión

**No necesitas configurar categorías en el dashboard** porque:

1. ✅ Las palabras clave en el código son más efectivas
2. ✅ Ya tienes más de 40 palabras clave configuradas
3. ✅ El targeting funciona automáticamente
4. ✅ Google usa estas palabras clave para mostrar anuncios relevantes

**Tu configuración actual es la forma correcta y más efectiva de hacer targeting en AdMob** 🎯

## 🆘 Preguntas Frecuentes

### ¿Por qué no veo la opción de categorías?
- Es normal. AdMob no ofrece esta opción para unidades individuales
- Las palabras clave son la forma estándar de hacer targeting

### ¿Funcionará el targeting sin categorías en el dashboard?
- ✅ Sí, las palabras clave son suficientes y más efectivas
- Google usa las palabras clave para determinar qué anuncios mostrar

### ¿Cómo sé si está funcionando?
- Revisa los informes en AdMob Dashboard
- Verifica que los anuncios mostrados sean relevantes
- Monitorea el CTR y RPM

### ¿Puedo mejorar el targeting?
- ✅ Sí, agrega más palabras clave específicas
- ✅ Usa el contexto de la playa (beachName, province)
- ✅ Monitorea y ajusta según los resultados


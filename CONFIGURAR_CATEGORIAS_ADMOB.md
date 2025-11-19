# 📋 Cómo Configurar Categorías de Contenido en AdMob

Las categorías de contenido ayudan a mostrar anuncios más relevantes de hoteles y restaurantes. Se pueden configurar de **dos formas**:

## 🎯 Opción 1: En el Dashboard de AdMob (Recomendado)

Esta es la forma más efectiva de configurar las categorías, ya que se aplica a nivel de unidad de anuncios.

### Pasos:

1. **Accede a AdMob Dashboard**
   - Ve a [https://admob.google.com](https://admob.google.com)
   - Inicia sesión con tu cuenta

2. **Navega a tu Unidad de Anuncios**
   - Ve a **Aplicaciones** → **Playas RD** → **Unidades de anuncios**
   - Haz clic en tu unidad de anuncios (ej: "Banner - Hoteles y Restaurantes")

3. **Edita la Configuración**
   - Haz clic en el ícono de **editar** (lápiz) o en **"Editar"**
   - Busca la sección **"Configuración avanzada"** o **"Advanced settings"**

4. **Configura las Categorías**
   - Busca **"Categorías de contenido"** o **"Content categories"**
   - Selecciona las siguientes categorías:
     - ✅ **Viajes y turismo** / **Travel & Tourism**
     - ✅ **Hoteles y alojamiento** / **Hotels & Accommodation**
     - ✅ **Restaurantes y comida** / **Restaurants & Food**
     - ✅ **Destinos turísticos** / **Tourist Destinations**

5. **Configuración Adicional (Opcional)**
   - **Ubicación geográfica**: República Dominicana
   - **Idioma**: Español, Inglés
   - **Edad del contenido**: General / Para todos

6. **Guarda los Cambios**
   - Haz clic en **"Guardar"** o **"Save"**

### ⚠️ Nota Importante
- Los cambios pueden tardar hasta 1 hora en aplicarse
- Las categorías configuradas aquí tienen prioridad sobre las palabras clave del código

---

## 💻 Opción 2: En el Código (Ya Configurado)

Ya está configurado en `lib/services/admob_service.dart` mediante:

### 1. Palabras Clave (Keywords)

El método `createHotelRestaurantAdRequest()` incluye más de 30 palabras clave relacionadas con:
- Hoteles y alojamiento
- Restaurantes y gastronomía
- Turismo y viajes
- Playas y destinos

### 2. Content URL

Se puede pasar un `contentUrl` para dar contexto adicional:

```dart
final adRequest = AdMobService().createHotelRestaurantAdRequest(
  beachName: 'Bávaro',
  province: 'La Altagracia',
  contentUrl: 'https://playasrd.com/beach/bavaro',
);
```

### 3. Uso en el Código

El código ya está configurado para usar estas palabras clave automáticamente:

```dart
// En home_screen.dart - Ya configurado
BannerAdWidget(
  useHotelRestaurantTargeting: true, // Por defecto es true
)
```

---

## 🔍 Verificar la Configuración

### En el Dashboard de AdMob:

1. Ve a **Informes** → **Análisis de anuncios**
2. Revisa las métricas:
   - **Categorías de anuncios mostrados**: Deberías ver anuncios de hoteles y restaurantes
   - **CTR (Click-Through Rate)**: Debería mejorar con mejor targeting
   - **RPM (Revenue Per Mille)**: Ingresos por cada 1000 impresiones

### En los Logs de la App:

Cuando ejecutes la app, deberías ver:
```
✅ AdMob inicializado correctamente
✅ Anuncio banner cargado (hoteles y restaurantes)
```

---

## 📊 Categorías Recomendadas para AdMob

### Categorías Principales:
1. **Viajes y turismo** / Travel & Tourism
2. **Hoteles y alojamiento** / Hotels & Accommodation  
3. **Restaurantes y comida** / Restaurants & Food
4. **Destinos turísticos** / Tourist Destinations
5. **Actividades al aire libre** / Outdoor Activities

### Categorías Secundarias (Opcionales):
- **Reservas y reservaciones** / Bookings & Reservations
- **Gastronomía** / Gastronomy
- **Vacaciones** / Vacations
- **Aventura** / Adventure

---

## 🎯 Mejores Prácticas

1. **Configura en el Dashboard**: Es más efectivo que solo usar palabras clave
2. **Combina ambas opciones**: Usa categorías en el dashboard + palabras clave en el código
3. **Monitorea el rendimiento**: Revisa qué categorías generan mejores resultados
4. **Ajusta según resultados**: Si ves anuncios no relevantes, ajusta las categorías

---

## 🆘 Solución de Problemas

### Los anuncios no son relevantes
- ✅ Verifica que las categorías estén configuradas en el dashboard
- ✅ Revisa que las palabras clave estén correctas en el código
- ✅ Espera hasta 1 hora para que los cambios se apliquen

### No veo la opción de categorías
- ✅ Asegúrate de estar en la sección "Configuración avanzada"
- ✅ Algunas unidades nuevas pueden tardar en mostrar todas las opciones
- ✅ Intenta editar la unidad de anuncios directamente

### Los anuncios no se muestran
- ✅ Verifica que la unidad de anuncios esté activa
- ✅ Revisa que el App ID y Ad Unit ID sean correctos
- ✅ Espera el período de activación (hasta 1 hora)

---

## 📝 Resumen

**Para configurar categorías de contenido:**

1. **Dashboard de AdMob** (Más efectivo):
   - Unidad de anuncios → Editar → Configuración avanzada
   - Selecciona: Viajes y turismo, Hoteles, Restaurantes

2. **Código** (Ya configurado):
   - Palabras clave automáticas en `createHotelRestaurantAdRequest()`
   - Se aplica automáticamente a todos los anuncios

**Ambas opciones trabajan juntas para un mejor targeting** 🎯


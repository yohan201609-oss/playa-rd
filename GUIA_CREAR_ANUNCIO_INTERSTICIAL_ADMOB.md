# 📺 Guía: Crear Unidad de Anuncio Intersticial en AdMob

Esta guía te ayudará a crear una unidad de anuncio intersticial (video) en tu cuenta de AdMob para la aplicación Playas RD.

## 📋 Requisitos Previos

- ✅ Tener una cuenta de AdMob activa
- ✅ Tener la aplicación "Playas RD" registrada en AdMob
- ✅ Acceso a [AdMob Console](https://admob.google.com/)

## 🎯 Paso 1: Acceder a AdMob Console

1. Ve a [https://admob.google.com](https://admob.google.com)
2. Inicia sesión con tu cuenta de Google
3. Asegúrate de estar en el proyecto correcto

## 📱 Paso 2: Seleccionar tu Aplicación

1. En el menú lateral izquierdo, haz clic en **"Aplicaciones"**
2. Busca y selecciona tu aplicación **"Playas RD"**
   - **Package Name:** `com.playasrd.playasrd`
   - **Plataforma:** Android (o iOS si también la tienes)

## ➕ Paso 3: Crear Nueva Unidad de Anuncio

1. Una vez dentro de la aplicación, verás una sección llamada **"Unidades de anuncios"**
2. Haz clic en el botón **"Añadir unidad de anuncios"** o **"Add ad unit"**
3. Se abrirá un diálogo para crear una nueva unidad

## 🎬 Paso 4: Configurar el Anuncio Intersticial

### 4.1 Tipo de Anuncio
- Selecciona **"Intersticial"** (Interstitial)
- Este tipo muestra anuncios de pantalla completa (incluye videos)

### 4.2 Nombre de la Unidad
- **Nombre sugerido:** `Intersticial - Playas RD` o `Interstitial - Playas RD`
- Este nombre es solo para tu referencia interna

### 4.3 Formato del Anuncio
- Selecciona **"Intersticial"** (ya seleccionado automáticamente)
- Este formato muestra anuncios de pantalla completa que pueden incluir videos

### 4.4 Configuración Adicional (Opcional)
- **Categoría de contenido:** Puedes dejarlo en "Sin especificar" o seleccionar "Turismo" si está disponible
- **Palabras clave:** No es necesario configurarlas aquí, ya las manejamos en el código

## ✅ Paso 5: Crear la Unidad

1. Haz clic en el botón **"Crear unidad de anuncios"** o **"Create ad unit"**
2. AdMob generará automáticamente un **Ad Unit ID**

## 📝 Paso 6: Copiar el Ad Unit ID

Después de crear la unidad, verás algo como esto:

```
ca-app-pub-2612958934827252/1234567890
```

**IMPORTANTE:** Copia este ID completo. Lo necesitarás para actualizar el código.

### Formato del ID:
- **Formato:** `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`
- **Ejemplo:** `ca-app-pub-2612958934827252/1234567890`

## 🔧 Paso 7: Actualizar el Código

Una vez que tengas el Ad Unit ID, actualiza el archivo `lib/services/admob_service.dart`:

### Ubicación del archivo:
```
lib/services/admob_service.dart
```

### Línea a actualizar (aproximadamente línea 25):

**ANTES:**
```dart
static const String _productionInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

**DESPUÉS (reemplaza con tu ID real):**
```dart
static const String _productionInterstitialAdUnitId = 'ca-app-pub-2612958934827252/TU_ID_AQUI';
```

### Ejemplo completo:
```dart
// IDs de producción
static const String _productionBannerAdUnitId = 'ca-app-pub-2612958934827252/5832453782';
static const String _productionInterstitialAdUnitId = 'ca-app-pub-2612958934827252/1234567890'; // ← Tu nuevo ID
static const String _productionRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

## 🧪 Paso 8: Probar el Anuncio

### Modo de Prueba (Recomendado para Desarrollo)

El código ya está configurado para usar anuncios de prueba cuando `_isTestMode = true`.

**Para probar con anuncios de prueba:**
- No necesitas cambiar nada, el código ya usa IDs de prueba por defecto en desarrollo
- Los anuncios de prueba tienen el ID: `ca-app-pub-3940256099942544/1033173712`

### Modo de Producción

**Para activar anuncios reales:**
1. Asegúrate de que `_isTestMode = false` en `lib/services/admob_service.dart` (línea 14)
2. Actualiza el `_productionInterstitialAdUnitId` con tu ID real
3. Compila y ejecuta la aplicación

## 📊 Paso 9: Verificar que Funciona

1. **Ejecuta la aplicación:**
   ```bash
   flutter run
   ```

2. **Navega a la pantalla de Perfil**

3. **Presiona cualquier botón del menú:**
   - Mis Favoritos
   - Visitadas
   - Mis Reportes
   - Configuración
   - Ayuda

4. **Deberías ver:**
   - Un anuncio intersticial de pantalla completa (puede ser video o imagen)
   - Después de cerrar el anuncio, navegará a la pantalla correspondiente

## ⚠️ Notas Importantes

### Tiempo de Activación
- Los anuncios pueden tardar **varias horas** en empezar a mostrarse después de crear la unidad
- Durante las primeras horas, es normal que no se muestren anuncios (AdMob está configurando la unidad)

### Políticas de AdMob
- Asegúrate de seguir las [Políticas de AdMob](https://support.google.com/admob/answer/6128543)
- No hagas clic en tus propios anuncios (puede resultar en suspensión de cuenta)

### Monetización
- Los anuncios intersticiales generalmente generan más ingresos que los banners
- Los anuncios de video suelen tener mejor rendimiento económico

## 🔍 Solución de Problemas

### El anuncio no se muestra

1. **Verifica el ID:**
   - Asegúrate de que el ID esté correctamente copiado
   - No debe tener espacios ni caracteres extra

2. **Verifica el modo:**
   - En desarrollo, usa `_isTestMode = true` para ver anuncios de prueba
   - En producción, usa `_isTestMode = false` con tu ID real

3. **Revisa los logs:**
   - Busca mensajes como "✅ Anuncio intersticial cargado" en la consola
   - Si ves errores, revisa el código de error

4. **Tiempo de espera:**
   - Los anuncios pueden tardar horas en activarse después de crear la unidad
   - Es normal que no aparezcan inmediatamente

### Error al cargar el anuncio

**Códigos de error comunes:**
- **Error 0:** Error interno de AdMob (reintentar más tarde)
- **Error 1:** Solicitud inválida (verifica el Ad Unit ID)
- **Error 2:** Error de red (verifica tu conexión)
- **Error 3:** No hay anuncios disponibles (normal en las primeras horas)

## 📱 Crear Unidad para iOS (Opcional)

Si también tienes la app en iOS, repite los mismos pasos pero:
1. Selecciona la aplicación iOS en AdMob
2. Crea otra unidad intersticial para iOS
3. Puedes usar el mismo ID o crear uno separado

## ✅ Checklist Final

- [ ] Unidad de anuncio intersticial creada en AdMob
- [ ] Ad Unit ID copiado
- [ ] ID actualizado en `lib/services/admob_service.dart`
- [ ] Aplicación probada con anuncios de prueba
- [ ] Verificado que los anuncios se muestran correctamente
- [ ] Listo para producción (cambiar a modo producción cuando estés listo)

## 🎉 ¡Listo!

Una vez completados estos pasos, tus anuncios intersticiales estarán funcionando en la aplicación Playas RD. Los anuncios se mostrarán automáticamente cuando los usuarios presionen los botones del menú en la pantalla de perfil.

---

**¿Necesitas ayuda?** Revisa la documentación oficial de AdMob:
- [Documentación de AdMob](https://support.google.com/admob/)
- [Guía de Anuncios Intersticiales](https://support.google.com/admob/answer/6066980)


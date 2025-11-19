# Guía: Vincular Firebase con AdMob

## ¿Por qué vincular Firebase con AdMob?

Vincular Firebase con AdMob te permite:
- ✅ Mejorar el targeting de anuncios (más relevantes para tu audiencia)
- ✅ Ver datos de campañas de aplicaciones en los informes de AdMob
- ✅ Acceder a funciones avanzadas después de implementar el SDK
- ✅ Reducir anuncios genéricos (como Temu) y obtener anuncios más relevantes

## Información de tu proyecto

**Proyecto Firebase:**
- Project ID: `playas-rd-2b475`
- Project Number: `360714035813`

**App Android:**
- Package Name: `com.playasrd.playasrd`
- App ID: `1:360714035813:android:b257f7be5740162e629c8c`

## Pasos para vincular Firebase con AdMob

### Paso 1: Ir a Firebase Console

1. Abre [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto: **playas-rd-2b475**
3. Ve a **Configuración del proyecto** (ícono de engranaje) → **Configuración del proyecto**

### Paso 2: Vincular AdMob en Firebase

1. En la sección **Integraciones**, busca **Google AdMob**
2. Haz clic en **Vincular** o **Conectar**
3. Selecciona tu cuenta de AdMob
4. Confirma la vinculación

### Paso 3: Vincular la App en AdMob

1. Abre [AdMob Console](https://admob.google.com/)
2. Ve a **Configuración** → **Servicios vinculados**
3. En la sección **Administración de las vinculaciones de la aplicación**, busca **Playas RD Android**
4. Haz clic en el botón **Vincular** o en el ícono de Firebase
5. Selecciona tu proyecto Firebase: **playas-rd-2b475**
6. Confirma la vinculación

### Paso 4: Verificar la vinculación

1. En AdMob, ve a **Configuración** → **Servicios vinculados**
2. Deberías ver:
   - ✅ **Firebase**: Vinculado
   - ✅ **Playas RD Android**: "La aplicación está vinculada a Firebase"

## Solución de problemas

### Si no ves la opción de vincular en Firebase:

1. Asegúrate de que estás usando la misma cuenta de Google en Firebase y AdMob
2. Verifica que tienes permisos de administrador en ambos proyectos
3. Espera unos minutos y recarga la página

### Si la app no aparece en AdMob:

1. Verifica que la app esté registrada en AdMob:
   - Ve a **Aplicaciones** en AdMob
   - Busca "Playas RD Android"
   - Si no existe, créala con el package name: `com.playasrd.playasrd`

### Si aparece "La aplicación no está vinculada a Firebase":

1. Asegúrate de que el `google-services.json` esté actualizado en tu proyecto
2. Verifica que el App ID coincida:
   - Firebase: `1:360714035813:android:b257f7be5740162e629c8c`
   - AdMob: Debe coincidir con el App ID de Firebase

## Después de vincular

Una vez vinculado, AdMob podrá:
- Usar datos de Firebase Analytics para mejorar el targeting
- Mostrar anuncios más relevantes basados en el comportamiento del usuario
- Reducir anuncios genéricos como Temu

**Nota:** Los cambios pueden tardar hasta 24 horas en reflejarse completamente.

## Sobre Google Ads (opcional)

El mensaje sobre Google Ads es opcional. Solo necesitas vincular Google Ads si quieres:
- Crear campañas publicitarias propias
- Configurar campañas de venta directa

Para mejorar el targeting de anuncios, **solo necesitas vincular Firebase**, no Google Ads.





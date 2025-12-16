# Guía para Completar las Declaraciones de Google Play Console

Esta guía te ayudará a completar las 2 declaraciones requeridas en Google Play Console para tu app **Playas RD**.

---

## 1. ID de publicidad (Advertising ID) ✅ REQUERIDO

### ¿Usa tu app un ID de publicidad?
**SÍ** - Tu app usa Google Mobile Ads (AdMob) para mostrar anuncios.

### Información para completar la declaración:

#### **Uso del Advertising ID:**
- ✅ **SÍ**, tu app usa el Advertising ID (ID de publicidad)

#### **Propósito del uso:**
En el formulario que estás viendo, marca **SOLO** las siguientes opciones:

1. ✅ **Publicidad o marketing** (OBLIGATORIO):
   - "Se usan para mostrar u orientar anuncios y medir su rendimiento o enviar comunicaciones de marketing"
   - Tu app muestra anuncios de Google AdMob (banner e intersticiales)
   - Se usa para segmentación de anuncios relevantes para usuarios

2. ✅ **Estadísticas** (Analytics):
   - "Sirve para recopilar datos sobre cómo los usuarios utilizan la app y cuál es el rendimiento"
   - Se usa para medir la efectividad de los anuncios
   - Estadísticas de interacción con anuncios (impresiones, clics, etc.)

3. ✅ **Seguridad, cumplimiento y prevención de fraudes**:
   - "Se usan para la prevención de fraudes, la seguridad o el cumplimiento de las leyes"
   - AdMob incluye protección contra fraude en publicidad
   - Prevención de clics fraudulentos en anuncios

#### **NO marques estas opciones:**
- ❌ **Funciones de la app**: AdMob no se usa para funciones de la app (eso es Firebase Auth)
- ❌ **Comunicaciones del desarrollador**: Las notificaciones push usan Firebase Messaging, no AdMob
- ❌ **Personalización**: Aunque AdMob puede personalizar anuncios, no es el propósito principal
- ❌ **Administración de la cuenta**: Eso es para Firebase Auth, no para AdMob

#### **Resumen - Opciones a marcar:**
1. ✅ Publicidad o marketing
2. ✅ Estadísticas
3. ✅ Seguridad, cumplimiento y prevención de fraudes

**Total: 3 opciones marcadas**

### Pasos a seguir:
1. Haz clic en **"Comenzar declaración"** del ID de publicidad
2. Selecciona **"Sí, mi app usa un ID de publicidad"**
3. Completa el formulario con las opciones marcadas arriba
4. Guarda y envía la declaración

---

## 2. Apps de salud (Health apps) ✅ REQUERIDO

### ¿Es tu app una aplicación de salud?
**NO** - Tu app es una aplicación de turismo/playas, NO una app de salud.

### Información para completar la declaración:

En el formulario que estás viendo, verás varias categorías con checkboxes:

#### **Salud y fitness:**
- ❌ **Actividad y ejercicio** - NO aplica
- ❌ **Nutrición y control de peso** - NO aplica
- ❌ **Seguimiento del período** - NO aplica
- ❌ **Gestión del sueño** - NO aplica
- ❌ **Control del estrés, relajación y agudeza mental** - NO aplica

#### **Medicina:**
- ❌ **Control de enfermedades y afecciones** - NO aplica
- ❌ Cualquier otra opción médica - NO aplica

### ⚠️ IMPORTANTE - Qué hacer en el formulario:

**NO marques ninguna opción** (deja todos los checkboxes vacíos) porque:
- Tu app es de turismo/playas, no de salud
- No tiene funcionalidades relacionadas con salud o medicina
- La información climática es recreativa/turística, no médica

### Funcionalidades que SÍ tiene tu app (pero NO son de salud):
- ✅ Información turística sobre playas
- ✅ Condiciones climáticas (información general para turistas, no médica)
- ✅ Geolocalización para encontrar playas
- ✅ Reportes de condiciones de playas (recreativas, no médicas)
- ✅ Fotos y descripciones de playas
- ✅ Sistema de favoritos y playas visitadas

### Pasos a seguir:
1. En el formulario **NO marques ninguna casilla**
2. Deja todos los checkboxes vacíos (sin seleccionar nada)
3. Si hay un botón "Continuar" o "Siguiente", haz clic en él
4. Si te pregunta "¿Tu app usa funciones de salud?", responde **"No"**
5. Guarda y envía la declaración

### Nota:
Al no marcar ninguna opción, estás declarando implícitamente que tu app NO usa funciones de salud, lo cual es correcto para una app de turismo.

---

## Resumen rápido

| Declaración | Respuesta | Acción |
|------------|-----------|--------|
| **ID de publicidad** | ✅ **SÍ** - Usa AdMob | Declarar todos los propósitos marcados arriba |
| **Apps de salud** | ❌ **NO** - Es app de turismo | Declarar que NO es app de salud |

---

## Notas importantes

1. **ID de publicidad**: Esta declaración es obligatoria porque tu app usa Google Mobile Ads. Sin completarla, no podrás lanzar versiones dirigidas a Android 13+.

2. **Apps de salud**: Aunque tu app muestra información sobre condiciones climáticas y condiciones de playas, esto es información recreativa/turística, NO médica. Por lo tanto, no califica como app de salud.

3. **Tiempo de respuesta**: Google recomienda completar estas declaraciones antes de sus respectivos plazos límite para evitar problemas con futuras actualizaciones.

4. **Actualización de declaraciones**: Si en el futuro agregas funcionalidades que cambien estas respuestas, deberás actualizar las declaraciones.

---

## Configuración actual de tu app

### SDKs utilizados:
- ✅ Google Mobile Ads (AdMob) - `google_mobile_ads: ^5.1.0`
- ✅ Firebase Analytics
- ✅ Firebase Auth
- ✅ Firebase Storage

### Funcionalidades principales:
- Información de playas
- Mapa con ubicación de playas
- Condiciones climáticas (API de clima)
- Reportes de condiciones de playas (recreativas)
- Fotos de playas
- Sistema de favoritos y playas visitadas
- Autenticación de usuarios

---

---

## 3. Detalles de contacto de la ficha de Play Store ⚠️ RECOMENDADO

### ¿Qué es esta sección?
Los detalles de contacto son información que los usuarios verán en la ficha de tu app en Google Play Store. Ayudan a dar transparencia y credibilidad a tu app.

### Campos disponibles:

#### 1. **Dirección de correo electrónico** 📧
- **¿Es obligatorio?** No, pero **altamente recomendado**
- **Qué poner:** Un email profesional para contacto con usuarios
- **Recomendaciones:**
  - Usa un email dedicado (ej: soporte@playasrd.com o contacto@playasrd.com)
  - Verifica que tengas acceso a este email y lo revises regularmente
  - Los usuarios pueden usarlo para reportar problemas o hacer preguntas

#### 2. **Número de teléfono** 📞
- **¿Es obligatorio?** No, es **opcional**
- **Qué poner:** Un número de teléfono de contacto (puede ser tu número personal o de negocio)
- **Recomendaciones:**
  - Solo inclúyelo si estás cómodo recibiendo llamadas de usuarios
  - Si no tienes un número dedicado para la app, puedes dejarlo vacío
  - Considera usar un número de WhatsApp Business si lo prefieres

#### 3. **Sitio web** 🌐
- **¿Es obligatorio?** No, pero **recomendado** si tienes uno
- **Qué poner:** URL de tu sitio web o página de la app
- **Recomendaciones:**
  - Si tienes un sitio web para la app, inclúyelo aquí
  - Puede ser una página simple en WordPress, Wix, o cualquier plataforma
  - Si no tienes sitio web, puedes dejarlo vacío o crear uno simple más adelante

### Pasos a seguir:
1. Haz clic en **"editar"** (enlace azul a la derecha del título)
2. Completa los campos que desees:
   - ✅ **Email:** Altamente recomendado (al menos este)
   - ⚠️ **Teléfono:** Opcional (solo si lo deseas)
   - ⚠️ **Sitio web:** Opcional (solo si tienes uno)
3. Guarda los cambios

### Importancia:
- ✅ Aumenta la confianza de los usuarios
- ✅ Permite que los usuarios te contacten con problemas o sugerencias
- ✅ Es señal de profesionalismo y responsabilidad
- ✅ Google Play recomienda tener al menos un email de contacto

### Ejemplo de configuración:
```
Email: contacto@playasrd.com (o tu email profesional)
Teléfono: [Opcional - dejar vacío si prefieres]
Sitio web: https://playasrd.com (si tienes uno)
```

---

## ¿Necesitas ayuda adicional?

Si tienes dudas sobre alguna parte de las declaraciones, puedes:
1. Revisar la documentación oficial de Google Play
2. Consultar las políticas de Google Play
3. Contactar con el soporte de Google Play Console

**Nota**: Esta guía se basa en el código actual de tu app. Si realizas cambios significativos, actualiza las declaraciones correspondientes.


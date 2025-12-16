# Guía: Completar App Privacy en App Store Connect

Esta guía te ayuda a completar todas las declaraciones de privacidad de datos para tu app **Playas RD** en App Store Connect.

---

## 📋 Categorías a Completar

1. ✅ **Name** (Nombre) - Ya completado
2. 🔄 **Email Address** (Dirección de correo electrónico)
3. 🔄 **Payment Info** (Información de pago)
4. 🔄 **User ID** (ID de usuario)

---

## 1. 📧 Email Address (Dirección de Correo Electrónico)

### ¿Recopila tu app direcciones de correo electrónico?

**SÍ** - Tu app recopila emails para autenticación y funcionalidad.

### Información para completar:

#### **Uso del Email:**

**Para "Do you or your third-party partners use email addresses for tracking purposes?"**
- **Respuesta: "No, we do not use email addresses for tracking purposes"**

#### **Propósitos del uso (marcar las que apliquen):**

1. ✅ **App Functionality** (Funcionalidad de la app):
   - Usado para registro de cuenta con email/contraseña
   - Usado para iniciar sesión
   - Usado para restablecer contraseña
   - Almacenado en Firestore para identificación del usuario

2. ✅ **Account Management** (Administración de cuenta):
   - Usado para autenticación de usuarios
   - Vinculado a la cuenta del usuario
   - Usado para recuperación de cuenta

3. ✅ **Developer Communications** (Comunicaciones del desarrollador):
   - Se puede usar para enviar notificaciones sobre cambios en la app
   - Contacto con soporte técnico
   - Respuesta a solicitudes de soporte

#### **Linked to User Identity (Vinculado a la identidad del usuario):**
- **SÍ, marcado** - El email está vinculado a la identidad del usuario (es parte del perfil de usuario)

#### **NO marcar:**
- ❌ **Third-Party Advertising** - No se usa para publicidad de terceros
- ❌ **Analytics** - No se usa específicamente para analytics (Firebase Analytics usa otros identificadores)
- ❌ **Product Personalization** - No se usa para personalizar productos
- ❌ **Other Purposes** - No se usa para otros fines

#### **Resumen - Opciones a marcar:**
1. ✅ App Functionality
2. ✅ Account Management
3. ✅ Developer Communications
4. ✅ Linked to User Identity: **SÍ**

---

## 2. 💳 Payment Info (Información de Pago) / Financial Info

### ¿Recopila tu app información de pago?

**NO** - Tu app NO recopila información de pago, tarjetas de crédito, o datos financieros.

### Información para completar:

#### **¿Recopila información de pago?**
- **Respuesta: "NO" o simplemente no configures esta sección si no recopilas esta información**

**Nota:** Si Apple te pide que configures esta categoría aunque no recopiles información de pago:
- Selecciona que **NO recopilas información de pago**
- O puedes omitir esta sección si no aplica a tu app

---

## 3. 🆔 User ID (ID de Usuario) / Identifiers

### ¿Recopila tu app User IDs?

**SÍ** - Tu app usa User IDs (Firebase Auth UID) para identificar usuarios.

### Información para completar:

#### **Uso del User ID:**

**Para "Do you or your third-party partners use user IDs for tracking purposes?"**
- **Respuesta: "No, we do not use user IDs for tracking purposes"**

#### **Propósitos del uso (marcar las que apliquen):**

1. ✅ **App Functionality** (Funcionalidad de la app):
   - Usado para identificar usuarios únicamente en la app
   - Vinculado a reportes de playas (userId en colección 'reports')
   - Vinculado a playas favoritas del usuario
   - Vinculado a playas visitadas
   - Usado para almacenar datos del usuario en Firestore

2. ✅ **Account Management** (Administración de cuenta):
   - Usado para autenticación y sesión de usuario
   - Identificador único de cuenta (Firebase Auth UID)

3. ✅ **Analytics** (Analytics):
   - Firebase Analytics puede usar User IDs para análisis de uso
   - Estadísticas de uso de la app
   - Mejora de la funcionalidad

#### **Linked to User Identity (Vinculado a la identidad del usuario):**
- **SÍ, marcado** - El User ID está directamente vinculado a la identidad del usuario

#### **NO marcar:**
- ❌ **Third-Party Advertising** - No se usa para publicidad de terceros
- ❌ **Product Personalization** - No se usa para personalizar productos de terceros
- ❌ **Developer Communications** - Las comunicaciones usan email, no User ID
- ❌ **Other Purposes** - No se usa para otros fines

#### **Resumen - Opciones a marcar:**
1. ✅ App Functionality
2. ✅ Account Management
3. ✅ Analytics
4. ✅ Linked to User Identity: **SÍ**

---

## 📝 Resumen por Categoría

### ✅ Name (Nombre)
- **Tracking:** No
- **Uso:** App Functionality, Third-Party Advertising (para AdMob)
- **Linked to Identity:** Sí

### 📧 Email Address
- **Tracking:** No
- **Uso:** App Functionality, Account Management, Developer Communications
- **Linked to Identity:** Sí

### 💳 Payment Info
- **Tracking:** N/A
- **Uso:** No recopilado
- **Linked to Identity:** N/A

### 🆔 User ID
- **Tracking:** No
- **Uso:** App Functionality, Account Management, Analytics
- **Linked to Identity:** Sí

---

## 🎯 Pasos para Completar en App Store Connect

### Para Email Address:

1. Haz clic en **"Set Up Email Address"**
2. Pregunta sobre tracking: **"No, we do not use email addresses for tracking purposes"**
3. Marca las siguientes opciones:
   - ✅ App Functionality
   - ✅ Account Management
   - ✅ Developer Communications
4. Marca **"Linked to User Identity"**: **Sí**
5. Haz clic en **"Save"**

### Para Payment Info:

1. Haz clic en **"Set Up Payment Info"** (si aparece)
2. Si te pregunta si recopilas información de pago: **"No"**
3. O simplemente omite esta sección si no aplica

### Para User ID:

1. Haz clic en **"Set Up User ID"**
2. Pregunta sobre tracking: **"No, we do not use user IDs for tracking purposes"**
3. Marca las siguientes opciones:
   - ✅ App Functionality
   - ✅ Account Management
   - ✅ Analytics
4. Marca **"Linked to User Identity"**: **Sí**
5. Haz clic en **"Save"**

---

## ⚠️ Notas Importantes

1. **Tracking vs Funcionalidad:**
   - "Tracking" se refiere específicamente a usar datos para publicidad dirigida o compartir con data brokers
   - Usar datos para funcionalidad de la app NO es tracking

2. **Linked to User Identity:**
   - Marca "Sí" si los datos están asociados a un usuario identificable
   - En tu caso, email y User ID están vinculados a la identidad del usuario

3. **Third-Party Advertising:**
   - Solo marca esto si compartes los datos específicos con redes publicitarias
   - AdMob usa Advertising ID, no email ni User ID directamente

4. **Consistencia:**
   - Asegúrate de que tus declaraciones sean consistentes con tu política de privacidad
   - Tu política de privacidad está en: `docs/politica_privacidad.md`

---

## ✅ Checklist Final

Antes de enviar, verifica:

- [ ] Name: Configurado correctamente (ya completado)
- [ ] Email Address: Tracking = No, usos marcados correctamente
- [ ] Payment Info: No recopilado (o no configurado)
- [ ] User ID: Tracking = No, usos marcados correctamente
- [ ] Todas las categorías tienen "Linked to User Identity" marcado correctamente
- [ ] Las declaraciones son consistentes con tu política de privacidad

---

## 🔍 Referencias

- Tu política de privacidad: `docs/politica_privacidad.md`
- Código de autenticación: `lib/services/firebase_service.dart`
- Uso de User ID: `lib/providers/auth_provider.dart`

---

**💡 Consejo:** Si tienes dudas sobre alguna categoría, es mejor ser conservador y declarar más usos de los que quizás uses, en lugar de omitir algo que podría considerarse no declarado.


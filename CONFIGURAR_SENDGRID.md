# 📧 Configuración de SendGrid para Envío de Emails

## ¿Por qué SendGrid?

- ✅ **Funciona inmediatamente** - No depende de políticas de Microsoft
- ✅ **Gratis hasta 100 emails/día** - Suficiente para soporte
- ✅ **Mejor deliverability** - Los emails llegan a la bandeja de entrada
- ✅ **Fácil de configurar** - Solo necesitas una API Key
- ✅ **Confiable** - Servicio profesional de email

## Pasos para Configurar SendGrid

### 1. Crear Cuenta en SendGrid

1. Ve a [https://sendgrid.com/](https://sendgrid.com/)
2. Haz clic en "Start for free"
3. Completa el registro (puedes usar `soporteplayasrd@outlook.com` como email)
4. Verifica tu email

### 2. Generar API Key

1. Una vez dentro de SendGrid, ve a **Settings** → **API Keys**
2. Haz clic en **Create API Key**
3. Nombre: "Playas RD Cloud Function"
4. Permisos: Selecciona **Full Access** (o al menos "Mail Send")
5. Haz clic en **Create & View**
6. **¡IMPORTANTE!** Copia la API Key inmediatamente (solo se muestra una vez)

### 3. Configurar en Firebase

Ejecuta estos comandos (reemplaza `TU_API_KEY_AQUI` con la API Key que copiaste):

```bash
firebase functions:config:set \
  support.email_user="apikey" \
  support.email_pass="TU_API_KEY_AQUI" \
  support.smtp_host="smtp.sendgrid.net" \
  support.smtp_port="465" \
  support.smtp_secure="true"
```

### 4. Verificar Sender Identity (Opcional pero Recomendado)

SendGrid requiere verificar un remitente:

1. Ve a **Settings** → **Sender Authentication**
2. Haz clic en **Verify a Single Sender**
3. Completa el formulario:
   - **From Email Address**: `soporteplayasrd@outlook.com`
   - **From Name**: `Playas RD Soporte`
   - Completa los demás campos
4. Verifica el email que recibas

### 5. Redesplegar la Función

```bash
firebase deploy --only functions:processSupportRequest
```

### 6. Probar

1. Envía una sugerencia desde la app
2. Verifica que llegue el email a `soporteplayasrd@outlook.com`
3. Revisa Firestore: el documento debe tener `status: "sent"`

## Alternativa: Usar Gmail SMTP

Si prefieres usar Gmail en lugar de SendGrid:

### 1. Habilitar Contraseñas de Aplicación en Google

1. Ve a [Google Account Security](https://myaccount.google.com/security)
2. Activa **Verificación en dos pasos** si no está activa
3. Ve a **Contraseñas de aplicaciones**
4. Genera una nueva contraseña para "Correo"
5. Copia la contraseña de 16 caracteres

### 2. Configurar en Firebase

```bash
firebase functions:config:set \
  support.email_user="tu_email@gmail.com" \
  support.email_pass="TU_CONTRASEÑA_DE_APLICACION" \
  support.smtp_host="smtp.gmail.com" \
  support.smtp_port="587" \
  support.smtp_secure="false"
```

### 3. Redesplegar

```bash
firebase deploy --only functions:processSupportRequest
```

## Verificar Configuración Actual

Para ver qué está configurado:

```bash
firebase functions:config:get
```

## Ventajas de SendGrid vs Gmail

| Característica | SendGrid | Gmail |
|---------------|----------|-------|
| Límite gratuito | 100 emails/día | 500 emails/día |
| Deliverability | Excelente | Buena |
| Configuración | Muy fácil | Requiere MFA |
| Para producción | ✅ Recomendado | ⚠️ Limitado |
| API | ✅ Sí | ❌ No |

## Recomendación Final

**Usa SendGrid** porque:
- Es más profesional
- Mejor para aplicaciones
- No depende de políticas de Google/Microsoft
- Fácil de escalar cuando crezcas


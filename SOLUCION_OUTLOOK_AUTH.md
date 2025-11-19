# 🔧 Solución: Error "Basic Authentication is Disabled" en Outlook

## Problema

El error `535 5.7.139 Authentication unsuccessful, basic authentication is disabled` indica que Microsoft ha deshabilitado la autenticación básica para tu cuenta de Outlook.

## Soluciones

### Opción 1: Habilitar Autenticación Básica (Recomendado para desarrollo)

1. Ve a [Microsoft 365 Admin Center](https://admin.microsoft.com/)
2. Ve a **Configuración** → **Correo**
3. Busca **Autenticación moderna** o **Modern Authentication**
4. **Deshabilita** la autenticación moderna temporalmente
5. O busca la opción para **habilitar autenticación básica**

**Nota:** Microsoft está eliminando la autenticación básica, así que esta es una solución temporal.

### Opción 2: Usar SendGrid (Recomendado para producción)

SendGrid es más confiable para envío de emails desde aplicaciones:

1. Crea una cuenta en [SendGrid](https://sendgrid.com/)
2. Genera una API Key
3. Configura las variables:

```bash
firebase functions:config:set \
  support.email_user="apikey" \
  support.email_pass="TU_API_KEY_DE_SENDGRID" \
  support.smtp_host="smtp.sendgrid.net" \
  support.smtp_port="465" \
  support.smtp_secure="true"
```

### Opción 3: Usar Gmail SMTP (Alternativa)

Si tienes una cuenta de Gmail:

1. Habilita "Contraseñas de aplicaciones" en tu cuenta de Google
2. Genera una contraseña de aplicación
3. Configura:

```bash
firebase functions:config:set \
  support.email_user="tu_email@gmail.com" \
  support.email_pass="TU_CONTRASEÑA_DE_APLICACION" \
  support.smtp_host="smtp.gmail.com" \
  support.smtp_port="587" \
  support.smtp_secure="false"
```

### Opción 4: Usar OAuth2 con Outlook (Avanzado)

Requiere configuración de OAuth2, más complejo pero más seguro.

## Verificar Configuración Actual

Para ver qué está configurado actualmente:

```bash
firebase functions:config:get
```

## Próximos Pasos

1. Elige una de las opciones arriba
2. Configura las variables de entorno
3. Redesplega la función:
   ```bash
   firebase deploy --only functions:processSupportRequest
   ```
4. Prueba enviando una sugerencia desde la app

## Recomendación

Para producción, **recomiendo usar SendGrid** porque:
- ✅ Más confiable
- ✅ Mejor deliverability
- ✅ No depende de políticas de Microsoft
- ✅ Gratis hasta 100 emails/día
- ✅ Fácil de configurar


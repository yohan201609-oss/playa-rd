# 📧 Configuración de Email de Soporte - Playas RD

## Problema Identificado

Los mensajes de soporte se están creando correctamente en Firestore, pero el envío por email falla con el error:
```
Invalid login: 535 Authentication failed: The provided authorization grant is invalid, expired, or revoked
```

## Solución: Configurar Credenciales SMTP para Outlook

### Paso 1: Obtener Contraseña de Aplicación de Outlook

1. Ve a [Microsoft Account Security](https://account.microsoft.com/security)
2. Inicia sesión con `soporteplayasrd@outlook.com`
3. Ve a **Seguridad** → **Verificación en dos pasos** (debe estar activada)
4. Ve a **Contraseñas de aplicaciones**
5. Crea una nueva contraseña de aplicación llamada "Playas RD Cloud Function"
6. **Copia la contraseña generada** (16 caracteres sin espacios)

### Paso 2: Configurar Variables de Entorno en Firebase

Ejecuta estos comandos en la terminal desde la raíz del proyecto:

```bash
# Navegar a la carpeta de functions
cd functions

# Configurar las variables de entorno
firebase functions:config:set \
  support_email_user="soporteplayasrd@outlook.com" \
  support_email_pass="TU_CONTRASEÑA_DE_APLICACION_AQUI" \
  support_smtp_host="smtp.office365.com" \
  support_smtp_port="587" \
  support_smtp_secure="false"
```

**⚠️ IMPORTANTE:** Reemplaza `TU_CONTRASEÑA_DE_APLICACION_AQUI` con la contraseña de aplicación que generaste en el Paso 1.

### Paso 3: Redesplegar la Cloud Function

```bash
# Asegúrate de estar en la carpeta functions
cd functions

# Instalar dependencias (si no lo has hecho)
npm install

# Desplegar solo la función de soporte
firebase deploy --only functions:processSupportRequest
```

### Paso 4: Verificar la Configuración

1. Envía una sugerencia o reporte desde la app
2. Ve a Firebase Console → Firestore → `support_requests`
3. Verifica que el documento tenga `status: "sent"` en lugar de `status: "error"`
4. Revisa tu bandeja de entrada de `soporteplayasrd@outlook.com`

## Configuración Alternativa: Usar SendGrid

Si prefieres usar SendGrid en lugar de Outlook:

```bash
firebase functions:config:set \
  support_email_user="apikey" \
  support_email_pass="TU_API_KEY_DE_SENDGRID" \
  support_smtp_host="smtp.sendgrid.net" \
  support_smtp_port="465" \
  support_smtp_secure="true"
```

## Verificar Logs de la Cloud Function

Para ver los logs y diagnosticar problemas:

```bash
firebase functions:log --only processSupportRequest
```

## Estructura del Email Enviado

Cuando funcione correctamente, recibirás emails con:
- **Asunto:** "Nueva sugerencia desde Playas RD · [ID]" o "Nuevo reporte de problema desde Playas RD · [ID]"
- **Contenido:** Mensaje del usuario, contacto, email, nombre, plataforma, ID de solicitud

## Notas Importantes

1. **Contraseña de Aplicación vs Contraseña Normal:**
   - Outlook requiere una "Contraseña de Aplicación" para servicios externos
   - No uses tu contraseña normal de Outlook
   - La contraseña de aplicación es de 16 caracteres

2. **Verificación en Dos Pasos:**
   - Debe estar activada para generar contraseñas de aplicación
   - Si no está activada, actívala primero

3. **Seguridad:**
   - Las variables de entorno están encriptadas en Firebase
   - No compartas las contraseñas de aplicación
   - Si comprometes una contraseña, revócala y crea una nueva

## Troubleshooting

### Error: "535 Authentication failed"
- Verifica que la contraseña de aplicación sea correcta
- Asegúrate de que la verificación en dos pasos esté activada
- Verifica que el usuario sea `soporteplayasrd@outlook.com` (completo)

### Error: "Connection timeout"
- Verifica que el puerto sea 587 (no 465 para STARTTLS)
- Verifica que `secure: false` esté configurado para puerto 587

### Error: "Invalid host"
- Verifica que `support_smtp_host` sea `smtp.office365.com`
- No uses `smtp.outlook.com` (está deprecado)

## Estado Actual

✅ **Funcionando:**
- Creación de documentos en Firestore
- Ejecución de Cloud Function
- Captura de datos del usuario

❌ **Pendiente:**
- Configuración de credenciales SMTP
- Envío exitoso de emails


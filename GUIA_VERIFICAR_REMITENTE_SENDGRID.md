# 📧 Guía: Verificar Remitente Único en SendGrid

## ¿Por qué necesitas verificar el remitente?

SendGrid requiere verificar que eres el dueño del email desde el cual envías correos. Esto previene spam y mejora la deliverability.

## Pasos para Verificar el Remitente

### Paso 1: Acceder a SendGrid

1. Ve a [https://app.sendgrid.com/](https://app.sendgrid.com/)
2. Inicia sesión con tu cuenta de SendGrid

### Paso 2: Ir a Sender Authentication

1. En el menú lateral izquierdo, haz clic en **Settings** (Configuración)
2. En el submenú, haz clic en **Sender Authentication** (Autenticación de Remitente)

### Paso 3: Verificar Single Sender

1. Verás varias opciones. Haz clic en **Verify a Single Sender** (Verificar un Remitente Único)
2. O busca el botón **Create New Sender** (Crear Nuevo Remitente)

### Paso 4: Completar el Formulario

Completa todos los campos requeridos:

**Información del Remitente:**
- **From Email Address**: `soporteplayasrd@outlook.com`
- **From Name**: `Playas RD Soporte` (o el nombre que prefieras)
- **Reply To**: `soporteplayasrd@outlook.com` (puede ser el mismo)
- **Company Address**: Tu dirección física (requerido por SendGrid)
  - Ejemplo: `Calle Principal #123, Santo Domingo, República Dominicana`
- **City**: `Santo Domingo` (o tu ciudad)
- **State**: `Distrito Nacional` (o tu estado/provincia)
- **Country**: `Dominican Republic` (República Dominicana)
- **Zip Code**: `10101` (tu código postal)

**Información Adicional:**
- **Website**: Puedes dejar en blanco o poner una URL si tienes
- **Company Name**: `Playas RD` (o el nombre de tu empresa)

### Paso 5: Aceptar Términos

1. Marca la casilla que dice que aceptas los términos y condiciones
2. Haz clic en **Create** (Crear) o **Verify** (Verificar)

### Paso 6: Verificar el Email

1. SendGrid enviará un email de verificación a `soporteplayasrd@outlook.com`
2. **Abre tu bandeja de entrada de Outlook**
3. Busca un email de SendGrid con el asunto "Verify your sender identity" o similar
4. **Haz clic en el enlace de verificación** dentro del email
5. O copia el código de verificación y pégalo en SendGrid

### Paso 7: Confirmar Verificación

1. Después de hacer clic en el enlace, regresa a SendGrid
2. Deberías ver un mensaje de "Sender Verified" o "Verificado"
3. El estado del remitente cambiará a **Verified** (Verificado) con un check verde ✅

## Verificar que Está Configurado Correctamente

1. Ve a **Settings** → **Sender Authentication**
2. Deberías ver tu remitente listado con estado **Verified** ✅
3. El email `soporteplayasrd@outlook.com` debe aparecer como verificado

## Importante

- ⚠️ **Solo puedes enviar emails DESDE el email verificado**
- ✅ El email de destino puede ser cualquier email (incluyendo el mismo)
- 📧 Los emails llegarán desde `soporteplayasrd@outlook.com` a `soporteplayasrd@outlook.com`

## Si No Recibes el Email de Verificación

1. Revisa la carpeta de **Spam** o **Correo no deseado**
2. Espera unos minutos (puede tardar hasta 10 minutos)
3. Verifica que el email esté escrito correctamente
4. Intenta crear el remitente nuevamente

## Prueba Después de Verificar

Una vez verificado:

1. Envía una sugerencia desde la app
2. Deberías recibir el email en `soporteplayasrd@outlook.com`
3. El email llegará desde `Playas RD Soporte <soporteplayasrd@outlook.com>`

## Solución de Problemas

### Error: "Invalid email address"
- Verifica que el email esté escrito correctamente
- Asegúrate de que el email existe y puedes acceder a él

### Error: "Address already verified"
- El remitente ya está verificado
- Puedes usarlo directamente

### El email no llega después de verificar
- Espera 5-10 minutos después de verificar
- Revisa los logs de Firebase Functions
- Verifica que la API Key tenga permisos de "Mail Send"

## Listo para Usar

Una vez verificado, tu sistema de soporte estará completamente funcional. Los emails se enviarán automáticamente cuando los usuarios envíen sugerencias o reporten problemas.






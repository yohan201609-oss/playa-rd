# 🔧 Corregir Authorized Redirect URI para Android

## ❌ Error Actual

Estás intentando agregar:
```
com.googleusercontent.apps.360714035813-Irrgnhe5eqvuu755ntif56
```

**Problemas:**
1. ❌ Le falta el `:/` al final
2. ❌ El Client ID está incompleto (falta parte del ID)
3. ❌ Google Cloud Console espera un formato válido

## ✅ Solución: URI Correcto

### Paso 1: Eliminar el URI Incorrecto

1. En la sección "URIs de redireccionamiento autorizados"
2. Busca el URI con el borde rojo: `com.googleusercontent.apps.360714035813-Irrgnhe5eqvuu755ntif56`
3. Haz clic en el **icono de basura** (🗑️) para eliminarlo

### Paso 2: Agregar el URI Correcto

1. Haz clic en **"+ Agregar URI"**
2. Agrega este URI completo:
   ```
   com.googleusercontent.apps.360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6:/
   ```

**⚠️ IMPORTANTE:**
- Debe terminar con `:/` (dos puntos y barra diagonal)
- El Client ID completo es: `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6`
- El formato completo es: `com.googleusercontent.apps.[CLIENT_ID]:/`

### Paso 3: Guardar

1. Haz clic en **"GUARDAR"** o **"SAVE"**
2. Espera a que se guarde correctamente

## 📋 Formato Correcto Explicado

Para Android apps con Google Sign-In, el redirect URI debe seguir este formato:

```
com.googleusercontent.apps.[WEB_CLIENT_ID]:/
```

Donde:
- `com.googleusercontent.apps.` es el prefijo fijo
- `[WEB_CLIENT_ID]` es tu Web Client ID (sin `.apps.googleusercontent.com`)
- `:/` es el custom scheme necesario para Android

## ✅ Verificación

Después de agregar el URI correcto, deberías ver:
- ✅ El URI sin borde rojo
- ✅ Sin mensaje de error
- ✅ El URI completo: `com.googleusercontent.apps.360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6:/`

## 🔄 Después de Guardar

1. **Espera 5-10 minutos** para que los cambios se propaguen
2. **Prueba Google Sign-In** en la app
3. El error `ApiException: 10` debería desaparecer

## 📝 Nota

El mensaje de error "debe usar http o https como esquema" es engañoso. Para Android apps, el custom scheme `com.googleusercontent.apps.[ID]:/` es válido y necesario, aunque Google Cloud Console muestre esa advertencia inicialmente. Una vez que agregues el `:/` al final, debería aceptarse correctamente.



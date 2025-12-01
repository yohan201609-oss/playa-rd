# 🔧 Configurar Web Client OAuth para Google Sign-In

## 📋 Estado Actual

Veo que tienes el **Web client** creado:
- **Client ID:** `360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6` (o similar)
- **Tipo:** Aplicación web
- **Creado:** 17 oct 2025

## 🎯 Acción Requerida: Verificar Configuración del Web Client

### Paso 1: Abrir Configuración del Web Client

1. En la página de **Credentials** que estás viendo
2. Busca el **"Web client (auto created by Google Service)"**
3. Haz clic en el **icono de editar** (lápiz) o en el nombre del client

### Paso 2: Verificar Authorized Redirect URIs

En la configuración del Web client, verifica la sección **"Authorized redirect URIs"**.

**Debe incluir:**
```
com.googleusercontent.apps.360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6:/
```

**Si NO está agregado:**
1. Haz clic en **"+ ADD URI"**
2. Agrega: `com.googleusercontent.apps.360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6:/`
3. Haz clic en **"SAVE"**

### Paso 3: Verificar Authorized JavaScript Origins (Opcional)

Para apps móviles, esta sección puede estar vacía o incluir:
```
https://playas-rd-2b475.firebaseapp.com
```

### Paso 4: Verificar que el Client esté Habilitado

Asegúrate de que el Web client esté **habilitado** (no deshabilitado).

## 🔍 Verificación Adicional: OAuth Consent Screen

Después de verificar el Web client, también necesitas verificar el **OAuth Consent Screen**:

1. En el menú lateral, ve a **"OAuth consent screen"**
2. Verifica:
   - **Estado:** "Testing" o "In production"
   - **Scopes:** Debe incluir `email`, `profile`, `openid`
   - **Test users:** Si está en "Testing", agrega los emails de los testers

## ✅ Checklist de Verificación

- [ ] Web client abierto y configurado
- [ ] Authorized redirect URI agregado: `com.googleusercontent.apps.360714035813-lrrgnhe5eqvuu755ntif56i92q6u5an6:/`
- [ ] Web client habilitado
- [ ] OAuth Consent Screen verificado
- [ ] Test users agregados (si está en modo Testing)

## 🔄 Después de los Cambios

1. **Espera 5-10 minutos** para que los cambios se propaguen
2. **Regenera el App Bundle** (si es necesario):
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```
3. **Sube nueva versión** a prueba cerrada

## 📝 Nota Importante

El **Authorized redirect URI** es crítico para que Google Sign-In funcione correctamente en Android. Sin este URI, el `idToken` no se puede obtener, causando el error `ApiException: 10`.



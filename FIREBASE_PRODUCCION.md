# 🔥 Guía: Cambiar Firebase de Prueba a Producción

## 📋 Índice

1. [Cambios Realizados](#1-cambios-realizados)
2. [Desplegar Reglas de Firestore](#2-desplegar-reglas-de-firestore)
3. [Desplegar Reglas de Storage](#3-desplegar-reglas-de-storage)
4. [Configurar Restricciones de API Keys](#4-configurar-restricciones-de-api-keys)
5. [Verificación Final](#5-verificación-final)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Cambios Realizados

### ✅ Reglas de Firestore Actualizadas

**ANTES (Modo Prueba):**
- Las playas permitían escritura sin autenticación
- Cualquiera podía modificar la base de datos

**DESPUÉS (Modo Producción):**
- Las playas requieren autenticación para escritura
- Solo usuarios autenticados pueden crear/modificar playas
- La lectura sigue siendo pública

### ✅ Reglas de Storage Actualizadas

**Mejoras:**
- Agregado límite de tamaño de archivo para fotos de playas (10MB)
- Validación de tipo de archivo (solo imágenes)
- Mantenidas las restricciones de seguridad existentes

---

## 2. Desplegar Reglas de Firestore

### Paso 2.1: Instalar Firebase CLI (si no lo tienes)

```bash
# Instalar Firebase CLI globalmente
npm install -g firebase-tools

# Verificar instalación
firebase --version
```

### Paso 2.2: Iniciar Sesión en Firebase

```bash
# Iniciar sesión en Firebase
firebase login

# Verificar que estás conectado al proyecto correcto
firebase projects:list
```

### Paso 2.3: Verificar Proyecto Actual

```bash
# Ver el proyecto actual configurado
firebase use

# Debe mostrar: playas-rd-2b475 (actual)
```

Si necesitas cambiar de proyecto:

```bash
# Listar proyectos disponibles
firebase projects:list

# Cambiar a otro proyecto (si tienes múltiples)
firebase use playas-rd-2b475
```

### Paso 2.4: Desplegar Reglas de Firestore

```bash
# Desplegar solo las reglas de Firestore
firebase deploy --only firestore:rules

# O desplegar todo (reglas + índices)
firebase deploy --only firestore
```

**Salida esperada:**
```
✔  Deploy complete!

Firestore Rules deployed to playas-rd-2b475
```

### Paso 2.5: Verificar Reglas Desplegadas

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona el proyecto `playas-rd-2b475`
3. Ve a **Firestore Database** > **Rules**
4. Verifica que las reglas sean:

```javascript
// PLAYAS - Producción
match /beaches/{beachId} {
  allow read: if true; // Todos pueden leer playas
  allow write: if isSignedIn(); // Solo usuarios autenticados pueden escribir
}
```

---

## 3. Desplegar Reglas de Storage

### Paso 3.1: Desplegar Reglas de Storage

```bash
# Desplegar solo las reglas de Storage
firebase deploy --only storage

# O desplegar todo (Firestore + Storage)
firebase deploy --only firestore,storage
```

**Salida esperada:**
```
✔  Deploy complete!

Storage Rules deployed to playas-rd-2b475
```

### Paso 3.2: Verificar Reglas Desplegadas

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona el proyecto `playas-rd-2b475`
3. Ve a **Storage** > **Rules**
4. Verifica que las reglas incluyan límites de tamaño y validaciones

---

## 4. Configurar Restricciones de API Keys

### ⚠️ **PRIORIDAD ALTA** - Seguridad en Producción

### Paso 4.1: Acceder a Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto `playas-rd-2b475`
3. Ve a **APIs & Services** > **Credentials**

### Paso 4.2: Restringir API Key de Android

**API Key:** `AIzaSyDFS0POsHWn9azaDIAviZM8FlUSjf8_fVs`

1. Haz clic en la API Key de Android
2. En **Application restrictions**:
   - Selecciona **Android apps**
   - Agrega el package name: `com.playasrd.playasrd`
   - Agrega el SHA-1 de tu keystore de release:
     ```bash
     # Obtener SHA-1 del keystore de release
     keytool -list -v -keystore ~/playas-rd-release-key.jks -alias playas-rd
     ```
3. En **API restrictions**:
   - Selecciona **Restrict key**
   - Marca solo estas APIs:
     - ✅ Firebase Authentication API
     - ✅ Cloud Firestore API
     - ✅ Firebase Storage API
     - ✅ Firebase Cloud Messaging API
     - ✅ Google Sign-In API

### Paso 4.3: Restringir API Key de iOS

**API Key:** `AIzaSyCpUfP7yerqjzXPMSxGU4I50OpQATcrqQ4`

1. Haz clic en la API Key de iOS
2. En **Application restrictions**:
   - Selecciona **iOS apps**
   - Agrega el bundle ID: `com.playasrd.playasrd`
3. En **API restrictions**:
   - Selecciona **Restrict key**
   - Marca solo estas APIs:
     - ✅ Firebase Authentication API
     - ✅ Cloud Firestore API
     - ✅ Firebase Storage API
     - ✅ Firebase Cloud Messaging API
     - ✅ Google Sign-In API

### Paso 4.4: Restringir API Key de Web

**API Key:** `AIzaSyDM9AnOHCBlyKJ98jNI_5r1y-xfAcJYLgI`

1. Haz clic en la API Key de Web
2. En **Application restrictions**:
   - Selecciona **HTTP referrers (web sites)**
   - Agrega los dominios permitidos:
     - `https://playas-rd-2b475.firebaseapp.com/*`
     - `https://playas-rd-2b475.web.app/*`
     - `http://localhost:*` (solo para desarrollo local)
3. En **API restrictions**:
   - Selecciona **Restrict key**
   - Marca solo estas APIs:
     - ✅ Firebase Authentication API
     - ✅ Cloud Firestore API
     - ✅ Firebase Storage API
     - ✅ Firebase Cloud Messaging API

### Paso 4.5: Habilitar APIs Necesarias

Asegúrate de que estas APIs estén habilitadas en Google Cloud Console:

1. Ve a **APIs & Services** > **Library**
2. Busca y habilita estas APIs:
   - ✅ **Firebase Authentication API**
   - ✅ **Cloud Firestore API**
   - ✅ **Firebase Storage API**
   - ✅ **Firebase Cloud Messaging API**
   - ✅ **Google Sign-In API**
   - ✅ **Identity Toolkit API**

---

## 5. Verificación Final

### Paso 5.1: Verificar Reglas de Firestore

```bash
# Probar las reglas localmente (opcional)
firebase emulators:start --only firestore

# Verificar reglas desplegadas
firebase firestore:rules:get
```

### Paso 5.2: Verificar Reglas de Storage

```bash
# Probar las reglas localmente (opcional)
firebase emulators:start --only storage

# Verificar reglas desplegadas
firebase storage:rules:get
```

### Paso 5.3: Probar la Aplicación

1. **Probar autenticación:**
   - Login con Google
   - Registro de nuevos usuarios
   - Logout

2. **Probar Firestore:**
   - Leer playas (debe funcionar sin autenticación)
   - Crear/modificar playa (debe requerir autenticación)
   - Crear reporte (debe requerir autenticación)

3. **Probar Storage:**
   - Subir foto de perfil (debe requerir autenticación)
   - Subir foto de reporte (debe requerir autenticación)
   - Ver fotos (debe funcionar sin autenticación)

### Paso 5.4: Verificar en Firebase Console

1. **Firestore:**
   - Ve a **Firestore Database** > **Data**
   - Verifica que los datos existan
   - Intenta crear un documento manualmente (debe fallar sin autenticación)

2. **Storage:**
   - Ve a **Storage** > **Files**
   - Verifica que los archivos existan
   - Intenta subir un archivo manualmente (debe fallar sin autenticación)

3. **Authentication:**
   - Ve a **Authentication** > **Users**
   - Verifica que los usuarios existan

---

## 6. Troubleshooting

### Error: "Permission denied" al escribir en Firestore

**Causa:** Las reglas requieren autenticación pero el usuario no está autenticado.

**Solución:**
1. Verifica que el usuario esté autenticado
2. Verifica que las reglas estén desplegadas correctamente
3. Revisa los logs en Firebase Console > Firestore > Usage

### Error: "Storage permission denied" al subir archivos

**Causa:** Las reglas requieren autenticación o el archivo excede el tamaño máximo.

**Solución:**
1. Verifica que el usuario esté autenticado
2. Verifica que el archivo sea menor a:
   - Reportes: 5MB
   - Perfiles: 2MB
   - Playas: 10MB
   - Fotos de visitantes: 5MB
3. Verifica que el archivo sea una imagen

### Error: "API key not valid" o "API key restricted"

**Causa:** Las restricciones de API key están mal configuradas.

**Solución:**
1. Verifica que el package name (Android) o bundle ID (iOS) coincida
2. Verifica que el SHA-1 (Android) sea correcto
3. Verifica que las APIs estén habilitadas
4. Verifica que las restricciones de dominio (Web) sean correctas

### Error: "Firebase project not found"

**Causa:** El proyecto no está configurado correctamente.

**Solución:**
```bash
# Verificar proyecto actual
firebase use

# Cambiar a proyecto correcto
firebase use playas-rd-2b475

# Verificar archivo .firebaserc
cat .firebaserc
```

### Error: "Rules deployment failed"

**Causa:** Las reglas tienen errores de sintaxis.

**Solución:**
1. Verifica la sintaxis de las reglas
2. Usa el simulador de reglas en Firebase Console
3. Prueba las reglas localmente con emuladores

---

## 📝 Checklist de Producción

### Reglas de Seguridad
- [x] Reglas de Firestore actualizadas para producción
- [x] Reglas de Storage actualizadas para producción
- [x] Reglas desplegadas en Firebase
- [x] Reglas verificadas en Firebase Console

### API Keys
- [ ] API Key de Android restringida
- [ ] API Key de iOS restringida
- [ ] API Key de Web restringida
- [ ] APIs necesarias habilitadas

### Verificación
- [ ] Autenticación funciona correctamente
- [ ] Lectura de datos funciona sin autenticación
- [ ] Escritura de datos requiere autenticación
- [ ] Subida de archivos funciona correctamente
- [ ] Restricciones de tamaño funcionan

### Documentación
- [x] Reglas documentadas en código
- [x] Guía de producción creada
- [ ] Proceso de despliegue documentado

---

## 🚀 Comandos Rápidos

```bash
# Desplegar todo (Firestore + Storage)
firebase deploy --only firestore,storage

# Desplegar solo Firestore
firebase deploy --only firestore:rules

# Desplegar solo Storage
firebase deploy --only storage

# Ver proyecto actual
firebase use

# Ver logs de despliegue
firebase deploy --only firestore:rules --debug

# Probar reglas localmente
firebase emulators:start --only firestore,storage
```

---

## 📚 Recursos Adicionales

- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules](https://firebase.google.com/docs/storage/security)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Google Cloud Console](https://console.cloud.google.com/)

---

## ✅ Resumen

### Cambios Realizados

1. **Reglas de Firestore:**
   - ✅ Requieren autenticación para escribir en playas
   - ✅ Mantienen lectura pública
   - ✅ Reportes y usuarios con reglas seguras

2. **Reglas de Storage:**
   - ✅ Límites de tamaño de archivo
   - ✅ Validación de tipo de archivo
   - ✅ Restricciones de autenticación

3. **Documentación:**
   - ✅ Guía completa de producción
   - ✅ Comandos de despliegue
   - ✅ Troubleshooting

### Próximos Pasos

1. Desplegar las reglas a Firebase
2. Configurar restricciones de API Keys
3. Probar la aplicación en producción
4. Monitorear logs y errores

---

**¡Firebase está listo para producción! 🔥**


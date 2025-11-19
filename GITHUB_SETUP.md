# 🚀 Guía para Subir el Proyecto a GitHub

## ✅ Estado Actual

- ✅ Repositorio Git inicializado
- ✅ `.gitignore` configurado (excluye archivos sensibles)
- ✅ Commit inicial creado

## 📋 Pasos para Subir a GitHub

### 1. Crear Repositorio en GitHub

1. Ve a [GitHub.com](https://github.com) e inicia sesión
2. Haz clic en el botón **"+"** en la esquina superior derecha
3. Selecciona **"New repository"**
4. Completa el formulario:
   - **Repository name**: `playa-rd` (recomendado) o cualquier otro nombre que prefieras
     - ✅ **Buenos nombres**: `playa-rd`, `playa_rd`, `playard`
     - ❌ **Evita espacios**: `Playa RD` (no permitido)
   - **Description**: "Aplicación Flutter para descubrir las mejores playas de República Dominicana"
   - **Visibility**: 
     - ✅ **Public** (recomendado si es open source)
     - ⚠️ **Private** (si quieres mantenerlo privado)
   - **NO marques** "Add a README file" (ya tenemos uno)
   - **NO marques** "Add .gitignore" (ya tenemos uno)
   - **NO marques** "Choose a license" (opcional)
5. Haz clic en **"Create repository"**

### 2. Conectar el Repositorio Local con GitHub

Después de crear el repositorio, GitHub te mostrará instrucciones. Ejecuta estos comandos en tu terminal:

```bash
# Añadir el repositorio remoto (reemplaza TU_USUARIO con tu usuario de GitHub)
# Si llamaste tu repositorio "playa-rd":
git remote add origin https://github.com/TU_USUARIO/playa-rd.git

# O si usaste otro nombre, reemplázalo:
# git remote add origin https://github.com/TU_USUARIO/NOMBRE_DE_TU_REPOSITORIO.git

# Verificar que se añadió correctamente
git remote -v
```

### 3. Subir el Código a GitHub

```bash
# Cambiar a la rama main (si no estás ya en ella)
git branch -M main

# Subir el código a GitHub
git push -u origin main
```

Si te pide autenticación:
- **Usuario**: Tu nombre de usuario de GitHub
- **Contraseña**: Usa un **Personal Access Token** (no tu contraseña de GitHub)
  - Crea uno en: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
  - Selecciona los permisos: `repo` (acceso completo a repositorios)

### 4. Verificar que se Subió Correctamente

1. Ve a tu repositorio en GitHub: `https://github.com/TU_USUARIO/playa-rd`
   (o el nombre que hayas elegido para tu repositorio)
2. Deberías ver todos tus archivos
3. Verifica que los archivos sensibles NO estén subidos:
   - ❌ `/android/app/google-services.json` (NO debe aparecer)
   - ❌ `/ios/Runner/GoogleService-Info.plist` (NO debe aparecer)
   - ❌ `/.env` (NO debe aparecer)
   - ❌ `/build/` (NO debe aparecer)

## 🔒 Archivos Protegidos (NO se Subirán)

Gracias al `.gitignore`, estos archivos NO se subirán a GitHub:

- ✅ Archivos de configuración de Firebase (google-services.json, GoogleService-Info.plist)
- ✅ Variables de entorno (.env)
- ✅ Archivos de build (/build/)
- ✅ Archivos de configuración local (local.properties)
- ✅ Node modules

## 📝 Próximos Pasos

### Crear un Archivo `.env.example`

Para que otros desarrolladores sepan qué variables de entorno necesitan:

```bash
# Crear archivo de ejemplo
# .env.example
OPENWEATHER_API_KEY=tu_api_key_aqui
```

### Actualizar el README

Agrega información sobre:
- Cómo clonar el repositorio
- Cómo configurar las variables de entorno
- Requisitos del sistema

## 🔄 Comandos Útiles para el Futuro

```bash
# Ver el estado del repositorio
git status

# Añadir cambios
git add .

# Hacer commit
git commit -m "Descripción de los cambios"

# Subir cambios a GitHub
git push

# Ver el historial de commits
git log

# Crear una nueva rama
git checkout -b nombre-de-la-rama

# Cambiar de rama
git checkout main
```

## ⚠️ Importante

**NUNCA subas a GitHub:**
- 🔑 API Keys
- 🔐 Tokens de acceso
- 📱 Archivos de configuración de Firebase
- 🔒 Variables de entorno con datos sensibles
- 💾 Archivos de build grandes

Si accidentalmente subiste algo sensible:
1. Elimínalo del repositorio en GitHub
2. Actualiza el `.gitignore`
3. Regenera las credenciales comprometidas

## 📚 Recursos

- [Documentación de Git](https://git-scm.com/doc)
- [Guía de GitHub](https://guides.github.com/)
- [Crear Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

---

¡Listo! Tu proyecto ahora está en GitHub 🎉


# 📥 Instrucciones para Clonar el Repositorio en Mac

## ✅ Comando Correcto

Abre Terminal en tu Mac y ejecuta:

```bash
cd ~/Desktop
git clone https://github.com/yohan201609-oss/playa-rd.git
```

## 📋 Pasos Detallados

### 1. Abrir Terminal
- Presiona `Cmd + Espacio` para abrir Spotlight
- Escribe "Terminal" y presiona Enter

### 2. Navegar al Escritorio
```bash
cd ~/Desktop
```

### 3. Clonar el Repositorio
```bash
git clone https://github.com/yohan201609-oss/playa-rd.git
```

**Nota importante:** 
- ✅ Usa `git clone` antes de la URL
- ✅ La URL correcta es: `https://github.com/yohan201609-oss/playa-rd.git`
- ❌ NO uses `/s/playa-rd.git` (ese es el error que viste)

### 4. Entrar al Directorio del Proyecto
```bash
cd playa-rd
```

### 5. Crear Archivo .env (IMPORTANTE)

**⚠️ Este paso es necesario para evitar errores de compilación:**

```bash
# Crear el archivo .env vacío
cat > .env << 'EOF'
# Variables de entorno para Playas RD
OPENWEATHER_API_KEY=
MAPS_API_KEY=
GOOGLE_MAPS_API_KEY=
GOOGLE_API_KEY=
API_BASE_URL=
FIREBASE_API_KEY=
EOF
```

O usa el script incluido:

```bash
chmod +x scripts/crear_env.sh
./scripts/crear_env.sh
```

**Nota:** El archivo `.env` puede estar vacío. La app funcionará sin problemas. Solo necesitas configurarlo si usas servicios que requieren API keys (como OpenWeatherMap para el clima).

### 6. Instalar Dependencias de Flutter
```bash
flutter pub get
```

## 🔧 Si Git no está Instalado

Si obtienes un error de que `git` no se encuentra:

### Opción 1: Instalar Xcode Command Line Tools
```bash
xcode-select --install
```

### Opción 2: Instalar Git con Homebrew
```bash
# Primero instala Homebrew si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Luego instala Git
brew install git
```

## 📱 Configurar API Key después de Clonar

Después de clonar, necesitas configurar la API Key de Google Maps:

```bash
cd ios/Runner
cp GoogleMaps-API-Key.h.template GoogleMaps-API-Key.h
```

Luego edita `GoogleMaps-API-Key.h` y reemplaza `YOUR_API_KEY_HERE` con tu clave API real.

## ✅ Verificación

Para verificar que todo está correcto:

```bash
# Ver el contenido del directorio
ls -la

# Verificar que estás en el directorio correcto
pwd

# Debería mostrar: /Users/tu-usuario/Desktop/playa-rd
```

## 🆘 Solución de Problemas

### Error: "command not found: git"
- Instala Git usando las instrucciones arriba

### Error: "repository not found"
- Verifica que la URL sea correcta: `https://github.com/yohan201609-oss/playa-rd.git`
- Verifica tu conexión a internet

### Error: "permission denied"
- Verifica que tengas permisos de escritura en el directorio
- Intenta con: `sudo git clone ...` (no recomendado, mejor arregla los permisos)

### Error: "No file or variants found for asset: .env"
- **Solución:** Crea el archivo `.env` vacío (ver paso 5 arriba)
- O ejecuta: `./scripts/crear_env.sh`
- Ver también: `SOLUCION_ERROR_ENV.md` para más detalles


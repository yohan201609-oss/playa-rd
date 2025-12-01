#!/bin/bash

# Script para crear el archivo .env si no existe
# Este script se ejecuta antes del build para evitar errores

ENV_FILE=".env"
ENV_EXAMPLE=".env.example"

# Si el archivo .env no existe, crear uno vacío
if [ ! -f "$ENV_FILE" ]; then
    echo "⚠️ Archivo .env no encontrado. Creando uno vacío..."
    
    cat > "$ENV_FILE" << 'EOF'
# Variables de entorno para Playas RD
# Este archivo es local y NO se sube al repositorio

# API Key de OpenWeatherMap (opcional - para servicio de clima)
OPENWEATHER_API_KEY=

# API Key de Google Maps (opcional)
MAPS_API_KEY=
GOOGLE_MAPS_API_KEY=
GOOGLE_API_KEY=

# URL base de API (opcional)
API_BASE_URL=

# Firebase API Key (opcional)
FIREBASE_API_KEY=
EOF
    
    echo "✅ Archivo .env creado. Configura tus API keys según sea necesario."
else
    echo "✅ Archivo .env ya existe."
fi


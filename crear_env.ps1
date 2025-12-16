# Script PowerShell para crear el archivo .env si no existe
# Este script se ejecuta antes del build para evitar errores

$envFile = ".env"
$envExample = ".env.example"

# Si el archivo .env no existe, crear uno vacío
if (-not (Test-Path $envFile)) {
    Write-Host "⚠️ Archivo .env no encontrado. Creando uno vacío..." -ForegroundColor Yellow
    
    @"
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
"@ | Out-File -FilePath $envFile -Encoding utf8
    
    Write-Host "✅ Archivo .env creado. Configura tus API keys según sea necesario." -ForegroundColor Green
} else {
    Write-Host "✅ Archivo .env ya existe." -ForegroundColor Green
}


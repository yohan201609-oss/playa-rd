# Script para crear enlace simbólico del Android SDK
# EJECUTAR COMO ADMINISTRADOR

# Crear directorio si no existe
New-Item -ItemType Directory -Path "C:\Android" -Force

# Crear enlace simbólico
New-Item -ItemType SymbolicLink -Path "C:\Android\sdk" -Target "C:\Users\Johan Almanzar\AppData\Local\Android\sdk"

Write-Host "✅ Enlace simbólico creado exitosamente" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora necesitas actualizar la variable de entorno ANDROID_HOME:" -ForegroundColor Yellow
Write-Host "1. Abre 'Variables de entorno' en Windows" -ForegroundColor Yellow
Write-Host "2. Edita la variable ANDROID_HOME" -ForegroundColor Yellow
Write-Host "3. Cambia a: C:\Android\sdk" -ForegroundColor Yellow
Write-Host "4. Reinicia tu terminal/IDE" -ForegroundColor Yellow





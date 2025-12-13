# Script para configurar las variables de entorno del sistema para Android SDK
# Esto resuelve permanentemente el error "failed to strip debug symbols"
# Requiere ejecutarse como Administrador

Write-Host "🔧 Configurando variables de entorno del sistema para Android SDK..." -ForegroundColor Cyan
Write-Host ""

# Verificar si se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ Este script requiere permisos de Administrador." -ForegroundColor Red
    Write-Host "   Por favor, ejecuta PowerShell como Administrador y vuelve a ejecutar este script." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Para ejecutar como Administrador:" -ForegroundColor Yellow
    Write-Host "   1. Cierra esta ventana" -ForegroundColor Yellow
    Write-Host "   2. Busca 'PowerShell' en el menú inicio" -ForegroundColor Yellow
    Write-Host "   3. Haz clic derecho y selecciona 'Ejecutar como administrador'" -ForegroundColor Yellow
    Write-Host "   4. Navega a este directorio: $PWD" -ForegroundColor Yellow
    Write-Host "   5. Ejecuta: .\configurar-android-sdk.ps1" -ForegroundColor Yellow
    exit 1
}

# Ruta del SDK sin espacios (usando el symlink)
$sdkPath = "C:\Android\sdk"

# Verificar que el symlink existe
if (-not (Test-Path $sdkPath)) {
    Write-Host "⚠️  El symlink $sdkPath no existe." -ForegroundColor Yellow
    Write-Host "   Creando symlink..." -ForegroundColor Yellow
    
    $originalPath = "$env:LOCALAPPDATA\Android\sdk"
    if (Test-Path $originalPath) {
        cmd /c mklink /D $sdkPath "`"$originalPath`""
        Write-Host "✅ Symlink creado" -ForegroundColor Green
    } else {
        Write-Host "❌ No se encontró el Android SDK en: $originalPath" -ForegroundColor Red
        exit 1
    }
}

Write-Host "📍 Ruta del SDK: $sdkPath" -ForegroundColor Cyan
Write-Host ""

# Configurar variables de entorno del sistema
Write-Host "🔨 Configurando variables de entorno del sistema..." -ForegroundColor Cyan

# ANDROID_HOME
[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, [System.EnvironmentVariableTarget]::Machine)
Write-Host "✅ ANDROID_HOME configurado" -ForegroundColor Green

# ANDROID_SDK_ROOT
[System.Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkPath, [System.EnvironmentVariableTarget]::Machine)
Write-Host "✅ ANDROID_SDK_ROOT configurado" -ForegroundColor Green

Write-Host ""
Write-Host "✅ Variables de entorno configuradas exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Próximos pasos:" -ForegroundColor Cyan
Write-Host "   1. Cierra y vuelve a abrir todas las ventanas de PowerShell/CMD" -ForegroundColor Yellow
Write-Host "   2. Cierra y vuelve a abrir tu IDE (VS Code, Android Studio, etc.)" -ForegroundColor Yellow
Write-Host "   3. Verifica con: flutter doctor -v" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Las variables estarán disponibles en todas las nuevas sesiones." -ForegroundColor Gray
Write-Host ""

# Mostrar valores actuales (solo para esta sesión)
$env:ANDROID_HOME = $sdkPath
$env:ANDROID_SDK_ROOT = $sdkPath

Write-Host "Valores configurados (esta sesión):" -ForegroundColor Cyan
Write-Host "  ANDROID_HOME = $env:ANDROID_HOME" -ForegroundColor Gray
Write-Host "  ANDROID_SDK_ROOT = $env:ANDROID_SDK_ROOT" -ForegroundColor Gray
Write-Host ""


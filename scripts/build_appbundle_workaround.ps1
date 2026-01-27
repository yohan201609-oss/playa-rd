# Script de workaround para construir app bundle
# Soluciona el error de espacios en la ruta del SDK

Write-Host "Configurando entorno para construir app bundle..." -ForegroundColor Cyan

$sdkPathActual = "$env:LOCALAPPDATA\Android\Sdk"
$sdkPathTemporal = "C:\AndroidSdkTemp"

# 1. Verificar SDK
if (-not (Test-Path $sdkPathActual)) {
    Write-Host "ERROR: No se encontro el SDK en: $sdkPathActual" -ForegroundColor Red
    exit 1
}

# 2. Gestionar enlace simbolico
if (Test-Path $sdkPathTemporal) {
    Write-Host "Aviso: Ya existe la ruta temporal $sdkPathTemporal" -ForegroundColor Yellow
    $resp = Read-Host "Quieres recrearla? (S/N)"
    if ($resp -eq "S" -or $resp -eq "s") {
        Remove-Item -Path $sdkPathTemporal -Force -Recurse -ErrorAction SilentlyContinue
    }
}

if (-not (Test-Path $sdkPathTemporal)) {
    Write-Host "Creando enlace simbolico en $sdkPathTemporal..." -ForegroundColor Yellow
    try {
        New-Item -ItemType SymbolicLink -Path $sdkPathTemporal -Target $sdkPathActual -Force | Out-Null
        Write-Host "Enlace creado correctamente." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo crear el enlace." -ForegroundColor Red
        Write-Host "Ejecuta VS Code o PowerShell como ADMINISTRADOR." -ForegroundColor Yellow
        exit 1
    }
}

# 3. Variables de entorno temporales
$oldHome = $env:ANDROID_HOME
$oldRoot = $env:ANDROID_SDK_ROOT

$env:ANDROID_HOME = $sdkPathTemporal
$env:ANDROID_SDK_ROOT = $sdkPathTemporal

# 4. Compilar
Write-Host "Iniciando compilacion de Flutter..." -ForegroundColor Cyan
try {
    flutter build appbundle --release
    if ($LASTEXITCODE -eq 0) {
        Write-Host "COMPILACION EXITOSA" -ForegroundColor Green
    } else {
        Write-Host "ERROR EN LA COMPILACION" -ForegroundColor Red
    }
} finally {
    # Restaurar variables
    $env:ANDROID_HOME = $oldHome
    $env:ANDROID_SDK_ROOT = $oldRoot
}

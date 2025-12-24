# Script de workaround para construir app bundle cuando el SDK tiene espacios en la ruta
# Este script crea un enlace simbólico temporal sin espacios y construye el bundle

Write-Host "🔧 Workaround para construir app bundle con SDK en ruta con espacios" -ForegroundColor Cyan
Write-Host ""

$sdkPathActual = "$env:LOCALAPPDATA\Android\Sdk"
$sdkPathTemporal = "C:\AndroidSdkTemp"

# Verificar si el SDK existe
if (-not (Test-Path $sdkPathActual)) {
    Write-Host "❌ No se encontró el Android SDK en: $sdkPathActual" -ForegroundColor Red
    Write-Host "   Verifica la ruta con: flutter doctor -v" -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 SDK actual: $sdkPathActual" -ForegroundColor White
Write-Host "📦 Ruta temporal: $sdkPathTemporal" -ForegroundColor White
Write-Host ""

# Verificar si ya existe un enlace simbólico
if (Test-Path $sdkPathTemporal) {
    Write-Host "⚠️  Ya existe un enlace en: $sdkPathTemporal" -ForegroundColor Yellow
    $respuesta = Read-Host "¿Deseas eliminarlo y crear uno nuevo? (S/N)"
    if ($respuesta -eq "S" -or $respuesta -eq "s") {
        Remove-Item -Path $sdkPathTemporal -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Usando el enlace existente..." -ForegroundColor Gray
    }
}

# Crear enlace simbólico si no existe
if (-not (Test-Path $sdkPathTemporal)) {
    Write-Host "🔗 Creando enlace simbólico..." -ForegroundColor Yellow
    
    # Requiere permisos de administrador para crear enlaces simbólicos
    try {
        # Intentar crear el enlace simbólico
        $null = New-Item -ItemType SymbolicLink -Path $sdkPathTemporal -Target $sdkPathActual -Force
        Write-Host "✅ Enlace simbólico creado" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al crear enlace simbólico: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Solución: Ejecuta PowerShell como Administrador o mueve el SDK permanentemente:" -ForegroundColor Yellow
        Write-Host "   .\scripts\mover_android_sdk.ps1" -ForegroundColor White
        exit 1
    }
}

# Guardar variables de entorno originales
$androidHomeOriginal = $env:ANDROID_HOME
$androidSdkRootOriginal = $env:ANDROID_SDK_ROOT

# Establecer variables de entorno temporales
Write-Host "🔧 Configurando variables de entorno temporales..." -ForegroundColor Yellow
$env:ANDROID_HOME = $sdkPathTemporal
$env:ANDROID_SDK_ROOT = $sdkPathTemporal

Write-Host "✅ Variables de entorno configuradas" -ForegroundColor Green
Write-Host ""

# Construir el bundle
Write-Host "🏗️  Construyendo app bundle..." -ForegroundColor Cyan
Write-Host ""

try {
    flutter build appbundle --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Build completado exitosamente" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ Build falló con código de salida: $LASTEXITCODE" -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error durante el build: $_" -ForegroundColor Red
} finally {
    # Restaurar variables de entorno originales
    $env:ANDROID_HOME = $androidHomeOriginal
    $env:ANDROID_SDK_ROOT = $androidSdkRootOriginal
    
    Write-Host ""
    Write-Host "🔄 Variables de entorno restauradas" -ForegroundColor Gray
}

Write-Host ""
Write-Host "💡 Nota: El enlace simbólico en $sdkPathTemporal se mantiene para futuros builds." -ForegroundColor Yellow
Write-Host "   Para eliminarlo: Remove-Item -Path '$sdkPathTemporal' -Force" -ForegroundColor Gray












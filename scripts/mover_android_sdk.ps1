# Script para mover Android SDK a una ruta sin espacios
# Soluciona el error: "Release app bundle failed to strip debug symbols from native libraries"

Write-Host "🔧 Script para mover Android SDK a una ruta sin espacios" -ForegroundColor Cyan
Write-Host ""

# Ruta actual del SDK (con espacios)
$rutaActual = "$env:LOCALAPPDATA\Android\Sdk"
$rutaNueva = "C:\Android\Sdk"

# Verificar si la ruta actual existe
if (-not (Test-Path $rutaActual)) {
    Write-Host "❌ No se encontró el Android SDK en: $rutaActual" -ForegroundColor Red
    Write-Host "   Verifica la ruta con: flutter doctor -v" -ForegroundColor Yellow
    exit 1
}

# Verificar si la ruta nueva ya existe
if (Test-Path $rutaNueva) {
    Write-Host "⚠️  La ruta destino ya existe: $rutaNueva" -ForegroundColor Yellow
    $respuesta = Read-Host "¿Deseas sobrescribir? (S/N)"
    if ($respuesta -ne "S" -and $respuesta -ne "s") {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
        exit 0
    }
    Remove-Item -Path $rutaNueva -Recurse -Force
}

Write-Host "📦 Ruta actual: $rutaActual" -ForegroundColor White
Write-Host "📦 Ruta nueva:  $rutaNueva" -ForegroundColor White
Write-Host ""

# Calcular tamaño
$tamano = (Get-ChildItem -Path $rutaActual -Recurse -ErrorAction SilentlyContinue | 
    Measure-Object -Property Length -Sum).Sum / 1GB
Write-Host "📊 Tamaño aproximado: $([math]::Round($tamano, 2)) GB" -ForegroundColor Cyan
Write-Host ""

$confirmar = Read-Host "¿Deseas continuar con el movimiento? (S/N)"
if ($confirmar -ne "S" -and $confirmar -ne "s") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🔄 Moviendo Android SDK..." -ForegroundColor Yellow
Write-Host "   Esto puede tardar varios minutos..." -ForegroundColor Gray

try {
    # Crear directorio padre si no existe
    $directorioPadre = Split-Path -Path $rutaNueva -Parent
    if (-not (Test-Path $directorioPadre)) {
        New-Item -ItemType Directory -Path $directorioPadre -Force | Out-Null
    }
    
    # Mover el SDK
    Move-Item -Path $rutaActual -Destination $rutaNueva -Force
    
    Write-Host "✅ Android SDK movido exitosamente" -ForegroundColor Green
    Write-Host ""
    
    # Actualizar variable de entorno ANDROID_HOME
    Write-Host "🔧 Actualizando variables de entorno..." -ForegroundColor Yellow
    
    # Actualizar para la sesión actual
    $env:ANDROID_HOME = $rutaNueva
    $env:ANDROID_SDK_ROOT = $rutaNueva
    
    # Actualizar permanentemente en el usuario
    [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $rutaNueva, "User")
    [System.Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $rutaNueva, "User")
    
    Write-Host "✅ Variables de entorno actualizadas" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Próximos pasos:" -ForegroundColor Cyan
    Write-Host "   1. Cierra y vuelve a abrir tu terminal/IDE" -ForegroundColor White
    Write-Host "   2. Ejecuta: flutter doctor -v" -ForegroundColor White
    Write-Host "   3. Verifica que ya no aparezca el warning de espacios" -ForegroundColor White
    Write-Host "   4. Intenta el build nuevamente: flutter build appbundle --release" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "❌ Error al mover el SDK: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Alternativa: Puedes moverlo manualmente:" -ForegroundColor Yellow
    Write-Host "   1. Cierra Android Studio y todas las aplicaciones que usen el SDK" -ForegroundColor White
    Write-Host "   2. Mueve la carpeta de: $rutaActual" -ForegroundColor White
    Write-Host "   3. A: $rutaNueva" -ForegroundColor White
    Write-Host "   4. Actualiza ANDROID_HOME y ANDROID_SDK_ROOT" -ForegroundColor White
    exit 1
}







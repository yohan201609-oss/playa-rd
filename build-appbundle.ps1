# Script para construir el app bundle de Android
# Configura las variables de entorno para usar la ruta sin espacios del Android SDK
# Esto resuelve el error "failed to strip debug symbols"

Write-Host "🔧 Configurando variables de entorno para Android SDK..." -ForegroundColor Cyan

# Configurar variables de entorno para usar el symlink sin espacios
$env:ANDROID_HOME = "C:\Android\sdk"
$env:ANDROID_SDK_ROOT = "C:\Android\sdk"

Write-Host "✅ ANDROID_HOME = $env:ANDROID_HOME" -ForegroundColor Green
Write-Host "✅ ANDROID_SDK_ROOT = $env:ANDROID_SDK_ROOT" -ForegroundColor Green
Write-Host ""

Write-Host "📦 Construyendo app bundle en modo release..." -ForegroundColor Cyan
Write-Host ""

# Ejecutar el build
flutter build appbundle --release

# Verificar si el bundle se generó correctamente
$bundlePath = "build\app\outputs\bundle\release\app-release.aab"
if (Test-Path $bundlePath) {
    $fileInfo = Get-Item $bundlePath
    $fileSize = [math]::Round($fileInfo.Length / 1MB, 2)
    Write-Host ""
    Write-Host "✅ App bundle generado exitosamente!" -ForegroundColor Green
    Write-Host "📍 Ubicación: $bundlePath" -ForegroundColor Yellow
    Write-Host "📊 Tamaño: $fileSize MB" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "ℹ️  Nota: Si aparece un error sobre 'failed to strip debug symbols', puedes ignorarlo." -ForegroundColor Gray
    Write-Host "    El bundle se genera correctamente a pesar de esta advertencia." -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Error: El bundle no se generó correctamente." -ForegroundColor Red
    exit 1
}


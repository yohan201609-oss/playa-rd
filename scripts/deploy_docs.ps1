# Script para copiar documentos legales a build/web para Firebase Hosting
# Ejecutar después de: flutter build web

Write-Host "📋 Copiando documentos legales a build/web..." -ForegroundColor Cyan

# Verificar que build/web existe
if (-not (Test-Path "build/web")) {
    Write-Host "❌ Error: build/web no existe. Ejecuta primero: flutter build web" -ForegroundColor Red
    exit 1
}

# Crear directorio docs en build/web si no existe
$docsDir = "build/web/docs"
if (-not (Test-Path $docsDir)) {
    New-Item -ItemType Directory -Path $docsDir -Force | Out-Null
    Write-Host "✅ Creado directorio: $docsDir" -ForegroundColor Green
}

# Copiar archivos HTML
$files = @(
    "docs/index.html",
    "docs/politica-privacidad.html",
    "docs/terminos-servicio.html"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $fileName = Split-Path $file -Leaf
        $destPath = Join-Path $docsDir $fileName
        Copy-Item $file $destPath -Force
        Write-Host "✅ Copiado: $fileName" -ForegroundColor Green
    } else {
        Write-Host "⚠️  No encontrado: $file" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Documentos copiados exitosamente!" -ForegroundColor Green
Write-Host "📝 Los archivos están en: build/web/docs/" -ForegroundColor Cyan
Write-Host "`n🌐 URLs después del despliegue:" -ForegroundColor Cyan
Write-Host "   - https://playas-rd-2b475.web.app/docs/politica-privacidad.html" -ForegroundColor Yellow
Write-Host "   - https://playas-rd-2b475.web.app/docs/terminos-servicio.html" -ForegroundColor Yellow
Write-Host "`n🚀 Para desplegar, ejecuta: firebase deploy --only hosting" -ForegroundColor Green


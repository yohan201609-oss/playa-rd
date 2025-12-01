# Script para preparar el proyecto Flutter para transferencia (Google Drive, etc.)
# Excluye archivos innecesarios que ocupan mucho espacio y se regeneran

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Preparando proyecto para transferir" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$proyectoOriginal = Get-Location
$nombreProyecto = Split-Path -Leaf $proyectoOriginal
$carpetaLimpia = "$proyectoOriginal" + "_para_transferir"

# Crear carpeta limpia
if (Test-Path $carpetaLimpia) {
    Write-Host "⚠️  La carpeta $carpetaLimpia ya existe. Eliminándola..." -ForegroundColor Yellow
    Remove-Item -Path $carpetaLimpia -Recurse -Force
}

Write-Host "📁 Creando copia limpia del proyecto..." -ForegroundColor Green
New-Item -ItemType Directory -Path $carpetaLimpia | Out-Null

Write-Host "📋 Copiando archivos (excluyendo builds y cachés)..." -ForegroundColor Green
Write-Host "   Esto puede tardar unos minutos..." -ForegroundColor Gray
Write-Host ""

# Usar robocopy para copiar excluyendo carpetas y archivos innecesarios
robocopy $proyectoOriginal $carpetaLimpia /E /XD `
    build `
    .dart_tool `
    ios\Pods `
    ios\.symlinks `
    android\.gradle `
    android\build `
    android\app\build `
    android\app\debug `
    android\app\profile `
    android\app\release `
    functions\node_modules `
    .git `
    .idea `
    .vscode `
    ios\Flutter\ephemeral `
    ios\Runner.xcworkspace\xcshareddata `
    /XF `
    *.log `
    *.iml `
    .DS_Store `
    Thumbs.db `
    desktop.ini `
    android\local.properties `
    android\key.properties `
    ios\Podfile.lock `
    /NFL /NDL /NP

if ($LASTEXITCODE -le 1) {
    Write-Host ""
    Write-Host "✅ Archivos copiados correctamente" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  Algunos archivos no se copiaron (puede ser normal)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🧹 Eliminando archivos específicos adicionales..." -ForegroundColor Green

# Eliminar archivos .log que puedan haber pasado
Get-ChildItem -Path $carpetaLimpia -Filter "*.log" -Recurse -ErrorAction SilentlyContinue | 
    ForEach-Object { 
        Write-Host "  🗑️  Eliminando: $($_.FullName.Replace($carpetaLimpia, ''))" -ForegroundColor Gray
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue 
    }

# Eliminar archivos .iml
Get-ChildItem -Path $carpetaLimpia -Filter "*.iml" -Recurse -ErrorAction SilentlyContinue | 
    ForEach-Object { 
        Write-Host "  🗑️  Eliminando: $($_.FullName.Replace($carpetaLimpia, ''))" -ForegroundColor Gray
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue 
    }

# Verificar que no queden carpetas de build
$carpetasBuild = @("build", ".dart_tool", "ios\Pods", "android\.gradle")
foreach ($carpeta in $carpetasBuild) {
    $rutaCompleta = Join-Path $carpetaLimpia $carpeta
    if (Test-Path $rutaCompleta) {
        Write-Host "  🗑️  Eliminando carpeta: $carpeta" -ForegroundColor Gray
        Remove-Item -Path $rutaCompleta -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "✅ Limpieza completada!" -ForegroundColor Green
Write-Host ""

# Calcular tamanos
Write-Host "📊 Calculando tamanos..." -ForegroundColor Yellow
$tamanoOriginal = (Get-ChildItem -Path $proyectoOriginal -Recurse -Force -ErrorAction SilentlyContinue | 
    Measure-Object -Property Length -Sum).Sum / 1MB
$tamanoLimpio = (Get-ChildItem -Path $carpetaLimpia -Recurse -Force -ErrorAction SilentlyContinue | 
    Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📊 Resumen de Tamanos:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  📦 Proyecto original: $([math]::Round($tamanoOriginal, 2)) MB" -ForegroundColor White
Write-Host "  ✨ Proyecto limpio:   $([math]::Round($tamanoLimpio, 2)) MB" -ForegroundColor White
Write-Host "  💾 Ahorrado:          $([math]::Round($tamanoOriginal - $tamanoLimpio, 2)) MB" -ForegroundColor Green
Write-Host ""

# Crear archivo README en la carpeta limpia
$readme = @"
# Proyecto Preparado para Transferir

Esta es una versión limpia del proyecto Playas RD Flutter, lista para transferir a Mac.

## 📝 Instrucciones en Mac

1. **Extrae este ZIP** en tu Mac
2. **Renombra** la carpeta a `playas_rd_flutter` (sin el sufijo `_para_transferir`)
3. Abre Terminal y navega al proyecto:
   `cd playas_rd_flutter`

4. Instala dependencias:
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

5. **Sigue la guía completa** en: `GUIA_COMPILAR_MAC.md`

## ⚠️ Notas Importantes

- Los archivos de build se regenerarán en Mac
- Las dependencias de CocoaPods se instalarán automáticamente con `pod install`
- El archivo `.env` NO está incluido (configúralo en Mac si lo necesitas)
- Los certificados de Android NO están incluidos (seguridad)

## 📋 Archivos Verificados

- ✅ Código fuente en `lib/`
- ✅ Configuración iOS en `ios/`
- ✅ Configuración Android en `android/`
- ✅ Dependencias en `pubspec.yaml`
- ✅ Firebase config (GoogleService-Info.plist)

## 📅 Fecha de preparación

$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

Set-Content -Path "$carpetaLimpia/README_TRANSFERENCIA.md" -Value $readme -Encoding UTF8

Write-Host "📝 Archivo README_TRANSFERENCIA.md creado" -ForegroundColor Green
Write-Host ""

# Verificar archivos importantes
Write-Host "🔍 Verificando archivos importantes..." -ForegroundColor Yellow
$archivosImportantes = @(
    "lib\main.dart",
    "pubspec.yaml",
    "ios\Podfile",
    "ios\Runner\GoogleService-Info.plist",
    "android\app\google-services.json"
)

$todosPresentes = $true
foreach ($archivo in $archivosImportantes) {
    $rutaArchivo = Join-Path $carpetaLimpia $archivo
    if (Test-Path $rutaArchivo) {
        Write-Host "  ✅ $archivo" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $archivo (FALTANTE)" -ForegroundColor Red
        $todosPresentes = $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($todosPresentes) {
    Write-Host "✅ ¡Listo para comprimir!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Algunos archivos importantes faltan" -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 Ubicación: $carpetaLimpia" -ForegroundColor Yellow
Write-Host ""

# Preguntar si quiere comprimir
Write-Host "💡 Opciones:" -ForegroundColor Cyan
Write-Host "   1. Comprimir manualmente:" -ForegroundColor White
Write-Host "      Clic derecho en la carpeta y selecciona 'Enviar a' > 'Carpeta comprimida (ZIP)'" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Comprimir con PowerShell (ahora):" -ForegroundColor White
Write-Host "      Se creara: ${nombreProyecto}_para_transferir.zip" -ForegroundColor Gray
Write-Host ""

$comprimir = Read-Host "¿Quieres comprimir ahora? (S/N)"
if ($comprimir -eq "S" -or $comprimir -eq "s" -or $comprimir -eq "Y" -or $comprimir -eq "y") {
    Write-Host ""
    Write-Host "🗜️  Comprimiendo..." -ForegroundColor Green
    $zipPath = "$proyectoOriginal\$nombreProyecto`_para_transferir.zip"
    
    if (Test-Path $zipPath) {
        Write-Host "  ⚠️  El archivo ZIP ya existe. Eliminándolo..." -ForegroundColor Yellow
        Remove-Item $zipPath -Force
    }
    
    Compress-Archive -Path $carpetaLimpia -DestinationPath $zipPath -Force
    
    if (Test-Path $zipPath) {
        $tamanoZip = (Get-Item $zipPath).Length / 1MB
        Write-Host "  ✅ ZIP creado exitosamente" -ForegroundColor Green
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "✅ ¡LISTO PARA SUBIR A GOOGLE DRIVE!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📦 Archivo: $zipPath" -ForegroundColor Yellow
        Write-Host "📊 Tamano del ZIP: $([math]::Round($tamanoZip, 2)) MB" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "🚀 Próximo paso: Sube el ZIP a Google Drive" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host "  ❌ Error al crear el ZIP" -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "📍 Recuerda comprimir la carpeta manualmente antes de subir" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
Write-Host "✨ ¡Proceso completado!" -ForegroundColor Green
Write-Host ""

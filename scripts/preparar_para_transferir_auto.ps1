# Script para preparar el proyecto Flutter para transferencia (version automatica)
# No requiere interaccion del usuario, comprime automaticamente

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Preparando proyecto para transferir" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$proyectoOriginal = Get-Location
$nombreProyecto = Split-Path -Leaf $proyectoOriginal
$carpetaLimpia = "$proyectoOriginal" + "_para_transferir"
$zipPath = "$proyectoOriginal\$nombreProyecto" + "_para_transferir.zip"

# Crear carpeta limpia
if (Test-Path $carpetaLimpia) {
    Write-Host "Eliminando carpeta existente..." -ForegroundColor Yellow
    Remove-Item -Path $carpetaLimpia -Recurse -Force
}

Write-Host "Creando copia limpia del proyecto..." -ForegroundColor Green
New-Item -ItemType Directory -Path $carpetaLimpia | Out-Null

Write-Host "Copiando archivos (esto puede tardar unos minutos)..." -ForegroundColor Green

# Usar robocopy para copiar excluyendo carpetas y archivos innecesarios
robocopy $proyectoOriginal $carpetaLimpia /E /XD build .dart_tool ios\Pods ios\.symlinks android\.gradle android\build android\app\build android\app\debug android\app\profile android\app\release functions\node_modules .git .idea .vscode ios\Flutter\ephemeral ios\Runner.xcworkspace\xcshareddata /XF *.log *.iml .DS_Store Thumbs.db desktop.ini android\local.properties android\key.properties ios\Podfile.lock /NFL /NDL /NP /R:1 /W:1

if ($LASTEXITCODE -le 1) {
    Write-Host "Archivos copiados correctamente" -ForegroundColor Green
}

Write-Host ""
Write-Host "Eliminando archivos adicionales..." -ForegroundColor Green

# Eliminar archivos .log
Get-ChildItem -Path $carpetaLimpia -Filter "*.log" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# Eliminar archivos .iml
Get-ChildItem -Path $carpetaLimpia -Filter "*.iml" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# Verificar que no queden carpetas de build
$carpetasBuild = @("build", ".dart_tool", "ios\Pods", "android\.gradle")
foreach ($carpeta in $carpetasBuild) {
    $rutaCompleta = Join-Path $carpetaLimpia $carpeta
    if (Test-Path $rutaCompleta) {
        Remove-Item -Path $rutaCompleta -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Limpieza completada!" -ForegroundColor Green
Write-Host ""

# Calcular tamanos
Write-Host "Calculando tamanos..." -ForegroundColor Yellow
$tamanoOriginal = (Get-ChildItem -Path $proyectoOriginal -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
$tamanoLimpio = (Get-ChildItem -Path $carpetaLimpia -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resumen de Tamanos:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Proyecto original: $([math]::Round($tamanoOriginal, 2)) MB" -ForegroundColor White
Write-Host "  Proyecto limpio:   $([math]::Round($tamanoLimpio, 2)) MB" -ForegroundColor White
Write-Host "  Ahorrado:          $([math]::Round($tamanoOriginal - $tamanoLimpio, 2)) MB" -ForegroundColor Green
Write-Host ""

# Crear archivo README
$readme = @"
# Proyecto Preparado para Transferir

Esta es una version limpia del proyecto Playas RD Flutter, lista para transferir a Mac.

## Instrucciones en Mac

1. Extrae este ZIP en tu Mac
2. Renombra la carpeta a playas_rd_flutter (sin el sufijo _para_transferir)
3. Abre Terminal y navega al proyecto:
   cd playas_rd_flutter

4. Instala dependencias:
   flutter pub get
   cd ios && pod install && cd ..

5. Sigue la guia completa en: GUIA_COMPILAR_MAC.md

## Notas Importantes

- Los archivos de build se regeneraran en Mac
- Las dependencias de CocoaPods se instalaran automaticamente
- El archivo .env NO esta incluido (configuralo en Mac si lo necesitas)
- Los certificados de Android NO estan incluidos (seguridad)

## Fecha de preparacion

$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

Set-Content -Path "$carpetaLimpia/README_TRANSFERENCIA.md" -Value $readme -Encoding UTF8

Write-Host "Archivo README_TRANSFERENCIA.md creado" -ForegroundColor Green
Write-Host ""

# Verificar archivos importantes
Write-Host "Verificando archivos importantes..." -ForegroundColor Yellow
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
        Write-Host "  OK: $archivo" -ForegroundColor Green
    } else {
        Write-Host "  FALTA: $archivo" -ForegroundColor Red
        $todosPresentes = $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Comprimiendo en ZIP..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Eliminar ZIP anterior si existe
if (Test-Path $zipPath) {
    Write-Host "Eliminando ZIP anterior..." -ForegroundColor Yellow
    Remove-Item $zipPath -Force
}

Write-Host "Comprimiendo (esto puede tardar varios minutos)..." -ForegroundColor Green
Compress-Archive -Path $carpetaLimpia -DestinationPath $zipPath -Force

if (Test-Path $zipPath) {
    $tamanoZip = (Get-Item $zipPath).Length / 1MB
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "LISTO PARA SUBIR A GOOGLE DRIVE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Archivo ZIP: $zipPath" -ForegroundColor Yellow
    Write-Host "Tamano del ZIP: $([math]::Round($tamanoZip, 2)) MB" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Proximo paso: Sube el ZIP a Google Drive" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "Error al crear el ZIP" -ForegroundColor Red
}

Write-Host "Proceso completado!" -ForegroundColor Green
Write-Host ""



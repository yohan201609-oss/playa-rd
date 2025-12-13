# Script para copiar el Android SDK a una ubicación sin espacios
# Esto resuelve permanentemente el problema de rutas con espacios

Write-Host "📦 Copiando Android SDK a ubicación sin espacios..." -ForegroundColor Cyan
Write-Host ""

$sourcePath = "$env:LOCALAPPDATA\Android\sdk"
$destPath = "C:\Android\sdk"

# Verificar que el SDK origen existe
if (-not (Test-Path $sourcePath)) {
    Write-Host "❌ No se encontró el Android SDK en: $sourcePath" -ForegroundColor Red
    exit 1
}

# Verificar espacio disponible
$sourceSize = (Get-ChildItem -Path $sourcePath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
$destDrive = (Get-PSDrive -Name (Split-Path -Qualifier $destPath).TrimEnd(':'))
$freeSpace = $destDrive.Free

Write-Host "📊 Información del SDK:" -ForegroundColor Cyan
Write-Host "   Origen: $sourcePath" -ForegroundColor Gray
Write-Host "   Destino: $destPath" -ForegroundColor Gray
Write-Host "   Tamaño: $([math]::Round($sourceSize / 1GB, 2)) GB" -ForegroundColor Gray
Write-Host "   Espacio disponible: $([math]::Round($freeSpace / 1GB, 2)) GB" -ForegroundColor Gray
Write-Host ""

if ($freeSpace -lt $sourceSize * 1.2) {
    Write-Host "⚠️  Advertencia: Puede que no haya suficiente espacio en disco." -ForegroundColor Yellow
    Write-Host "   Se recomienda tener al menos 20% más de espacio libre." -ForegroundColor Yellow
    Write-Host ""
}

# Preguntar confirmación
$confirm = Read-Host "¿Deseas continuar con la copia? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit 0
}

# Eliminar el symlink si existe
if (Test-Path $destPath) {
    $item = Get-Item $destPath
    if ($item.Attributes -match "ReparsePoint") {
        Write-Host "🗑️  Eliminando symlink existente..." -ForegroundColor Yellow
        Remove-Item $destPath -Force
    } else {
        Write-Host "⚠️  La carpeta $destPath ya existe y no es un symlink." -ForegroundColor Yellow
        Write-Host "   Por favor, elimínala manualmente o elige otra ubicación." -ForegroundColor Yellow
        exit 1
    }
}

# Crear directorio destino
Write-Host "📁 Creando directorio destino..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $destPath -Force | Out-Null

# Copiar el SDK
Write-Host ""
Write-Host "📋 Iniciando copia del SDK..." -ForegroundColor Cyan
Write-Host "   Esto puede tardar varios minutos (aprox. 9.3 GB)..." -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date

# Usar Robocopy para copia más eficiente con progreso
$robocopyArgs = @(
    $sourcePath,
    $destPath,
    "/E",           # Copiar subdirectorios incluyendo vacíos
    "/COPYALL",     # Copiar todos los atributos
    "/R:3",         # Reintentos: 3
    "/W:5",         # Espera entre reintentos: 5 seg
    "/MT:4",        # Usar 4 threads para copia más rápida
    "/NP",          # No mostrar progreso (para evitar spam)
    "/NFL",         # No mostrar lista de archivos
    "/NDL"          # No mostrar lista de directorios
)

$process = Start-Process -FilePath "robocopy" -ArgumentList $robocopyArgs -Wait -PassThru -NoNewWindow

$endTime = Get-Date
$duration = $endTime - $startTime

# Robocopy retorna códigos especiales, 0-7 son exitosos
if ($process.ExitCode -le 7) {
    Write-Host ""
    Write-Host "✅ SDK copiado exitosamente!" -ForegroundColor Green
    Write-Host "   Tiempo transcurrido: $($duration.ToString('mm\:ss'))" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📝 Próximos pasos:" -ForegroundColor Cyan
    Write-Host "   1. Actualizar variables de entorno del sistema:" -ForegroundColor Yellow
    Write-Host "      - ANDROID_HOME = C:\Android\sdk" -ForegroundColor Gray
    Write-Host "      - ANDROID_SDK_ROOT = C:\Android\sdk" -ForegroundColor Gray
    Write-Host "   2. Actualizar android/local.properties (ya está actualizado)" -ForegroundColor Yellow
    Write-Host "   3. Reiniciar terminal/IDE" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Error durante la copia. Código de salida: $($process.ExitCode)" -ForegroundColor Red
    Write-Host "   Puedes intentar copiar manualmente o usar el symlink existente." -ForegroundColor Yellow
    exit 1
}





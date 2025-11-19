# Script para ajustar el inset del icono adaptativo despues de regenerar los iconos
# Este script debe ejecutarse despues de: flutter pub run flutter_launcher_icons

$iconXmlPath = "android\app\src\main\res\mipmap-anydpi-v26\ic_launcher.xml"

if (Test-Path $iconXmlPath) {
    Write-Host "Ajustando el inset del icono adaptativo..." -ForegroundColor Yellow
    
    # Leer el contenido del archivo
    $content = Get-Content $iconXmlPath -Raw
    
    # Ajustar el inset a 5% para que el logo use mas espacio y se ajuste mejor
    # Reemplazar cualquier porcentaje de inset por 5%
    $content = $content -replace 'android:inset="\d+%"', 'android:inset="5%"'
    
    # Guardar el archivo
    Set-Content -Path $iconXmlPath -Value $content -NoNewline
    
    Write-Host "Inset ajustado a 5% para mejor ajuste del logo en $iconXmlPath" -ForegroundColor Green
} else {
    Write-Host "No se encontro el archivo: $iconXmlPath" -ForegroundColor Red
}


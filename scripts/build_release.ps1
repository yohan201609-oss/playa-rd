# Script PowerShell para generar builds de Playas RD
param(
    [switch]$Clean,
    [switch]$Android,
    [switch]$IOS
)

Write-Host "=== Playas RD Build Release Script ==="

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace = Join-Path $projectRoot ".."
Set-Location $workspace

if ($Clean) {
    Write-Host "Limpiando proyecto..."
    flutter clean
}

Write-Host "Instalando dependencias..."
flutter pub get

if (-not ($Android -or $IOS)) {
    $Android = $true
    $IOS = $true
}

if ($Android) {
    Write-Host "[Android] Generando AppBundle release..."
    flutter build appbundle --release
}

if ($IOS) {
    Write-Host "[iOS] Generando IPA release..."
    flutter build ipa --release
}

Write-Host "Builds completados. Revisa las carpetas 'build/app/outputs' (Android) y 'build/ios/ipa' (iOS)."


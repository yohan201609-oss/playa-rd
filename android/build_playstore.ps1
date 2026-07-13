# Compila el .aab para Play Store (soluciona PKIX / antivirus).
# Uso: powershell -ExecutionPolicy Bypass -File android\build_playstore.ps1

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path $PSScriptRoot -Parent
$jdk = "C:\Program Files\Java\jdk-21"
$trustStore = "D:/playas_rd_flutter/android/playas-gradle-truststore"

Write-Host "=== 1/5 Detener Gradle ==="
Set-Location (Join-Path $projectRoot "android")
& .\gradlew.bat --stop 2>&1 | Out-Null
Set-Location $projectRoot

Write-Host "=== 2/5 Truststore SSL ==="
& (Join-Path $PSScriptRoot "fix_gradle_ssl.ps1")

Write-Host ""
Write-Host "=== 3/5 Repositorio Maven local ==="
& (Join-Path $PSScriptRoot "setup_local_maven.ps1")

Write-Host ""
Write-Host "=== 4/5 Variables de entorno ==="
# SDK sin espacios en la ruta (evita fallo al strip de simbolos nativos)
$sdkReal = "$env:LOCALAPPDATA\Android\sdk"
$sdkLink = "D:\Android\sdk"
if (-not (Test-Path $sdkLink)) {
    New-Item -ItemType Junction -Path $sdkLink -Target $sdkReal -Force | Out-Null
    Write-Host "Enlace SDK: $sdkLink -> $sdkReal"
}
$env:ANDROID_HOME = $sdkLink
$env:ANDROID_SDK_ROOT = $sdkLink
$localProps = Join-Path $PSScriptRoot "local.properties"
(Get-Content $localProps) -replace 'sdk\.dir=.*', "sdk.dir=D\:\\Android\\sdk" | Set-Content $localProps

$env:JAVA_HOME = $jdk
$env:GRADLE_OPTS = "-Djavax.net.ssl.trustStore=$trustStore -Djavax.net.ssl.trustStorePassword=changeit"
Write-Host ""
Write-Host "=== 5/5 flutter build appbundle --release ==="
Set-Location $projectRoot
flutter build appbundle --release

$aab = Join-Path $projectRoot "build\app\outputs\bundle\release\app-release.aab"
if (Test-Path $aab) {
    $sizeMb = [math]::Round((Get-Item $aab).Length / 1MB, 1)
    Write-Host ""
    Write-Host "OK: $aab ($sizeMb MB)"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Nota: Flutter aviso 'strip debug symbols' pero el .aab es valido para Play Store."
    }
} else {
    Write-Host ""
    Write-Host "Fallo. Prueba: desactivar inspeccion HTTPS del antivirus y ejecutar de nuevo."
    exit 1
}

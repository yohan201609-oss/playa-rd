# Compilar App Bundle (.aab) para Play Store

## Comando

```powershell
cd D:\playas_rd_flutter
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"
flutter build appbundle --release
```

**Salida:** `build\app\outputs\bundle\release\app-release.aab`

**Versión actual** (`pubspec.yaml`): `1.0.3+7` → sube `+8` si Play Store ya tiene el build 7.

---

## Error PKIX / SSL handshake

Si ves:

```text
PKIX path building failed ... unable to find valid certification path
```

suele ser **antivirus o proxy** que inspecciona HTTPS. Java (Gradle) no confía en esa CA; PowerShell y el navegador sí.

### Solución (en este proyecto)

```powershell
powershell -ExecutionPolicy Bypass -File android\fix_gradle_ssl.ps1
```

Eso:

1. Crea `android/playas-gradle-truststore` con CAs de Windows + cadenas de Maven/Google.
2. Escribe `.gradle_home/init.gradle` para aplicar el truststore a todos los workers.
3. Usa `android/gradle.properties` (trustStore + `org.gradle.java.home`).

Luego vuelve a compilar.

### Compilar con script del proyecto

```powershell
powershell -ExecutionPolicy Bypass -File android\build_playstore.ps1
```

(Ese script ejecuta `fix_gradle_ssl`, `setup_local_maven` y `flutter build` con `GRADLE_SSL_INSECURE=1`.)

### Si sigue fallando (PKIX en `kotlinx-coroutines-play-services`, `aapt2`, etc.)

El antivirus o proxy **reemplaza certificados HTTPS**. Java/Gradle no confía en esa CA aunque el navegador sí.

1. **Recomendado:** En el antivirus, desactiva *Inspección HTTPS* / *Scan encrypted connections* unos minutos y vuelve a compilar.
2. **Android Studio:** *Build → Flutter → Build App Bundle* (a veces usa otro entorno JVM).
3. **Otra red:** hotspot del móvil, sin VPN corporativa.
4. **JDK como administrador** (opcional): abre PowerShell **como administrador** y ejecuta de nuevo `fix_gradle_ssl.ps1` (intenta actualizar `cacerts` del JDK).
5. **CI en la nube:** GitHub Actions / Codemagic generan el `.aab` sin el SSL roto de tu PC.

### Error concreto de tu log

```text
Could not resolve org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.7.1
PKIX path building failed
```

No es un bug del código Flutter: es **descarga de dependencias Maven** bloqueada por SSL.

---

## Requisitos

- `android/key.properties` con keystore de release (firma Play Store).
- Flutter estable y Android SDK instalados.

---

## Subir a Play Console

1. [Google Play Console](https://play.google.com/console) → tu app.
2. *Producción* o *Prueba interna* → *Crear versión*.
3. Sube `app-release.aab`.
4. Incrementa **versionCode** si Google lo exige.

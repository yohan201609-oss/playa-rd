# 📄 Guía: Configuración de app-ads.txt para AdMob

## ✅ Archivo Creado

He creado el archivo `app-ads.txt` en la carpeta `web/` con el contenido correcto para tu cuenta de AdMob:

```
google.com, pub-2612958934827252, DIRECT, f08c47fec0942fa0
```

## 🚀 Pasos para Publicar el Archivo

### 1. Compilar la aplicación web

Primero, compila la aplicación Flutter para web:

```bash
flutter build web
```

Esto copiará automáticamente el archivo `web/app-ads.txt` a `build/web/app-ads.txt`.

### 2. Publicar en Firebase Hosting

Publica tu sitio web en Firebase Hosting:

```bash
firebase deploy --only hosting
```

### 3. Verificar que el archivo esté disponible

Una vez publicado, verifica que el archivo sea accesible en:

- **Dominio principal:** `https://playas-rd-2b475.web.app/app-ads.txt`
- **Dominio alternativo:** `https://playas-rd-2b475.firebaseapp.com/app-ads.txt`

Abre cualquiera de estas URLs en tu navegador y deberías ver el contenido del archivo.

## ⚠️ IMPORTANTE: Dominio en Google Play Console / App Store

**El dominio que uses en Google Play Console o App Store debe coincidir EXACTAMENTE con el dominio donde publiques el archivo.**

Por ejemplo:
- Si usas `playas-rd-2b475.web.app` → el archivo debe estar en `https://playas-rd-2b475.web.app/app-ads.txt`
- Si usas `playas-rd-2b475.firebaseapp.com` → el archivo debe estar en `https://playas-rd-2b475.firebaseapp.com/app-ads.txt`
- Si tienes un dominio personalizado → el archivo debe estar en `https://tudominio.com/app-ads.txt`

## 🔍 Verificación en AdMob / Google Play Console

1. Después de publicar el archivo, espera unos minutos (puede tomar hasta 24 horas)
2. Ve a Google Play Console o AdMob donde estás verificando la aplicación
3. Haz clic en **"Verificar si hay actualizaciones"**
4. El sistema verificará que:
   - El archivo existe en el dominio raíz
   - El formato es correcto
   - La información coincide con tu cuenta de AdMob

## 📋 Contenido del Archivo

El archivo `app-ads.txt` contiene:

- **Publisher ID:** `pub-2612958934827252` (tu ID de AdMob)
- **Certificación:** `f08c47fec0942fa0` (certificación de Google)

## 🛠️ Solución de Problemas

### El archivo no se encuentra

- Verifica que ejecutaste `flutter build web` antes de publicar
- Verifica que el archivo existe en `build/web/app-ads.txt`
- Verifica que publicaste con `firebase deploy --only hosting`

### La verificación falla

- Asegúrate de que el dominio en Google Play Console coincide EXACTAMENTE con el dominio donde está publicado
- Verifica que el archivo sea accesible públicamente (abre la URL en tu navegador)
- Espera hasta 24 horas para que la verificación se complete
- Verifica que el Publisher ID en el archivo coincide con tu cuenta de AdMob

### Error 404 en el archivo

- Asegúrate de que el archivo está en la raíz del sitio (`/app-ads.txt`, no `/ruta/app-ads.txt`)
- Verifica que Firebase Hosting está configurado correctamente
- Revisa que el archivo se copió correctamente a `build/web/app-ads.txt`

## 📝 Notas Adicionales

- El archivo `app-ads.txt` es necesario para verificar tu aplicación en Google Play Console y App Store cuando usas AdMob
- Este archivo ayuda a prevenir fraudes en anuncios
- Debe estar disponible públicamente en el dominio raíz de tu sitio web
- Una vez publicado, el archivo se actualizará automáticamente cada vez que hagas deploy a Firebase Hosting

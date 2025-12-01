# 🔧 Solución: Error Google Sign-In en iOS (GIDClientID)

**Proyecto:** Playas RD Flutter  
**Error:** `No active configuration. Make sure GIDClientID is set in Info.plist.`

---

## 📋 Problema

Al ejecutar la app en iOS, obtienes este error:

```
*** Terminating app due to uncaught exception 'NSInvalidArgumentException', 
reason: 'No active configuration. Make sure GIDClientID is set in Info.plist.'
```

Esto ocurre porque falta la configuración del `GIDClientID` en el archivo `Info.plist` de iOS.

---

## ✅ Solución: Agregar GIDClientID en Xcode

### Método 1: Desde Xcode (Recomendado)

#### Paso 1: Abrir el proyecto correctamente

**⚠️ IMPORTANTE:** Abre el **Workspace**, NO el proyecto:

```bash
cd ios
open Runner.xcworkspace
```

#### Paso 2: Localizar Info.plist

1. En el navegador izquierdo de Xcode, expande la carpeta **Runner**
2. Busca y haz clic en **Info.plist**
3. Verás una tabla con tres columnas: **Key**, **Type**, **Value**

#### Paso 3: Agregar GIDClientID

1. **Busca una clave existente** (por ejemplo, `GADApplicationIdentifier`)
2. **Haz clic derecho** en cualquier parte del editor
3. **Selecciona "Add Row"** (o haz clic en el botón `+` en la esquina superior izquierda de la tabla)
4. **En la columna "Key":**
   - Escribe: `GIDClientID`
5. **En la columna "Type":**
   - Debe ser: `String` (si no lo es, selecciónalo del menú desplegable)
6. **En la columna "Value":**
   - Escribe: `360714035813-j1q7j0elbuep49uurma34kkofh9v27i5.apps.googleusercontent.com`

#### Paso 4: Verificar la ubicación

La clave `GIDClientID` debe estar al mismo nivel que otras claves de configuración como:
- `GADApplicationIdentifier` (AdMob)
- `MBXAccessToken` (Mapbox)
- Etc.

No debe estar dentro de otro diccionario o array.

#### Paso 5: Guardar y limpiar

1. **Guarda el archivo:** `Cmd + S`
2. **Cierra Xcode** completamente
3. **Vuelve a abrir:**
   ```bash
   open ios/Runner.xcworkspace
   ```

#### Paso 6: Limpiar y reconstruir

En Terminal:

```bash
cd ios
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run -d ios
```

---

### Método 2: Verificar que ya está agregado

Si ya se agregó la clave, verifica en Xcode:

1. Abre `Runner.xcworkspace`
2. Selecciona `Info.plist`
3. Busca la clave `GIDClientID` en la lista
4. Verifica que el valor sea: `360714035813-j1q7j0elbuep49uurma34kkofh9v27i5.apps.googleusercontent.com`

Si ya está allí pero el error persiste:

1. **Verifica el formato:**
   - Key: `GIDClientID` (exactamente así, sin espacios)
   - Type: `String`
   - Value: El Client ID completo terminando en `.apps.googleusercontent.com`

2. **Limpia el build:**
   - En Xcode: **Product** > **Clean Build Folder** (Shift + Cmd + K)
   - O desde Terminal: `flutter clean`

3. **Reconstruye:**
   ```bash
   flutter run -d ios
   ```

---

## 🔍 Verificar el Client ID Correcto

Si necesitas verificar cuál es tu Client ID correcto:

### Opción 1: Desde GoogleService-Info.plist

Abre el archivo:
```
ios/Runner/GoogleService-Info.plist
```

Busca la clave `CLIENT_ID`. El valor es el que debes usar en `GIDClientID`.

### Opción 2: Desde Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto: **playas-rd-2b475**
3. Ve a **Project Settings** (⚙️)
4. En la pestaña **General**, busca tu app iOS
5. Busca el campo **OAuth Client ID** o **Client ID**
6. Copia ese valor

---

## ✅ Verificación Final

Después de agregar `GIDClientID`, tu `Info.plist` debe tener:

1. ✅ **GIDClientID** configurado con tu Client ID
2. ✅ **CFBundleURLTypes** con el URL Scheme de Google Sign-In:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.360714035813-j1q7j0elbuep49uurma34kkofh9v27i5</string>
           </array>
       </dict>
   </array>
   ```

---

## 🚀 Ejecutar la App

Después de agregar la configuración:

```bash
# Limpiar
flutter clean

# Obtener dependencias
flutter pub get

# Instalar pods (si es necesario)
cd ios
pod install
cd ..

# Ejecutar en iOS
flutter run -d ios
```

---

## 🆘 Si el Error Persiste

### Verificar que el archivo se guardó

1. Cierra Xcode completamente
2. Abre el archivo en un editor de texto:
   ```bash
   open -a TextEdit ios/Runner/Info.plist
   ```
3. Busca: `<key>GIDClientID</key>`
4. Verifica que el valor esté correcto

### Verificar formato del Client ID

El Client ID debe tener este formato:
```
XXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com
```

### Verificar en GoogleService-Info.plist

Asegúrate de que el `CLIENT_ID` en `GoogleService-Info.plist` coincida con el `GIDClientID` en `Info.plist`.

### Reinstalar pods

```bash
cd ios
rm -rf Pods
rm -rf Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter run -d ios
```

---

## 📝 Nota Importante

- El `GIDClientID` es diferente del `REVERSED_CLIENT_ID`
- El `GIDClientID` es el mismo valor que `CLIENT_ID` en `GoogleService-Info.plist`
- El `REVERSED_CLIENT_ID` se usa en `CFBundleURLSchemes`

---

## ✅ Checklist

- [ ] Abriste `Runner.xcworkspace` (no `.xcodeproj`)
- [ ] Agregaste la clave `GIDClientID` en `Info.plist`
- [ ] El valor es el `CLIENT_ID` de `GoogleService-Info.plist`
- [ ] Limpiaste el build (`flutter clean`)
- [ ] Reconstruiste la app (`flutter run -d ios`)
- [ ] El error desapareció

---

**Última actualización:** Enero 2025


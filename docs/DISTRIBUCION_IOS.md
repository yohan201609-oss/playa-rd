# 📱 Guía de Distribución iOS para Playas RD

## ⚠️ Importante: Diferencias con Android

**En iOS NO puedes compartir aplicaciones como un APK de Android.** Apple requiere que todas las apps se distribuyan a través de canales oficiales con certificados y firmas específicas.

---

## 🎯 Opciones de Distribución iOS

### 1. **TestFlight (Recomendado para Testing/Beta)**

TestFlight es la forma más fácil de compartir tu app iOS con otros usuarios antes de publicarla en el App Store.

#### Requisitos:
- ✅ Cuenta de desarrollador de Apple ($99/año)
- ✅ App Store Connect configurado
- ✅ Certificados y perfiles de aprovisionamiento

#### Ventajas:
- ✅ Gratis (incluido con la cuenta de desarrollador)
- ✅ Hasta **10,000 probadores externos**
- ✅ Distribución por email o enlace público
- ✅ Actualizaciones automáticas
- ✅ Feedback y crash reports

#### Pasos para configurar TestFlight:

##### Paso 1: Preparar el build
```bash
# Compilar la app para iOS
flutter build ipa --release

# El archivo .ipa estará en: build/ios/ipa/
```

##### Paso 2: Subir a App Store Connect
1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Selecciona tu app (o créala si no existe)
3. Ve a "TestFlight" → "iOS Builds"
4. Usa **Xcode** o **Transporter** para subir el `.ipa`:
   - **Opción A (Xcode)**: Abre `ios/Runner.xcworkspace` → Product → Archive → Distribute App → App Store Connect
   - **Opción B (Transporter)**: App gratuita de Apple para subir builds

##### Paso 3: Configurar TestFlight
1. Una vez procesado el build (puede tardar 10-30 min):
   - Ve a TestFlight → "iOS Builds"
   - Selecciona el build
   - Agrega información de prueba (opcional)

2. Agregar probadores:
   - **Probadores Internos**: Hasta 100 usuarios de tu equipo
   - **Probadores Externos**: Hasta 10,000 usuarios
     - Agregar emails individuales
     - O crear un enlace público (máx. 10,000 usuarios)

##### Paso 4: Invitar usuarios
- **Por email**: Los usuarios recibirán un email con instrucciones
- **Enlace público**: Puedes compartir un enlace que cualquiera puede usar (hasta 10,000)

Los usuarios necesitan:
1. Instalar la app **TestFlight** desde el App Store
2. Aceptar la invitación o abrir el enlace público
3. Instalar tu app desde TestFlight

---

### 2. **Distribución Ad-Hoc (Para pruebas limitadas)**

Permite instalar la app directamente en dispositivos específicos sin App Store, pero con limitaciones.

#### Requisitos:
- ✅ Cuenta de desarrollador de Apple ($99/año)
- ✅ UDID de cada dispositivo iOS donde se instalará
- ✅ Perfil de aprovisionamiento Ad-Hoc

#### Limitaciones:
- ⚠️ Máximo **100 dispositivos** por año
- ⚠️ Los UDIDs deben estar registrados en Apple Developer
- ⚠️ Instalación más compleja (requiere iTunes, Finder, o herramientas de terceros)
- ⚠️ Las apps expiran después de 1 año (necesitas recompilar)

#### Pasos para distribución Ad-Hoc:

##### Paso 1: Obtener UDIDs de dispositivos
Los usuarios deben proporcionar su UDID del iPhone:
- **Método 1**: Settings → General → About → encontrar "Identifier" o "UDID"
- **Método 2**: Conectar a Mac → Finder/iTunes mostrará el UDID
- **Método 3**: Usar herramientas como [udid.tech](https://udid.tech)

##### Paso 2: Registrar UDIDs en Apple Developer
1. Ve a [Apple Developer Portal](https://developer.apple.com/account)
2. Certificates, Identifiers & Profiles → Devices
3. Agrega cada UDID (+ botón)

##### Paso 3: Crear Perfil de Aprovisionamiento Ad-Hoc
1. Certificates, Identifiers & Profiles → Profiles
2. Crear nuevo perfil → Ad Hoc
3. Selecciona tu App ID y los dispositivos registrados
4. Descarga el perfil

##### Paso 4: Compilar con perfil Ad-Hoc
```bash
# Compilar con perfil Ad-Hoc
flutter build ipa --release

# Luego en Xcode:
# - Abre ios/Runner.xcworkspace
# - Product → Archive
# - Distribute App → Ad Hoc
```

##### Paso 5: Distribuir el .ipa
- Compartir el archivo `.ipa` con los usuarios
- Los usuarios pueden instalar usando:
  - **Mac**: Finder (conectar iPhone) o Xcode
  - **Windows**: Herramientas como 3uTools o iMazing
  - **Otras**: AltStore, Sideloadly (requieren configuraciones adicionales)

---

### 3. **App Store (Distribución Pública)**

Para distribuir públicamente tu app a todos los usuarios de iOS.

#### Requisitos:
- ✅ Cuenta de desarrollador de Apple ($99/año)
- ✅ Aprobación de Apple (review process)

#### Pasos:
1. Compilar: `flutter build ipa --release`
2. Subir a App Store Connect
3. Completar metadatos (descripción, screenshots, etc.)
4. Enviar para revisión
5. Una vez aprobada, estará disponible públicamente

---

## 📋 Comparación de Opciones

| Característica | TestFlight | Ad-Hoc | App Store |
|----------------|------------|--------|-----------|
| **Facilidad** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Límite usuarios** | 10,000 | 100 | Ilimitado |
| **Actualizaciones** | Automáticas | Manual | Automáticas |
| **Requiere UDID** | ❌ | ✅ | ❌ |
| **Requiere revisión** | ❌ | ❌ | ✅ |
| **Público** | ❌ | ❌ | ✅ |

---

## 🚀 Recomendación

Para compartir tu app con otros usuarios (similar a compartir un APK), usa **TestFlight**:

1. ✅ Es la opción más simple
2. ✅ No requiere UDIDs
3. ✅ Soporta muchos usuarios
4. ✅ Experiencia similar a App Store para los usuarios

---

## 📝 Scripts Útiles

### Compilar para TestFlight/App Store
```bash
flutter build ipa --release
```

### Compilar para Ad-Hoc
```bash
flutter build ipa --release
# Luego configurar el perfil en Xcode
```

### Verificar configuración iOS
```bash
flutter doctor -v
```

---

## 🔗 Enlaces Útiles

- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer Portal](https://developer.apple.com/account)
- [Guía TestFlight](https://developer.apple.com/testflight/)
- [Transporter App](https://apps.apple.com/app/transporter/id1450874784)

---

## ❓ Preguntas Frecuentes

**P: ¿Puedo compartir un .ipa como comparto un .apk?**
R: No directamente. En iOS necesitas certificados y distribución a través de canales oficiales.

**P: ¿La app solo abre con Xcode o con el dispositivo conectado a la Mac?**
R: **NO.** Una vez instalada en el iPhone, la app funciona completamente de forma independiente:
- ✅ La app abre normalmente desde el iPhone, sin Xcode
- ✅ No necesita estar conectada a la Mac
- ✅ Funciona igual que cualquier otra app instalada
- ⚠️ Solo necesitas Xcode/Mac para **COMPILAR e INSTALAR** la app inicialmente
- ⚠️ Para desarrollo en modo debug, la app funciona independientemente una vez instalada (solo necesitas conexión para debug/logs)

**P: ¿TestFlight es gratis?**
R: Sí, está incluido con la cuenta de desarrollador de Apple ($99/año).

**P: ¿Los usuarios necesitan jailbreak?**
R: No, TestFlight y Ad-Hoc funcionan en dispositivos normales.

**P: ¿Cuánto tiempo tarda la revisión de TestFlight?**
R: Generalmente 10-30 minutos para procesar el build. No hay revisión manual para builds de prueba.

**P: ¿Puedo usar TestFlight sin publicar en App Store?**
R: Sí, TestFlight es independiente. Puedes usarlo solo para testing.

---

## 🔄 Desarrollo vs Distribución - ¿Cuándo necesitas qué?

### Durante el Desarrollo:
```
Flutter/Xcode → Compila → Instala en iPhone → ✅ App funciona independientemente
                        ↓
                 No necesita Xcode/Mac para abrir
```

### Tipos de Instalación:

1. **Modo Debug (Desarrollo)**
   - Instalación: Desde Flutter/Xcode
   - Funcionamiento: ✅ Independiente (no necesita Mac conectada)
   - Debug: Solo si quieres ver logs, necesitas conexión USB
   - Expiración: ⚠️ La app puede expirar después de 7 días (depende del perfil)

2. **Modo Release (TestFlight/Ad-Hoc/App Store)**
   - Instalación: TestFlight, Ad-Hoc, o App Store
   - Funcionamiento: ✅ Completamente independiente
   - No necesita: Mac, Xcode, o conexión USB
   - Expiración: Solo Ad-Hoc expira después de 1 año (TestFlight y App Store no expiran)

---

## 📞 Siguiente Paso

Para configurar TestFlight, necesitarás:
1. Crear una cuenta de desarrollador de Apple (si no la tienes)
2. Configurar tu app en App Store Connect
3. Compilar y subir tu primer build

¿Necesitas ayuda con algún paso específico?


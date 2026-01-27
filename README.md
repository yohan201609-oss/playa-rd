# 🏖️ Playas RD

## Descubre las Mejores Playas de República Dominicana

Aplicación completa para descubrir y reportar las mejores playas de República Dominicana 🇩🇴

**Nombre de la aplicación:** Playas RD  
**Versión:** 1.0.1+4  
**Plataformas:** Android, iOS, Web, Windows, macOS, Linux

## 📱 Proyecto Original
- **React Native + Expo**: `C:\PlayaRD`
- **Flutter Version**: `D:\playas_rd_flutter`

## 🎯 Características Implementadas

### Funcionalidades Principales
- [x] Lista de playas (102 playas reales de RD con coordenadas GPS verificadas)
- [x] Mapa interactivo con Google Maps
- [x] Detalles completos de playa con información detallada
- [x] Sistema de reportes en tiempo real con fotos
- [x] Perfil de usuario completo
- [x] Sistema de favoritos sincronizado en la nube
- [x] Sistema de puntos
- [x] Búsqueda y filtros avanzados
- [x] Ratings y reseñas de usuarios
- [x] Clima en tiempo real por playa (OpenWeatherMap)
- [x] Sistema de playas visitadas
- [x] Historial de reportes del usuario

### Autenticación y Usuarios
- [x] Firebase Authentication
- [x] Registro e inicio de sesión con email y contraseña
- [x] Google Sign-In (Android, iOS, Web)
- [x] Apple Sign-In (iOS, macOS)
- [x] Recuperación de contraseña
- [x] Perfiles de usuario con sincronización en la nube
- [x] Favoritos sincronizados automáticamente

### Notificaciones
- [x] Notificaciones push con Firebase Cloud Messaging
- [x] Notificaciones locales
- [x] Configuración de preferencias de notificaciones
- [x] Pantalla de prueba de notificaciones

### Integraciones y Servicios
- [x] Firebase Firestore Database
- [x] Firebase Storage para imágenes
- [x] Firebase Cloud Functions (procesamiento de imágenes, emails de soporte)
- [x] Google Maps API con navegación integrada
- [x] OpenWeatherMap API para datos climáticos
- [x] Google Mobile Ads (AdMob) - Banners, Intersticiales y Recompensados
- [x] Sistema de soporte por email integrado

### UI/UX
- [x] Diseño responsive (adaptable a diferentes tamaños de pantalla)
- [x] Tema claro y oscuro
- [x] Localización completa (Español e Inglés)
- [x] Animaciones y transiciones suaves
- [x] Skeleton loading (shimmer effects)
- [x] Caché de imágenes con `cached_network_image`
- [x] Compartir playas y reportes

### Pantallas y Navegación
- [x] Pantalla de inicio (Home) con lista de playas
- [x] Pantalla de mapa interactivo
- [x] Pantalla de detalles de playa
- [x] Pantalla de reportes
- [x] Pantalla de perfil de usuario
- [x] Pantalla de login/registro
- [x] Pantalla de favoritos
- [x] Pantalla de playas visitadas
- [x] Pantalla de mis reportes
- [x] Pantalla de configuración
- [x] Pantalla de ayuda
- [x] Pantalla de política de privacidad
- [x] Pantalla de términos de servicio
- [x] Pantalla de prueba de notificaciones
- [x] Splash screen con inicialización

## 🚀 Configuración e Instalación

### Requisitos Previos
- Flutter SDK 3.9.2 o superior
- Dart SDK compatible
- Cuenta de Firebase (proyecto: `playas-rd-2b475`)
- API Keys:
  - Google Maps API Key
  - OpenWeatherMap API Key
  - Google Mobile Ads (AdMob) - Opcional para desarrollo

### 1. Instalar dependencias

```bash
cd D:\playas_rd_flutter
flutter pub get
```

### 2. Configurar Variables de Entorno

Crear archivo `.env` en la raíz del proyecto con las siguientes variables:

```env
# Google Maps API Key
GOOGLE_MAPS_API_KEY=tu_api_key_aqui

# OpenWeatherMap API Key
OPENWEATHER_API_KEY=tu_api_key_aqui

# Firebase (ya configurado, pero puedes agregar si es necesario)
FIREBASE_PROJECT_ID=playas-rd-2b475
```

**Nota:** El archivo `.env` está en `.gitignore` por seguridad. No subas tus API keys al repositorio.

### 3. Configurar Google Maps

✅ **Google Maps API Key configurada** en:
- ✅ `.env` como `GOOGLE_MAPS_API_KEY`
- ✅ Android (`android/app/src/main/AndroidManifest.xml`)
- ✅ iOS (`ios/Runner/AppDelegate.swift` o `Info.plist`)
- ✅ Web (`web/index.html`)

**Requisitos de la API Key:**
- Habilitar "Maps SDK for Android"
- Habilitar "Maps SDK for iOS"
- Habilitar "Maps JavaScript API" (para Web)
- Configurar restricciones de aplicación (recomendado para producción)

### 4. Firebase - ¡YA CONFIGURADO! 🔥

**Estado de Firebase:**
- ✅ **Web**: Completamente configurado y listo para usar
- ✅ **Android**: Completamente configurado y listo para usar
- ✅ **iOS**: Completamente configurado y listo para usar
- ✅ **macOS**: Completamente configurado y listo para usar
- ✅ Proyecto: `playas-rd-2b475`

**Para usar (todas las plataformas configuradas):**
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android
flutter build apk
flutter build appbundle

# iOS (requiere Mac)
flutter run -d ios
flutter build ios

# macOS (requiere Mac)
flutter run -d macos
flutter build macos

# Windows
flutter run -d windows
flutter build windows

# Linux
flutter run -d linux
flutter build linux
```

📖 **Ver guía completa:** `FIREBASE_PRODUCCION.md`

**Funcionalidades con Firebase:**
- ✅ Autenticación de usuarios (Email, Google, Apple)
- ✅ Firestore Database (playas, reportes, usuarios)
- ✅ Firebase Storage (imágenes de reportes)
- ✅ Firebase Cloud Messaging (notificaciones push)
- ✅ Firebase App Check (protección contra abuso)
- ✅ Firebase Cloud Functions (procesamiento backend)

### 5. Configurar Firebase Cloud Functions (Opcional)

Las Cloud Functions están en la carpeta `functions/` y proporcionan:
- Procesamiento automático de imágenes (redimensionado)
- Envío de emails de soporte
- Tareas programadas

Para desplegar:
```bash
cd functions
npm install
firebase deploy --only functions
```

### 6. Ejecutar la aplicación

```bash
# Ejecutar en Chrome (Web)
flutter run -d chrome

# Ejecutar en Android
flutter run -d android

# Ejecutar en iOS (requiere Mac)
flutter run -d ios

# Ejecutar en Windows
flutter run -d windows
```

## 📊 Comparación con React Native

| Aspecto | Flutter | React Native + Expo |
|---------|---------|---------------------|
| Lenguaje | Dart | JavaScript |
| Tamaño | ~30 MB | ~70 MB |
| Performance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Hot Reload | ⚡ Muy rápido | ⚡ Rápido |
| Plataformas | 6 (Android, iOS, Web, Windows, macOS, Linux) | 2 (Android, iOS) |

## 🔧 Dependencias principales

```yaml
dependencies:
  # State Management
  provider: ^6.1.2
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.4
  firebase_messaging: ^15.1.3
  firebase_app_check: ^0.3.1+2
  
  # Notificaciones locales
  flutter_local_notifications: ^18.0.1
  
  # Autenticación Social
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.1
  
  # Maps - Google Maps
  google_maps_flutter: ^2.5.3
  
  # Location
  geolocator: ^13.0.1
  geocoding: ^3.0.0
  
  # Image
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
  
  # UI
  flutter_rating_bar: ^4.0.1
  shimmer: ^3.0.0
  
  # Utils
  intl: ^0.20.2
  uuid: ^4.5.1
  share_plus: ^10.1.2
  url_launcher: ^6.3.0
  
  # HTTP y API
  http: ^1.2.0
  flutter_dotenv: ^5.1.0
  
  # Caché local
  shared_preferences: ^2.2.2
  
  # AdMob
  google_mobile_ads: ^5.1.0
```

## 📝 Estructura del proyecto

```
lib/
├── main.dart                      # Entry point de la aplicación
├── models/                        # Modelos de datos
│   ├── beach.dart                 # Beach, BeachReport, AppUser
│   └── weather.dart               # WeatherData, WeatherCondition
├── screens/                       # Pantallas de la aplicación
│   ├── home_screen.dart           # Lista de playas con búsqueda/filtros
│   ├── map_screen.dart            # Mapa interactivo con Google Maps
│   ├── beach_detail_screen.dart   # Detalles completos de playa
│   ├── report_screen.dart         # Formulario de reportes
│   ├── profile_screen.dart         # Perfil de usuario
│   ├── login_screen.dart          # Autenticación (Email, Google, Apple)
│   ├── favorites_screen.dart      # Lista de favoritos
│   ├── visited_beaches_screen.dart # Playas visitadas
│   ├── my_reports_screen.dart     # Mis reportes
│   ├── settings_screen.dart       # Configuración
│   ├── help_screen.dart           # Ayuda y FAQ
│   ├── privacy_policy_screen.dart # Política de privacidad
│   ├── terms_of_service_screen.dart # Términos de servicio
│   ├── test_notifications_screen.dart # Prueba de notificaciones
│   └── splash_screen.dart         # Pantalla de inicio
├── widgets/                       # Componentes reutilizables
│   ├── beach_card.dart            # Card de playa
│   ├── loading_shimmer.dart       # Skeleton loading
│   ├── weather_card.dart          # Card de clima
│   └── app_logo.dart              # Logo de la aplicación
├── providers/                     # State Management (Provider)
│   ├── beach_provider.dart        # Estado de playas
│   ├── auth_provider.dart         # Estado de autenticación
│   ├── weather_provider.dart      # Estado del clima
│   └── settings_provider.dart     # Estado de configuración
├── services/                      # Servicios y lógica de negocio
│   ├── firebase_service.dart      # Operaciones de Firebase
│   ├── beach_service.dart         # 20 playas reales de RD
│   ├── weather_service.dart       # Servicio de clima (OpenWeatherMap)
│   ├── notification_service.dart  # Notificaciones push y locales
│   ├── admob_service.dart         # Gestión de anuncios AdMob
│   ├── app_initializer.dart      # Inicialización de la app
│   ├── navigation_service.dart    # Servicio de navegación
│   ├── preferences_service.dart   # Preferencias locales
│   ├── support_service.dart       # Servicio de soporte
│   ├── google_geocoding_service.dart # Geocodificación
│   ├── google_places_service.dart # Google Places API
│   └── beach_coordinates_updater.dart # Actualizador de coordenadas
├── utils/                         # Utilidades
│   ├── constants.dart             # Colores, constantes, helpers
│   ├── responsive.dart            # Utilidades de responsividad
│   ├── app_assets.dart            # Gestión de assets
│   ├── api_key_verifier.dart      # Verificación de API keys
│   ├── notification_helper.dart   # Helpers de notificaciones
│   └── coordinate_updater_helper.dart # Helpers de coordenadas
├── l10n/                          # Localización (i18n)
│   ├── app_es.arb                 # Traducciones en español
│   ├── app_en.arb                 # Traducciones en inglés
│   ├── app_localizations.dart     # Clase principal de localización
│   ├── app_localizations_es.dart  # Localización español
│   └── app_localizations_en.dart  # Localización inglés
└── scripts/                       # Scripts de utilidad
    └── sync_new_beaches.dart      # Sincronización de nuevas playas

functions/                         # Firebase Cloud Functions
├── index.js                       # Funciones serverless
├── package.json                   # Dependencias de Node.js
└── README.md                      # Documentación de funciones

assets/                            # Recursos estáticos
├── logo.png                       # Logo de la aplicación
├── images/                        # Imágenes de playas
└── icons/                         # Iconos de la aplicación
```

## 🎨 Tema de la app

```dart
primaryColor: Color(0xFF00A9E0)  // Azul océano
secondaryColor: Color(0xFFFFC107)   // Amarillo arena
```

La aplicación soporta:
- **Tema claro**: Fondo gris claro (#F5F5F5)
- **Tema oscuro**: Fondo oscuro (#121212)
- **Material Design 3**: Implementación completa de Material 3

## 🏖️ Base de Datos de Playas (GPS Verificadas)

La app incluye **20 playas reales de República Dominicana** con coordenadas GPS oficiales:

**REGIÓN ESTE - Punta Cana & La Altagracia**
1. **Playa Bávaro** (18.6825°N, 68.4276°W) - UNESCO, 40+ km de costa, Bandera Azul
2. **Playa Macao** (18.7618°N, 68.4356°W) - Playa pública, ideal surf
3. **Playa Juanillo - Cap Cana** (18.4526°N, 68.3856°W) - Exclusiva, golf Jack Nicklaus
4. **Isla Saona - Palmilla** (18.1634°N, 68.7284°W) - Parque Nacional, postal del Caribe
5. **Piscinas Naturales** (18.2145°N, 68.7542°W) - Bancos de arena, estrellas de mar
6. **Playa Arena Gorda** (18.7345°N, 68.4156°W) - Bandera Azul, muy amplia
7. **Uvero Alto** (18.8254°N, 68.4892°W) - Exclusiva, menos concurrida

**REGIÓN NORTE - Península de Samaná**
8. **Playa Rincón** (19.2884°N, 69.2483°W) - Top 10 mundial, 3 km media luna
9. **Playa Frontón** (19.29708°N, 69.15153°W) - Virgen, solo bote o trekking
10. **Playa El Valle** (19.2567°N, 69.3124°W) - Arena dorada, tortugas marinas
11. **Cayo Levantado** (19.1834°N, 69.3567°W) - "Isla Bacardí"

**REGIÓN NORTE - Puerto Plata & Costa Norte**
12. **Playa Dorada** (19.7534°N, 70.6892°W) - 3 km, campo de golf
13. **Playa Sosúa** (19.7512°N, 70.5123°W) - Media luna, arrecifes de coral
14. **Kite Beach Cabarete** (19.7567°N, 70.4156°W) - Capital del kitesurf del Caribe

**REGIÓN NOROESTE - Monte Cristi**
15. **Cayo Arena (Paraíso)** (19.9234°N, 71.2456°W) - Banco de arena flotante
16. **Punta Rucia** (19.8945°N, 71.2134°W) - Manglares, base Cayo Arena

**REGIÓN ESTE - Santo Domingo**
17. **Boca Chica** (18.4534°N, 69.6012°W) - Playa de los capitalinos, 30 km de SD
18. **La Caleta** (18.4312°N, 69.6845°W) - Buceo, pecios submarinos

**REGIÓN SUR**
19. **Bahía de las Águilas** (17.8945°N, 71.6234°W) - Pedernales, 8 km virgen, Parque Jaragua
20. **Playas de Barahona** (18.2134°N, 71.1012°W) - Surf, panoramas espectaculares

## ⭐ Características destacadas

### Sistema de Reportes
- Los usuarios pueden reportar condiciones actuales de playas
- Subir hasta 3 fotos por reporte
- Agregar comentarios y detalles
- Gana 10 puntos por reporte + 5 por foto
- Historial completo de reportes del usuario
- Marcar reportes como útiles (+2 puntos)

### Sistema de Puntos
- Reportar condiciones: +10 puntos
- Subir foto: +5 puntos
- Marcar como útil: +2 puntos
- Visitar playa: +15 puntos

### Clima en Tiempo Real
- Datos climáticos actualizados de OpenWeatherMap
- Información detallada: temperatura, sensación térmica, humedad, viento, índice UV
- Horarios de amanecer y atardecer
- Recomendaciones inteligentes sobre el mejor momento para visitar
- Caché local para reducir llamadas a la API (45 minutos)

### Filtros y Búsqueda Avanzada
- Buscar por nombre, provincia o municipio
- Filtrar por provincia
- Filtrar por condición (Excelente, Bueno, Moderado, Peligroso)
- Ordenar por calificación, nombre o condición
- Filtrar solo favoritos
- Filtrar solo visitadas

### Mapa Interactivo
- Visualiza todas las playas en un mapa de Google Maps
- Markers con código de colores según condición
- Tap en marker para ver información rápida
- Navegación a detalles completos
- Integración con Google Maps y Waze para navegación
- Geolocalización del usuario

### Notificaciones Push
- Notificaciones push con Firebase Cloud Messaging
- Notificaciones locales programadas
- Configuración de preferencias
- Pantalla de prueba de notificaciones
- Sincronización de tokens FCM

### Anuncios AdMob
- Banners publicitarios
- Anuncios intersticiales
- Anuncios recompensados
- Modo de prueba para desarrollo
- IDs de producción configurados

## 🔐 Autenticación

### Métodos de Autenticación
- ✅ Registro con email y contraseña
- ✅ Inicio de sesión con email y contraseña
- ✅ Google Sign-In (Android, iOS, Web)
- ✅ Apple Sign-In (iOS, macOS)
- ✅ Recuperación de contraseña por email
- ✅ Verificación de email (opcional)

### Funcionalidades de Usuario
- Perfiles de usuario completos
- Favoritos sincronizados en la nube
- Historial de reportes
- Playas visitadas
- Sistema de puntos y ranking
- Configuración de preferencias

## 🌍 Localización (i18n)

La aplicación está completamente localizada en:
- **Español** (español dominicano)
- **Inglés** (inglés americano)

La localización incluye:
- Todas las cadenas de texto de la UI
- Mensajes de error y validación
- Formatos de fecha y hora
- Nombres de provincias y regiones

## 🚧 Próximas características

### Funcionalidades Planificadas
- [ ] Modo offline completo con sincronización
- [ ] Sistema de logros y badges
- [ ] Compartir en redes sociales (Facebook, Twitter, Instagram)
- [ ] Rutas y direcciones detalladas a playas
- [ ] Sistema de comentarios en reportes
- [ ] Galería de fotos de usuarios por playa
- [ ] Filtros avanzados (accesibilidad, servicios, actividades)
- [ ] Integración con redes sociales para login (Facebook, Twitter)
- [ ] Widgets para pantalla de inicio
- [ ] Modo de realidad aumentada (AR) para visualizar playas

### Mejoras Técnicas
- [ ] Optimización de rendimiento para listas grandes
- [ ] Implementación de caché más robusto
- [ ] Mejoras en la accesibilidad (a11y)
- [ ] Tests unitarios y de integración
- [ ] Documentación de API interna

---

## 🚀 Guías de Producción

**¿Listo para publicar en Google Play y App Store?**

Se ha realizado un análisis exhaustivo del proyecto y se creó documentación completa para llevarlo a producción:

### 📚 Documentación Disponible

#### ⭐ **NUEVA GUÍA - Configuraciones Faltantes**

1. **[GUIA_CONFIGURACIONES_PRODUCCION.md](GUIA_CONFIGURACIONES_PRODUCCION.md)** ← **⭐ GUÍA COMPLETA PASO A PASO**
   - Guía detallada de todas las configuraciones faltantes
   - 9 secciones completas con instrucciones paso a paso
   - Android: Keystore, firma, ProGuard
   - iOS: Bundle ID, certificados, firma
   - Firebase: Reglas de seguridad actualizadas
   - API Keys: Restricciones y configuración
   - Google Play Console y App Store Connect
   - Checklist final completo

#### 📖 **Otras Guías Disponibles**

3. **[FIREBASE_PRODUCCION.md](FIREBASE_PRODUCCION.md)**
   - Configuración completa de Firebase para producción
   - Reglas de seguridad de Firestore
   - Configuración de Storage
   - App Check y protección

4. **[GUIA_PRODUCCION_ANDROID.md](GUIA_PRODUCCION_ANDROID.md)**
   - Configuración de keystore
   - Firma de aplicaciones
   - ProGuard y ofuscación
   - Google Play Console

5. **[GUIA_PRODUCCION_IOS.md](GUIA_PRODUCCION_IOS.md)**
   - Configuración de certificados
   - App Store Connect
   - Configuración de notificaciones push (APNS)
   - Apple Sign-In

6. **[METADATOS_APP_STORE_IOS.md](METADATOS_APP_STORE_IOS.md)**
   - Textos para App Store Connect
   - Descripciones y screenshots
   - Categorías y palabras clave

### ⏱️ Tiempo Estimado a Producción
- **Publicación rápida:** 2-3 días (16-24 horas)
- **Producción completa:** 5-7 días (36-54 horas)

### 💰 Costos Necesarios
- Google Play: $25 USD (pago único)
- Apple Developer: $99 USD (anual)
- APIs: Gratis (suficiente para empezar)
- **Total año 1: $124 USD**

### 🎯 Primeros Pasos (15 minutos)
1. **Sigue la guía completa:** [GUIA_CONFIGURACIONES_PRODUCCION.md](GUIA_CONFIGURACIONES_PRODUCCION.md)
2. **Empieza por lo crítico:** Sección 1 - Variables de entorno (crear `.env`)
3. **Continúa con Android:** Sección 2 - Configuración de keystore y firma

---

## 📄 Licencia

Este proyecto es privado y está destinado para uso personal/comercial.

---

## 👥 Contribuciones

Este es un proyecto privado. Para sugerencias o reportes de bugs, contacta al equipo de desarrollo.

---

**Hecho con ❤️ para República Dominicana 🇩🇴**

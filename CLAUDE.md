# Playas RD — Flutter App

Aplicación móvil para descubrir y reportar condiciones de playas en República Dominicana.

## Stack

- **Flutter** `^3.9.2`, Material 3
- **State management**: Provider
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging, App Check)
- **Maps**: Google Maps Flutter
- **Auth**: Email/Password, Google Sign-In, Apple Sign-In
- **i18n**: Español (principal) + English — archivos en `lib/l10n/`
- **Ads**: Google Mobile Ads (AdMob)

## Estructura

```
lib/
  main.dart              # Entry point, MultiProvider, temas, nav bar
  models/                # Beach, BeachReport, AppUser
  providers/             # AuthProvider, BeachProvider, WeatherProvider, SettingsProvider
  services/              # Firebase, beach, weather, places, geocoding, notifications, AdMob
  screens/               # home, map, beach_detail, report, profile, favorites, visited, settings…
  widgets/               # beach_card, weather_card, app_logo, loading_shimmer…
  utils/                 # constants (AppColors), responsive, app_assets, migration_utils…
  l10n/                  # AppLocalizations (es + en)
  scripts/               # utilidades de migración / sincronización de datos
```

## Convenciones

- Siempre usar `AppColors` (definido en `lib/utils/constants.dart`) para colores.
- Widgets deben consumir providers con `Consumer<T>` o `Provider.of<T>(context)`.
- Los textos visibles al usuario van en `lib/l10n/` — no hardcodear strings en español/inglés directamente.
- `Beach.getLocalizedDescription(language)` para descripciones bilingües.
- Imágenes/íconos referenciados vía `AppAssets` (`lib/utils/app_assets.dart`).
- `copyWith` disponible en todos los modelos.

## Firebase / Firestore

- Colección principal: `beaches` → documentos `Beach`
- Subcolección de reportes: `beaches/{id}/reports` → `BeachReport`
- Usuarios: `users/{uid}` → `AppUser`
- Coordenadas y condiciones se actualizan con `BeachCoordinatesUpdater` y reportes de usuarios.

## Variables de entorno

Sensibles (API keys) en `.env` (cargado con `flutter_dotenv`). El archivo `.env` está incluido como asset pero **no se versiona**.

## Comandos útiles

```bash
flutter pub get
flutter run
flutter build apk --release
flutter build ios --release
flutter gen-l10n   # regenerar localizaciones
```

## Notas

- `AppInitializer` (`lib/services/app_initializer.dart`) orquesta Firebase init, App Check, notificaciones y AdMob antes de montar el árbol de providers.
- `SettingsProvider` controla idioma y tema; usa `ValueKey` con el idioma para forzar reconstrucción de pantallas al cambiar locale.
- Favoritos se sincronizan entre `AuthProvider` y `BeachProvider` via `ProxyProvider2` en `main.dart`.

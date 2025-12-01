import 'package:flutter/material.dart';

/// Constantes para Assets de la aplicación Playas RD
/// 
/// Este archivo centraliza todas las rutas de assets para:
/// - Evitar errores de tipeo
/// - Facilitar refactorización
/// - Aprovechar auto-completado del IDE
/// - Detectar errores en tiempo de compilación
class AppAssets {
  // Prevenir instanciación
  AppAssets._();

  // ===== LOGOS =====
  
  /// Logo principal con fondo (1024x1024px)
  /// Uso: AppBar, Drawer, pantallas internas
  static const String logo = 'assets/logo.png';

  /// Logo sin fondo - PNG transparente (1024x1024px)
  /// Uso: Superposiciones, compartir, watermarks
  static const String logoTransparent = 'assets/images/logo_transparent.png';

  /// Logo en blanco para fondos oscuros (1024x1024px)
  /// Uso: Splash screen, AppBar con fondo azul
  static const String logoWhite = 'assets/images/logo_white.png';

  /// Logo horizontal para splash screen (2048x512px)
  /// Uso: Splash screen, pantalla de carga
  static const String logoHorizontal = 'assets/images/logo_horizontal.png';

  /// Fondo del splash screen (1242x2688px)
  /// Uso: Pantalla de inicio al abrir la app
  static const String splashBackground = 'assets/images/splash_background.png';

  // ===== ICONOS DE APP =====

  /// Ícono principal de la aplicación (1024x1024px)
  /// Uso: Launcher icon, settings
  static const String appIcon = 'assets/icons/app_icon.png';

  /// Ícono para Android adaptativo (512x512px)
  /// Uso: Android adaptive icon
  static const String appIconAndroid = 'assets/icons/app_icon_android.png';

  /// Ícono para iOS (1024x1024px)
  /// Uso: iOS App Store y home screen
  static const String appIconIOS = 'assets/icons/app_icon_ios.png';

  /// Foreground para Android adaptive icon (1024x1024px)
  /// Uso: Parte frontal del icono adaptativo de Android
  static const String foreground = 'assets/icons/foreground.png';

  /// Background para Android adaptive icon (1024x1024px)
  /// Uso: Parte posterior del icono adaptativo de Android
  static const String background = 'assets/icons/background.png';

  // ===== MÉTODOS DE AYUDA =====

  /// Retorna el logo apropiado según el brillo del tema
  /// 
  /// ```dart
  /// Image.asset(
  ///   AppAssets.getLogoForBrightness(Theme.of(context).brightness),
  /// )
  /// ```
  static String getLogoForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? logoWhite : logo;
  }

  /// Retorna el logo apropiado según el ancho de pantalla
  /// 
  /// Útil para diseño responsive:
  /// - Móvil: Logo cuadrado
  /// - Tablet/Desktop: Logo horizontal
  static String getLogoForWidth(double width) {
    return width < 600 ? logo : logoHorizontal;
  }

  /// Lista de todos los logos para pre-carga
  /// 
  /// Usa esto en el inicio de la app para pre-cargar imágenes críticas:
  /// ```dart
  /// await Future.wait(
  ///   AppAssets.criticalAssets.map(
  ///     (asset) => precacheImage(AssetImage(asset), context)
  ///   )
  /// );
  /// ```
  static const List<String> criticalAssets = [
    logo,
    logoWhite,
  ];

  /// Lista de todos los assets para verificación
  static const List<String> allAssets = [
    // Logos
    logo,
    logoTransparent,
    logoWhite,
    logoHorizontal,
    splashBackground,
    // Iconos
    appIcon,
    appIconAndroid,
    appIconIOS,
    foreground,
    background,
  ];
}


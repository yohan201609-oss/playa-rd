import 'package:flutter/material.dart';

/// Utilidades para diseño responsivo
/// Define breakpoints para diferentes tamaños de pantalla
class ResponsiveBreakpoints {
  // Breakpoints estándar
  static const double mobile = 600; // Teléfonos
  static const double tablet = 900; // Tablets
  static const double desktop = 1200; // Escritorio
  
  /// Determina si la pantalla es móvil
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
  
  /// Determina si la pantalla es tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }
  
  /// Determina si la pantalla es escritorio
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
  
  /// Obtiene el ancho de la pantalla
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// Obtiene la altura de la pantalla
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// Obtiene el padding horizontal según el tamaño de pantalla
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 32.0;
    } else {
      return 48.0;
    }
  }
  
  /// Obtiene el tamaño de fuente según el tamaño de pantalla
  static double fontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? mobile * 1.4;
    }
  }
  
  /// Obtiene el número de columnas para grids según el tamaño de pantalla
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }
  
  /// Obtiene el ancho máximo del contenido según el tamaño de pantalla
  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 800;
    } else {
      return 1200;
    }
  }
}

/// Widget que adapta su contenido según el tamaño de pantalla
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (ResponsiveBreakpoints.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

/// Widget que centra el contenido con un ancho máximo responsivo
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveBreakpoints.maxContentWidth(context);
    final horizontalPadding = ResponsiveBreakpoints.horizontalPadding(context);
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget reutilizable para mostrar el logo de Playas RD
///
/// Este widget usa el logo existente sin modificarlo y proporciona
/// diferentes variantes según el contexto de uso.
class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool useWhiteVersion;
  final VoidCallback? onTap;
  final bool circular; // Hace el logo completamente circular
  final double? borderRadius; // Radio personalizado para bordes redondeados

  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.useWhiteVersion = false,
    this.onTap,
    this.circular = false,
    this.borderRadius,
  });

  /// Logo pequeño para AppBar (40px) con bordes redondeados
  const AppLogo.small({
    super.key,
    this.useWhiteVersion = false,
    this.onTap,
    this.circular = false,
  }) : height = 40,
       width = null,
       fit = BoxFit.cover,
       borderRadius = null;

  /// Logo mediano para headers (80px) con bordes redondeados
  const AppLogo.medium({
    super.key,
    this.useWhiteVersion = false,
    this.onTap,
    this.circular = false,
  }) : height = 80,
       width = null,
       fit = BoxFit.cover,
       borderRadius = null;

  /// Logo grande para splash screen (200px) con bordes redondeados
  const AppLogo.large({
    super.key,
    this.useWhiteVersion = false,
    this.onTap,
    this.circular = false,
  }) : height = 200,
       width = null,
       fit = BoxFit.cover,
       borderRadius = null;

  /// Logo adaptativo según el brillo del tema
  factory AppLogo.adaptive({
    Key? key,
    required BuildContext context,
    double? height,
    double? width,
    VoidCallback? onTap,
    bool circular = false,
  }) {
    final brightness = Theme.of(context).brightness;
    return AppLogo(
      key: key,
      height: height,
      width: width,
      useWhiteVersion: brightness == Brightness.dark,
      onTap: onTap,
      circular: circular,
    );
  }

  /// Logo completamente circular (perfecto para avatares o iconos)
  const AppLogo.circular({
    super.key,
    this.height = 80,
    this.useWhiteVersion = false,
    this.onTap,
  }) : width = null,
       fit = BoxFit.cover,
       circular = true,
       borderRadius = null;

  @override
  Widget build(BuildContext context) {
    // Usar el logo existente desde assets/logo.png
    // NO se modifica, NO se regenera, solo se usa tal como está
    final logoPath = useWhiteVersion && _logoWhiteExists()
        ? AppAssets.logoWhite
        : AppAssets.logo;

    final logoImage = Image.asset(
      logoPath,
      height: height,
      width: width,
      fit: fit,
      // Texto alternativo para accesibilidad
      semanticLabel:
          'Logo de Playas RD - Descubre las mejores playas de República Dominicana',
      // Optimización: cachear la imagen para mejor rendimiento
      cacheHeight: height != null ? (height! * 3).toInt() : null,
      cacheWidth: width != null ? (width! * 3).toInt() : null,
      // Manejo de errores: mostrar placeholder si el logo no se encuentra
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(
              height != null ? height! / 4 : 12,
            ),
          ),
          child: Icon(
            Icons.beach_access,
            size: height != null ? height! * 0.6 : 40,
            color: Colors.white,
          ),
        );
      },
    );

    // Aplicar bordes circulares/redondeados al logo
    // Esto mejora la apariencia sin modificar el archivo original
    Widget logoWidget;

    if (circular) {
      // Logo completamente circular
      final size = height ?? width ?? 80.0;
      logoWidget = ClipOval(
        child: SizedBox(width: size, height: size, child: logoImage),
      );
    } else {
      // Logo con bordes redondeados (suave)
      final radius = borderRadius ?? (height != null ? height! / 4 : 12.0);
      logoWidget = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: logoImage,
      );
    }

    // Si hay callback onTap, hacer el logo clickeable
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: logoWidget);
    }

    return logoWidget;
  }

  /// Verifica si existe la versión blanca del logo
  bool _logoWhiteExists() {
    // Por ahora retornamos false ya que usaremos el logo principal
    // Cuando agregues logo_white.png, esto funcionará automáticamente
    return false;
  }
}

/// Logo con animación de fade in para splash screen
class AnimatedAppLogo extends StatefulWidget {
  final double? height;
  final double? width;
  final Duration duration;

  const AnimatedAppLogo({
    super.key,
    this.height = 200,
    this.width,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AppLogo(height: widget.height, width: widget.width),
      ),
    );
  }
}

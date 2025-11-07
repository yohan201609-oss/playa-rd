import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../utils/constants.dart';

/// Splash Screen con el logo existente de Playas RD
/// 
/// Esta pantalla se muestra al iniciar la aplicación mientras se cargan
/// los datos necesarios (Firebase, playas, etc.)
class SplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const SplashScreen({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Esperar la duración del splash screen
    await Future.delayed(widget.duration);

    // Llamar el callback si existe
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradiente de fondo con los colores de Playas RD
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.secondary.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado - Usando tu logo existente
                AnimatedAppLogo(
                  height: 200,
                  duration: Duration(milliseconds: 1500),
                ),
                const SizedBox(height: 40),
                // Texto de bienvenida
                const Text(
                  'Playas RD',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Descubre las mejores playas de\nRepública Dominicana 🇩🇴',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 60),
                // Indicador de carga
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Versión simple del Splash Screen sin animaciones complejas
class SimpleSplashScreen extends StatelessWidget {
  const SimpleSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo - Usando tu logo existente
            AppLogo.large(),
            const SizedBox(height: 24),
            const Text(
              'Playas RD',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


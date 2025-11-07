import 'package:flutter/material.dart';

// Exportar assets para fácil acceso
export 'app_assets.dart';

// Colores basados en el logo de Playas RD
class AppColors {
  static const Color primary = Color(0xFF00BCD4); // Azul turquesa vibrante (del logo)
  static const Color secondary = Color(0xFFFFB74D); // Amarillo-naranja cálido (del logo)
  static const Color accent = Color(0xFFFFC107); // Amarillo dorado alternativo
  static const Color excellent = Color(0xFF4CAF50); // Verde
  static const Color good = Color(0xFF8BC34A); // Verde claro
  static const Color moderate = Color(0xFFFFC107); // Amarillo
  static const Color danger = Color(0xFFFF5722); // Rojo
  static const Color background = Color(0xFFF5F5F5);
  
  // Gradiente del logo para uso especial
  static const Color gradientTop = Color(0xFF00BCD4); // Azul turquesa
  static const Color gradientBottom = Color(0xFFFFB74D); // Amarillo-naranja
}

// Condiciones de playa
class BeachConditions {
  static const String excellent = 'Excelente';
  static const String good = 'Bueno';
  static const String moderate = 'Moderado';
  static const String danger = 'Peligroso';
  static const String unknown = 'Desconocido';

  static Color getColor(String condition) {
    switch (condition) {
      case excellent:
        return AppColors.excellent;
      case good:
        return AppColors.good;
      case moderate:
        return AppColors.moderate;
      case danger:
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  static IconData getIcon(String condition) {
    switch (condition) {
      case excellent:
        return Icons.check_circle;
      case good:
        return Icons.thumb_up;
      case moderate:
        return Icons.warning;
      case danger:
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }
}

// Provincias de República Dominicana con playas
class DominicanProvinces {
  static const List<String> provinces = [
    'La Altagracia',
    'Puerto Plata',
    'Samaná',
    'María Trinidad Sánchez',
    'La Romana',
    'San Pedro de Macorís',
    'Santo Domingo',
    'Peravia',
    'Azua',
    'Barahona',
    'Pedernales',
    'Montecristi',
  ];
}

// Actividades de playa
class BeachActivities {
  static const String swimming = 'Natación';
  static const String surfing = 'Surf';
  static const String snorkeling = 'Snorkel';
  static const String diving = 'Buceo';
  static const String kayaking = 'Kayak';
  static const String fishing = 'Pesca';
  static const String volleyball = 'Voleibol';
  static const String jetski = 'Moto acuática';

  static IconData getIcon(String activity) {
    switch (activity) {
      case swimming:
        return Icons.pool;
      case surfing:
        return Icons.surfing;
      case snorkeling:
        return Icons.scuba_diving;
      case diving:
        return Icons.scuba_diving;
      case kayaking:
        return Icons.kayaking;
      case fishing:
        return Icons.set_meal;
      case volleyball:
        return Icons.sports_volleyball;
      case jetski:
        return Icons.two_wheeler;
      default:
        return Icons.beach_access;
    }
  }
}

// Puntos del sistema de gamificación
class PointsSystem {
  static const int reportSubmitted = 10;
  static const int photoUploaded = 5;
  static const int helpfulVote = 2;
  static const int beachVisited = 15;
}

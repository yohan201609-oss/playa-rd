import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// Exportar assets para fácil acceso
export 'app_assets.dart';
// Exportar utilidades responsivas
export 'responsive.dart';

// Correo de soporte
class SupportEmail {
  static const String email = 'soporteplayasrd@outlook.com';
}

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
      case unknown:
        return Colors.blue; // Azul para condiciones desconocidas
      default:
        return Colors.blue; // Azul por defecto para condiciones no reconocidas
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

  /// Traduce una condición de playa al idioma actual
  static String getLocalizedCondition(BuildContext context, String condition) {
    final l10n = AppLocalizations.of(context);
    
    // Si no hay localizaciones, retornar el valor original
    if (l10n == null) {
      return condition;
    }
    
    // Normalizar la condición para hacer coincidencias más flexibles
    final normalizedCondition = condition.trim();
    
    // Las constantes excellent, good, etc. ya son 'Excelente', 'Bueno', etc.
    switch (normalizedCondition) {
      case 'Excelente':
        return l10n.conditionExcellent;
      case 'Bueno':
        return l10n.conditionGood;
      case 'Moderado':
        return l10n.conditionModerate;
      case 'Peligroso':
        return l10n.conditionDanger;
      case 'Desconocido':
        return l10n.conditionUnknown;
      default:
        return condition; // Retornar el valor original si no coincide
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

  /// Traduce una actividad de playa al idioma actual
  static String getLocalizedActivity(BuildContext context, String activity) {
    final l10n = AppLocalizations.of(context);
    
    // Si no hay localizaciones, retornar el valor original
    if (l10n == null) {
      return activity;
    }
    
    // Normalizar la actividad para hacer coincidencias más flexibles
    final normalizedActivity = activity.trim();
    
    // Las constantes swimming, surfing, etc. ya son 'Natación', 'Surf', etc.
    switch (normalizedActivity) {
      case 'Natación':
        return l10n.activitySwimming;
      case 'Surf':
        return l10n.activitySurfing;
      case 'Snorkel':
        return l10n.activitySnorkeling;
      case 'Buceo':
        return l10n.activityDiving;
      case 'Kayak':
        return l10n.activityKayaking;
      case 'Pesca':
        return l10n.activityFishing;
      case 'Voleibol':
        return l10n.activityVolleyball;
      case 'Moto acuática':
        return l10n.activityJetski;
      case 'Ecoturismo':
        return l10n.activityEcotourism;
      case 'Fotografía':
        return l10n.activityPhotography;
      case 'Relajación':
        return l10n.activityRelaxation;
      case 'Tranquilidad':
        return l10n.activityTranquility;
      case 'Aventura':
        return l10n.activityAdventure;
      case 'Caminata':
        return l10n.activityHiking;
      case 'Naturaleza':
        return l10n.activityNature;
      case 'Atardecer':
        return l10n.activitySunset;
      case 'Río':
        return l10n.activityRiver;
      case 'Familias':
        return l10n.activityFamilies;
      default:
        // Si no coincide con ninguna actividad conocida, retornar el original
        return activity;
    }
  }
}


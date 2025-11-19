import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Modelo de datos del clima
/// Incluye toda la información meteorológica relevante para playas
class WeatherData {
  final double temperature; // Temperatura en °C
  final double feelsLike; // Sensación térmica en °C
  final String description; // Descripción del clima (ej: "cielo despejado")
  final String mainCondition; // Condición principal (ej: "Clear", "Rain")
  final String icon; // Código del icono de OpenWeatherMap
  final int humidity; // Humedad en %
  final double windSpeed; // Velocidad del viento en m/s
  final int windDirection; // Dirección del viento en grados
  final double? uvIndex; // Índice UV (0-11+)
  final int? rainProbability; // Probabilidad de lluvia en % (si está disponible)
  final double? visibility; // Visibilidad en km
  final int pressure; // Presión atmosférica en hPa
  final int cloudiness; // Nubosidad en %
  final DateTime timestamp; // Momento de la medición
  final DateTime sunrise; // Hora del amanecer
  final DateTime sunset; // Hora del atardecer

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    this.uvIndex,
    this.rainProbability,
    this.visibility,
    required this.pressure,
    required this.cloudiness,
    required this.timestamp,
    required this.sunrise,
    required this.sunset,
  });

  /// Crea un WeatherData desde el JSON de OpenWeatherMap API
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather =
        (json['weather'] as List<dynamic>)[0] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;

    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      description: weather['description'] as String,
      mainCondition: weather['main'] as String,
      icon: weather['icon'] as String,
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      windDirection: (wind['deg'] as num?)?.toInt() ?? 0,
      uvIndex: json['uvi'] != null ? (json['uvi'] as num).toDouble() : null,
      visibility: json['visibility'] != null
          ? (json['visibility'] as num).toDouble() / 1000 // convertir a km
          : null,
      pressure: main['pressure'] as int,
      cloudiness: (json['clouds'] as Map<String, dynamic>)['all'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          (json['dt'] as int) * 1000,
          isUtc: true),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          (sys['sunrise'] as int) * 1000,
          isUtc: true),
      sunset: DateTime.fromMillisecondsSinceEpoch(
          (sys['sunset'] as int) * 1000,
          isUtc: true),
    );
  }

  /// Convierte a JSON para almacenamiento en caché
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'description': description,
      'mainCondition': mainCondition,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'uvIndex': uvIndex,
      'rainProbability': rainProbability,
      'visibility': visibility,
      'pressure': pressure,
      'cloudiness': cloudiness,
      'timestamp': timestamp.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
    };
  }

  /// Crea desde JSON almacenado en caché
  factory WeatherData.fromCache(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      description: json['description'] as String,
      mainCondition: json['mainCondition'] as String,
      icon: json['icon'] as String,
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windDirection: json['windDirection'] as int,
      uvIndex:
          json['uvIndex'] != null ? (json['uvIndex'] as num).toDouble() : null,
      rainProbability: json['rainProbability'] as int?,
      visibility: json['visibility'] != null
          ? (json['visibility'] as num).toDouble()
          : null,
      pressure: json['pressure'] as int,
      cloudiness: json['cloudiness'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sunrise: DateTime.parse(json['sunrise'] as String),
      sunset: DateTime.parse(json['sunset'] as String),
    );
  }

  /// Obtiene la temperatura en Fahrenheit
  double get temperatureF => (temperature * 9 / 5) + 32;

  /// Obtiene la sensación térmica en Fahrenheit
  double get feelsLikeF => (feelsLike * 9 / 5) + 32;

  /// Obtiene la velocidad del viento en km/h
  double get windSpeedKmh => windSpeed * 3.6;

  /// Obtiene la velocidad del viento en mph
  double get windSpeedMph => windSpeed * 2.237;

  /// Retorna el nombre de la dirección del viento (N, NE, E, SE, S, SO, O, NO)
  String get windDirectionName {
    if (windDirection >= 337.5 || windDirection < 22.5) return 'N';
    if (windDirection >= 22.5 && windDirection < 67.5) return 'NE';
    if (windDirection >= 67.5 && windDirection < 112.5) return 'E';
    if (windDirection >= 112.5 && windDirection < 157.5) return 'SE';
    if (windDirection >= 157.5 && windDirection < 202.5) return 'S';
    if (windDirection >= 202.5 && windDirection < 247.5) return 'SO';
    if (windDirection >= 247.5 && windDirection < 292.5) return 'O';
    return 'NO';
  }

  /// Retorna el nivel de UV como texto (Bajo, Moderado, Alto, Muy Alto, Extremo)
  String get uvIndexLevel {
    if (uvIndex == null) return 'Desconocido';
    if (uvIndex! < 3) return 'Bajo';
    if (uvIndex! < 6) return 'Moderado';
    if (uvIndex! < 8) return 'Alto';
    if (uvIndex! < 11) return 'Muy Alto';
    return 'Extremo';
  }

  /// Retorna el color asociado al nivel de UV
  String get uvIndexColor {
    if (uvIndex == null) return '#808080'; // Gris
    if (uvIndex! < 3) return '#289500'; // Verde
    if (uvIndex! < 6) return '#F7E400'; // Amarillo
    if (uvIndex! < 8) return '#F85900'; // Naranja
    if (uvIndex! < 11) return '#D8001D'; // Rojo
    return '#6B49C8'; // Violeta
  }

  /// Determina si es buen clima para ir a la playa
  bool get isGoodBeachWeather {
    // Temperatura entre 24-35°C, sin lluvia, viento moderado
    return temperature >= 24 &&
        temperature <= 35 &&
        !mainCondition.toLowerCase().contains('rain') &&
        !mainCondition.toLowerCase().contains('thunderstorm') &&
        windSpeed < 10;
  }

  /// Retorna una recomendación basada en el clima (traducida)
  String getLocalizedRecommendation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return beachRecommendationFallback;
    }
    
    if (mainCondition.toLowerCase().contains('thunderstorm')) {
      return l10n.weatherRecommendationNotRecommended(l10n.weatherReasonThunderstorm);
    }
    if (mainCondition.toLowerCase().contains('rain')) {
      return l10n.weatherRecommendationNotRecommended(l10n.weatherReasonRain);
    }
    if (windSpeed > 15) {
      return l10n.weatherRecommendationWarning(l10n.weatherReasonStrongWinds);
    }
    if (uvIndex != null && uvIndex! > 8) {
      return l10n.weatherRecommendationCaution(l10n.weatherReasonHighUV);
    }
    if (temperature < 20) {
      return l10n.weatherRecommendationCool;
    }
    if (temperature > 35) {
      return l10n.weatherRecommendationCaution(l10n.weatherReasonHighTemperature);
    }
    return l10n.weatherRecommendationExcellent;
  }

  /// Retorna una recomendación basada en el clima (fallback en español)
  String get beachRecommendationFallback {
    if (mainCondition.toLowerCase().contains('thunderstorm')) {
      return 'No recomendado - Tormenta eléctrica';
    }
    if (mainCondition.toLowerCase().contains('rain')) {
      return 'No recomendado - Lluvia';
    }
    if (windSpeed > 15) {
      return 'Advertencia - Vientos fuertes';
    }
    if (uvIndex != null && uvIndex! > 8) {
      return 'Precaución - Índice UV muy alto';
    }
    if (temperature < 20) {
      return 'Fresco - Puede estar frío para nadar';
    }
    if (temperature > 35) {
      return 'Precaución - Temperatura muy alta';
    }
    return 'Excelente para la playa';
  }

  /// Retorna una recomendación basada en el clima (deprecated - usar getLocalizedRecommendation)
  @Deprecated('Use getLocalizedRecommendation instead')
  String get beachRecommendation => beachRecommendationFallback;

  /// URL del icono del clima
  String getIconUrl({String size = '2x'}) {
    return 'https://openweathermap.org/img/wn/$icon@$size.png';
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

/// Tarjeta compacta de clima para mostrar en lista de playas
class WeatherCompactCard extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherCompactCard({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WeatherCompactCard> createState() => _WeatherCompactCardState();
}

class _WeatherCompactCardState extends State<WeatherCompactCard> {
  String? _lastLanguage;

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeatherProvider, SettingsProvider>(
      builder: (context, weatherProvider, settings, _) {
        final weather = weatherProvider.getWeatherForLocation(widget.latitude, widget.longitude);
        final isLoading = weatherProvider.isLoadingForLocation(widget.latitude, widget.longitude);
        final error = weatherProvider.getErrorForLocation(widget.latitude, widget.longitude);

        // Recargar clima solo cuando cambie el idioma
        if (_lastLanguage != null && _lastLanguage != settings.language) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            weatherProvider.fetchWeatherForBeach(
              latitude: widget.latitude,
              longitude: widget.longitude,
              language: settings.language,
              forceRefresh: true,
            );
          });
        } else if (_lastLanguage == null && weather == null) {
          // Cargar clima la primera vez
          WidgetsBinding.instance.addPostFrameCallback((_) {
            weatherProvider.fetchWeatherForBeach(
              latitude: widget.latitude,
              longitude: widget.longitude,
              language: settings.language,
            );
          });
        }
        _lastLanguage = settings.language;

        if (isLoading) {
          return _buildLoadingCard();
        }

        if (error != null) {
          return _buildErrorCard(error);
        }

        if (weather == null) {
          return _buildLoadingCard();
        }

        return _buildWeatherCard(context, weather);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[400]),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.weatherLoading,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red[400]),
          const SizedBox(width: 6),
          Text(
            error,
            style: TextStyle(fontSize: 11, color: Colors.red[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherData weather) {
    final settings = context.watch<SettingsProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: _getWeatherGradient(weather.mainCondition),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl: weather.getIconUrl(),
            width: 32,
            height: 32,
            errorWidget: (_, __, ___) => const Icon(Icons.wb_sunny, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                settings.formatTemperature(weather.temperature),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                weather.description,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getWeatherGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const LinearGradient(
          colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
        );
      case 'clouds':
        return const LinearGradient(
          colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
        );
      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          colors: [Color(0xFF4B79A1), Color(0xFF283E51)],
        );
      case 'thunderstorm':
        return const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
        );
    }
  }
}

/// Tarjeta detallada de clima para la pantalla de detalles de playa
class WeatherDetailedCard extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherDetailedCard({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WeatherDetailedCard> createState() => _WeatherDetailedCardState();
}

class _WeatherDetailedCardState extends State<WeatherDetailedCard> {
  String? _lastLanguage;

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeatherProvider, SettingsProvider>(
      builder: (context, weatherProvider, settings, _) {
        final weather = weatherProvider.getWeatherForLocation(widget.latitude, widget.longitude);
        final isLoading = weatherProvider.isLoadingForLocation(widget.latitude, widget.longitude);
        final error = weatherProvider.getErrorForLocation(widget.latitude, widget.longitude);

        // Recargar clima solo cuando cambie el idioma
        if (_lastLanguage != null && _lastLanguage != settings.language) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            weatherProvider.fetchWeatherForBeach(
              latitude: widget.latitude,
              longitude: widget.longitude,
              language: settings.language,
              forceRefresh: true,
            );
          });
        } else if (_lastLanguage == null && weather == null) {
          // Cargar clima la primera vez
          WidgetsBinding.instance.addPostFrameCallback((_) {
            weatherProvider.fetchWeatherForBeach(
              latitude: widget.latitude,
              longitude: widget.longitude,
              language: settings.language,
            );
          });
        }
        _lastLanguage = settings.language;

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: weather != null
                  ? _getWeatherGradient(weather.mainCondition)
                  : const LinearGradient(
                      colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
                    ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildContent(context, weather, isLoading, error, weatherProvider),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WeatherData? weather,
    bool isLoading,
    String? error,
    WeatherProvider weatherProvider,
  ) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              error,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                final l10n = AppLocalizations.of(context)!;
                return ElevatedButton.icon(
                  onPressed: () {
                    final settings2 = context.read<SettingsProvider>();
                    weatherProvider.refreshWeather(widget.latitude, widget.longitude, language: settings2.language);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[700],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (weather == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        weatherProvider.fetchWeatherForBeach(
          latitude: widget.latitude,
          longitude: widget.longitude,
          language: settings.language,
        );
      });
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return _buildWeatherDetails(context, weather, weatherProvider);
  }

  Widget _buildWeatherDetails(
    BuildContext context,
    WeatherData weather,
    WeatherProvider weatherProvider,
  ) {
    final timeFormat = DateFormat('HH:mm');
    final settings = context.watch<SettingsProvider>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con icono y temperatura
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<SettingsProvider>(
                      builder: (context, settings, child) {
                        final l10n = AppLocalizations.of(context)!;
                        return Row(
                          children: [
                            const Icon(Icons.wb_sunny, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.weatherCurrent,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: weather.getIconUrl(size: '4x'),
                          width: 80,
                          height: 80,
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.wb_sunny, size: 64, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.formatTemperature(weather.temperature),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Consumer<SettingsProvider>(
                              builder: (context, settings2, child) {
                                final l10n = AppLocalizations.of(context)!;
                                return Text(
                                  l10n.weatherFeelsLike(settings.formatTemperature(weather.feelsLike)),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.description.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  final settings = context.read<SettingsProvider>();
                  weatherProvider.refreshWeather(widget.latitude, widget.longitude, language: settings.language);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recomendación
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  weather.isGoodBeachWeather ? Icons.check_circle : Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weather.getLocalizedRecommendation(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Grid de detalles
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final l10n = AppLocalizations.of(context)!;
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildDetailItem(
                    icon: Icons.water_drop,
                    label: l10n.weatherHumidity,
                    value: '${weather.humidity}%',
                  ),
                  _buildDetailItem(
                    icon: Icons.air,
                    label: l10n.weatherWind,
                    value: '${weather.windSpeedKmh.toStringAsFixed(1)} km/h ${weather.windDirectionName}',
                  ),
                  if (weather.uvIndex != null)
                    _buildDetailItem(
                      icon: Icons.wb_sunny_outlined,
                      label: l10n.weatherUVIndex,
                      value: '${weather.uvIndex!.toStringAsFixed(1)} (${weather.uvIndexLevel})',
                    ),
                  _buildDetailItem(
                    icon: Icons.compress,
                    label: l10n.weatherPressure,
                    value: '${weather.pressure} hPa',
                  ),
                  if (weather.visibility != null)
                    _buildDetailItem(
                      icon: Icons.visibility,
                      label: l10n.weatherVisibility,
                      value: '${weather.visibility!.toStringAsFixed(1)} km',
                    ),
                  _buildDetailItem(
                    icon: Icons.cloud,
                    label: l10n.weatherCloudiness,
                    value: '${weather.cloudiness}%',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Amanecer y atardecer
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final l10n = AppLocalizations.of(context)!;
              return Row(
                children: [
                  Expanded(
                    child: _buildSunItem(
                      icon: Icons.wb_twilight,
                      label: l10n.weatherSunrise,
                      time: timeFormat.format(weather.sunrise.toLocal()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSunItem(
                      icon: Icons.nightlight,
                      label: l10n.weatherSunset,
                      time: timeFormat.format(weather.sunset.toLocal()),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunItem({
    required IconData icon,
    required String label,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getWeatherGradient(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
        );
      case 'clouds':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
        );
      case 'rain':
      case 'drizzle':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4B79A1), Color(0xFF283E51)],
        );
      case 'thunderstorm':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
        );
    }
  }
}


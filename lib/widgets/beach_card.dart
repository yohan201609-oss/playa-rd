import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/beach.dart';
import '../utils/constants.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/beach_provider.dart';
import 'weather_card.dart';

class BeachCard extends StatelessWidget {
  final Beach beach;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool showFavorite;

  const BeachCard({
    super.key,
    required this.beach,
    required this.onTap,
    this.onFavorite,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDark ? 0 : 2,
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            _buildImage(context),
            // Información
            Padding(
              padding: EdgeInsets.all(
                ResponsiveBreakpoints.isMobile(context)
                    ? 16.0
                    : ResponsiveBreakpoints.isTablet(context)
                    ? 20.0
                    : 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  SizedBox(
                    height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12,
                  ),
                  _buildLocation(context),
                  SizedBox(
                    height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12,
                  ),
                  _buildRating(context),
                  SizedBox(
                    height: ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
                  ),
                  // Widget compacto del clima
                  WeatherCompactCard(
                    latitude: beach.latitude,
                    longitude: beach.longitude,
                  ),
                  SizedBox(
                    height: ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
                  ),
                  _buildActivities(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final imageHeight = ResponsiveBreakpoints.isMobile(context)
        ? 200.0
        : ResponsiveBreakpoints.isTablet(context)
        ? 220.0
        : 240.0;

    return Stack(
      children: [
        // Imagen principal
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: beach.imageUrls.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: beach.imageUrls.first,
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;
                    return Container(
                      height: imageHeight,
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorWidget: (context, url, error) {
                    // Si la URL es de Google Places y falló, intentar regenerarla
                    if (url.contains(
                      'maps.googleapis.com/maps/api/place/photo',
                    )) {
                      print('⚠️ URL de imagen expirada o inválida: $url');
                      // Notificar al provider para regenerar las imágenes
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Provider.of<BeachProvider>(
                          context,
                          listen: false,
                        ).regenerateExpiredImageUrls(beach);
                      });
                    }

                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;
                    return Container(
                      height: imageHeight,
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.beach_access,
                          size: ResponsiveBreakpoints.isMobile(context)
                              ? 64
                              : 80,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    );
                  },
                )
              : Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;
                    return Container(
                      height: imageHeight,
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.beach_access,
                          size: ResponsiveBreakpoints.isMobile(context)
                              ? 64
                              : 80,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Badge de condición (solo para usuarios autenticados)
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              return Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: BeachConditions.getColor(beach.currentCondition),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Consumer<SettingsProvider>(
                    builder: (context, settings, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            BeachConditions.getIcon(beach.currentCondition),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            BeachConditions.getLocalizedCondition(
                              context,
                              beach.currentCondition,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }
            // Si no está autenticado, mostrar badge de bloqueo
            return Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Inicia sesión',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Botón de favorito
        if (showFavorite && onFavorite != null)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  beach.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: beach.isFavorite ? Colors.red : Colors.grey[600],
                ),
                onPressed: onFavorite,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      beach.name,
      style: TextStyle(
        fontSize: ResponsiveBreakpoints.fontSize(
          context,
          mobile: 20,
          tablet: 22,
          desktop: 24,
        ),
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildLocation(BuildContext context) {
    final iconSize = ResponsiveBreakpoints.isMobile(context) ? 18.0 : 20.0;
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: iconSize,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        SizedBox(width: ResponsiveBreakpoints.isMobile(context) ? 4 : 6),
        Expanded(
          child: Text(
            '${beach.municipality}, ${beach.province}',
            style: TextStyle(
              fontSize: ResponsiveBreakpoints.fontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRating(BuildContext context) {
    final itemSize = ResponsiveBreakpoints.isMobile(context) ? 20.0 : 24.0;
    final theme = Theme.of(context);
    return Row(
      children: [
        RatingBarIndicator(
          rating: beach.rating,
          itemBuilder: (context, index) =>
              const Icon(Icons.star, color: Color(0xFFFFC107)),
          itemCount: 5,
          itemSize: itemSize,
          direction: Axis.horizontal,
        ),
        SizedBox(width: ResponsiveBreakpoints.isMobile(context) ? 8 : 10),
        Text(
          '${beach.rating.toStringAsFixed(1)} (${beach.reviewCount})',
          style: TextStyle(
            fontSize: ResponsiveBreakpoints.fontSize(
              context,
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActivities(BuildContext context) {
    if (beach.activities.isEmpty) return const SizedBox.shrink();

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: beach.activities.take(3).map((activity) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    BeachActivities.getIcon(activity),
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    BeachActivities.getLocalizedActivity(context, activity),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

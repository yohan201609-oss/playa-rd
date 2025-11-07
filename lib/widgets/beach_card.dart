import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/beach.dart';
import '../utils/constants.dart';
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            _buildImage(),
            // Información
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildLocation(),
                  const SizedBox(height: 8),
                  _buildRating(),
                  const SizedBox(height: 12),
                  // Widget compacto del clima
                  WeatherCompactCard(
                    latitude: beach.latitude,
                    longitude: beach.longitude,
                  ),
                  const SizedBox(height: 12),
                  _buildActivities(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
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
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.beach_access,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.beach_access,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        // Badge de condición
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  BeachConditions.getIcon(beach.currentCondition),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  beach.currentCondition,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildTitle() {
    return Text(
      beach.name,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${beach.municipality}, ${beach.province}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        RatingBarIndicator(
          rating: beach.rating,
          itemBuilder: (context, index) =>
              const Icon(Icons.star, color: Color(0xFFFFC107)),
          itemCount: 5,
          itemSize: 20.0,
          direction: Axis.horizontal,
        ),
        const SizedBox(width: 8),
        Text(
          '${beach.rating.toStringAsFixed(1)} (${beach.reviewCount})',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActivities() {
    if (beach.activities.isEmpty) return const SizedBox.shrink();

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
                activity,
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
  }
}

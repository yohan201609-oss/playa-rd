import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/beach_provider.dart';
import '../providers/auth_provider.dart';
import '../models/beach.dart';
import '../utils/constants.dart';
import '../widgets/weather_card.dart';
import '../services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BeachDetailScreen extends StatelessWidget {
  const BeachDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final beach = context.watch<BeachProvider>().selectedBeach;

    if (beach == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Playa no encontrada')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, beach),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, beach),
                _buildQuickInfo(beach),
                _buildDescription(beach),
                // Widget del clima
                WeatherDetailedCard(
                  latitude: beach.latitude,
                  longitude: beach.longitude,
                ),
                _buildPhotoSection(context, beach),
                _buildAmenities(beach),
                _buildActivities(beach),
                _buildLocation(beach),
                const SizedBox(height: 20),
                _buildActionButtons(context, beach),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Beach beach) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            beach.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: beach.imageUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.beach_access, size: 100),
                  ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            _shareBeach(context, beach);
          },
        ),
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return IconButton(
              icon: Icon(
                beach.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: beach.isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () async {
                if (authProvider.isAuthenticated) {
                  await context.read<BeachProvider>().toggleFavorite(
                    beach,
                    authProvider.user!.uid,
                  );
                  // Recargar datos del usuario para actualizar la lista de favoritos
                  await authProvider.reloadUserData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inicia sesión para guardar favoritos'),
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Beach beach) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            beach.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${beach.municipality}, ${beach.province}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(Beach beach) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: BeachConditions.getIcon(beach.currentCondition),
            label: 'Condición',
            value: beach.currentCondition,
            color: BeachConditions.getColor(beach.currentCondition),
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildInfoItem(
            icon: Icons.star,
            label: 'Calificación',
            value: beach.rating.toStringAsFixed(1),
            color: AppColors.secondary,
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildInfoItem(
            icon: Icons.people,
            label: 'Reseñas',
            value: beach.reviewCount.toString(),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDescription(Beach beach) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descripción',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            beach.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, Beach beach) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fotos de visitantes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickAndUploadPhoto(context, beach),
                icon: const Icon(Icons.add_a_photo, color: Colors.white),
                label: const Text(
                  'Agregar foto',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<String>>(
            future: _fetchBeachPhotos(beach.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error al cargar fotos: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Sé el primero en subir una foto.');
              }
              return SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data![idx],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(
                        width: 90, height: 90, color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (c, u, e) => const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(BuildContext context, Beach beach) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 1000);
    if (picked == null) return;
    final file = File(picked.path);
    final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes iniciar sesión para subir fotos.')));
      return;
    }
    final name = '${DateTime.now().millisecondsSinceEpoch}_${uid}.jpg';
    final ref = FirebaseStorage.instance.ref().child('beach_photos/${beach.id}/$name');
    final upload = await ref.putFile(file);
    final url = await upload.ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('beach_photos').add({
      'beachId': beach.id,
      'url': url,
      'uid': uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Foto subida con éxito!')));
  }

  Future<List<String>> _fetchBeachPhotos(String beachId) async {
    final snaps = await FirebaseFirestore.instance
        .collection('beach_photos')
        .where('beachId', isEqualTo: beachId)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();
    return snaps.docs.map((doc) => doc['url'] as String).toList();
  }

  Widget _buildAmenities(Beach beach) {
    if (beach.amenities.isEmpty) return const SizedBox.shrink();

    final amenityIcons = {
      'baños': Icons.wc,
      'duchas': Icons.shower,
      'parking': Icons.local_parking,
      'restaurantes': Icons.restaurant,
      'sombrillas': Icons.beach_access,
      'salvavidas': Icons.local_hospital,
    };

    final amenityLabels = {
      'baños': 'Baños',
      'duchas': 'Duchas',
      'parking': 'Parking',
      'restaurantes': 'Restaurantes',
      'sombrillas': 'Sombrillas',
      'salvavidas': 'Salvavidas',
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Servicios',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: beach.amenities.entries.map((entry) {
              if (entry.value != true) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      amenityIcons[entry.key] ?? Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amenityLabels[entry.key] ?? entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivities(Beach beach) {
    if (beach.activities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividades',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: beach.activities.map((activity) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      BeachActivities.getIcon(activity),
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation(Beach beach) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ubicación',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, size: 64, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Mapa próximamente',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${beach.latitude.toStringAsFixed(4)}, '
                    'Lng: ${beach.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Beach beach) {
    final authProvider = context.watch<AuthProvider>();
    final appUser = authProvider.appUser;
    final isVisited = appUser?.visitedBeaches.contains(beach.id) ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Botón de marcar como visitada
          if (authProvider.isAuthenticated)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final userId = authProvider.user?.uid;
                    if (userId != null) {
                      if (isVisited) {
                        await FirebaseService.removeVisitedBeach(userId, beach.id);
                      } else {
                        await FirebaseService.addVisitedBeach(userId, beach.id);
                      }
                      await authProvider.reloadUserData();
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  isVisited ? Icons.check_circle : Icons.star,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  isVisited
                                      ? 'Eliminada de visitadas'
                                      : 'Playa marcada como visitada',
                                ),
                              ],
                            ),
                            backgroundColor: isVisited ? Colors.grey[700] : Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    isVisited ? Icons.check_circle : Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  label: Text(
                    isVisited ? 'Ya visitada' : 'Marcar como visitada',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVisited ? Colors.green : AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isVisited ? 2 : 4,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Abrir Google Maps o navegación
                  },
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text(
                    'Cómo llegar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/report', arguments: beach);
                  },
                  icon: const Icon(Icons.report, color: AppColors.primary),
                  label: const Text(
                    'Reportar',
                    style: TextStyle(fontSize: 16, color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Compartir playa con información completa
  void _shareBeach(BuildContext context, Beach beach) {
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${beach.latitude},${beach.longitude}';
    
    final shareText = '''
🏖️ ${beach.name}

📍 ${beach.municipality}, ${beach.province}
⭐ ${beach.rating}/5.0 (${beach.reviewCount} reseñas)
${beach.currentCondition != 'Desconocido' ? '🚦 Condición: ${beach.currentCondition}' : ''}

${beach.description}

📍 Ver en mapa: $googleMapsUrl

---
Descargado desde Playas RD 🇩🇴
Descubre las mejores playas de República Dominicana
    '''.trim();

    Share.share(
      shareText,
      subject: '${beach.name} - Playas RD',
    );
  }
}

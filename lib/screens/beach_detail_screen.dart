import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/beach_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../models/beach.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../widgets/weather_card.dart';
import '../services/firebase_service.dart';
import '../services/google_places_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uuid/uuid.dart';
import 'report_screen.dart';
import '../services/admob_service.dart';
import '../services/navigation_service.dart';

class BeachDetailScreen extends StatefulWidget {
  const BeachDetailScreen({super.key});

  @override
  State<BeachDetailScreen> createState() => _BeachDetailScreenState();
}

class _BeachDetailScreenState extends State<BeachDetailScreen> {
  PageController? _pageController;
  ScrollController? _scrollController;
  int _currentPage = 0;
  List<String> _allPhotos = [];
  String? _currentBeachId;
  bool _isLoadingPhotos = false;
  bool _isHorizontalDragging = false;
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  InterstitialAdHelper? _interstitialAdHelper;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _loadInterstitialAd();
  }

  /// Cargar anuncio intersticial (video) para el botón "Cómo llegar"
  Future<void> _loadInterstitialAd() async {
    _interstitialAdHelper?.dispose();
    _interstitialAdHelper = InterstitialAdHelper(
      useHotelRestaurantTargeting: true,
    );
    await _interstitialAdHelper?.loadInterstitialAd();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _scrollController?.dispose();
    _interstitialAdHelper?.dispose();
    super.dispose();
  }

  Future<void> _loadAllPhotos(Beach beach) async {
    // Evitar cargar si ya estamos cargando o si es la misma playa
    if (_isLoadingPhotos || _currentBeachId == beach.id) {
      return;
    }

    _isLoadingPhotos = true;
    _currentBeachId = beach.id;

    try {
      print('📸 Cargando fotos para playa: ${beach.name} (ID: ${beach.id})');

      // Obtener fotos de usuarios desde Firestore
      final userPhotos = await _fetchAllBeachPhotos(beach.id);
      print('📸 Fotos de usuarios encontradas: ${userPhotos.length}');

      // Combinar fotos de beach.imageUrls con fotos de usuarios
      final allPhotos = <String>[];

      // Primero agregar las fotos de la playa (si existen y son válidas)
      for (final photoUrl in beach.imageUrls) {
        if (_isValidImageUrl(photoUrl)) {
          allPhotos.add(photoUrl);
        } else {
          print('⚠️ Foto original filtrada (no es imagen válida): $photoUrl');
        }
      }
      print(
        '📸 Fotos originales de la playa válidas: ${allPhotos.length} de ${beach.imageUrls.length}',
      );

      // Luego agregar las fotos de usuarios (evitando duplicados y validando URLs)
      for (final photoUrl in userPhotos) {
        if (!allPhotos.contains(photoUrl) && _isValidImageUrl(photoUrl)) {
          allPhotos.add(photoUrl);
        }
      }

      // Si no hay suficientes fotos, intentar obtener de Google Maps
      if (allPhotos.isEmpty || allPhotos.length < 3) {
        print('📸 Pocas fotos encontradas, buscando en Google Maps...');
        try {
          // Primero intentar obtener fotos reales de Places API
          final googlePhotos = await GooglePlacesService.getBeachPhotos(
            beach.name,
            province: beach.province,
            municipality: beach.municipality,
            latitude: beach.latitude,
            longitude: beach.longitude,
            maxPhotos: 5,
          );

          print(
            '📸 Fotos de Google Places encontradas: ${googlePhotos.length}',
          );

          // Agregar fotos de Google Places (evitando duplicados)
          for (final photoUrl in googlePhotos) {
            if (!allPhotos.contains(photoUrl) && _isValidImageUrl(photoUrl)) {
              allPhotos.add(photoUrl);
            }
          }

          // Si aún no hay fotos, generar imagen estática del mapa
          if (allPhotos.isEmpty) {
            print('📸 Generando imagen estática del mapa...');
            final staticMapUrl = GooglePlacesService.generateStaticMapImageUrl(
              latitude: beach.latitude,
              longitude: beach.longitude,
              beachName: beach.name,
              width: 800,
              height: 600,
              zoom: 15,
              mapType:
                  'satellite', // Usar vista satelital para mostrar la playa
            );

            if (staticMapUrl.isNotEmpty) {
              allPhotos.add(staticMapUrl);
              print('✅ Imagen estática del mapa generada');
            }
          }
        } catch (e) {
          print('⚠️ Error al obtener fotos de Google Maps: $e');

          // En caso de error, intentar generar imagen estática del mapa como fallback
          if (allPhotos.isEmpty) {
            try {
              final staticMapUrl =
                  GooglePlacesService.generateStaticMapImageUrl(
                    latitude: beach.latitude,
                    longitude: beach.longitude,
                    beachName: beach.name,
                    width: 800,
                    height: 600,
                    zoom: 15,
                    mapType: 'satellite',
                  );

              if (staticMapUrl.isNotEmpty) {
                allPhotos.add(staticMapUrl);
                print('✅ Imagen estática del mapa generada (fallback)');
              }
            } catch (e2) {
              print('❌ Error al generar imagen estática: $e2');
            }
          }
        }
      }

      print('📸 Total de fotos combinadas: ${allPhotos.length}');

      if (mounted && _currentBeachId == beach.id) {
        setState(() {
          _allPhotos = allPhotos;
          _currentPage = 0; // Resetear a la primera página
          if (_pageController != null && allPhotos.isNotEmpty) {
            _pageController!.jumpToPage(0);
          }
        });
      }
    } catch (e) {
      print('❌ Error al cargar fotos para ${beach.name}: $e');
      // En caso de error, al menos mostrar las fotos originales de la playa
      if (mounted && _currentBeachId == beach.id) {
        setState(() {
          _allPhotos = beach.imageUrls;
        });
      }
    } finally {
      if (mounted) {
        _isLoadingPhotos = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final beach = context.watch<BeachProvider>().selectedBeach;
    context.watch<SettingsProvider>(); // Escuchar cambios de idioma

    if (beach == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Playa no encontrada')),
      );
    }

    // Cargar todas las fotos cuando cambie la playa o si aún no se han cargado
    if (_currentBeachId != beach.id || _allPhotos.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentBeachId != beach.id) {
          _loadAllPhotos(beach);
        }
      });
    }

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Permitir que el PageView maneje gestos horizontales
          // Bloquear el scroll vertical solo cuando se está deslizando horizontalmente
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: _isHorizontalDragging
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
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
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Beach beach) {
    // Combinar fotos cargadas con fotos originales de la playa
    final photosToShow = <String>[];
    if (_allPhotos.isNotEmpty) {
      photosToShow.addAll(_allPhotos);
    } else {
      // Mientras se cargan, usar las fotos originales si existen
      photosToShow.addAll(beach.imageUrls);
    }

    // Solo mostrar el ícono si realmente NO hay fotos
    final hasPhotos = photosToShow.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: hasPhotos
            ? Listener(
                onPointerDown: (event) {
                  _lastTapTime = DateTime.now();
                  _lastTapPosition = event.position;
                },
                onPointerMove: (event) {
                  // Si hay movimiento, actualizar posición
                  if (_lastTapPosition != null) {
                    final distance =
                        (event.position - _lastTapPosition!).distance;
                    if (distance > 10) {
                      // Hay movimiento significativo, no es un toque simple
                      _lastTapPosition = null;
                      _lastTapTime = null;
                    }
                  }
                },
                onPointerUp: (event) {
                  if (_lastTapTime != null && _lastTapPosition != null) {
                    final now = DateTime.now();
                    final duration = now.difference(_lastTapTime!);
                    final distance =
                        (event.position - _lastTapPosition!).distance;

                    // Si fue un toque rápido (menos de 300ms) y no hubo movimiento significativo
                    if (duration.inMilliseconds < 300 && distance < 15) {
                      // Es un toque simple, abrir visor
                      _showImageViewer(context, photosToShow, _currentPage);
                    }
                  }
                  _lastTapTime = null;
                  _lastTapPosition = null;
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: const PageScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: photosToShow.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: photosToShow[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print('❌ Error al cargar imagen: $url - $error');
                            // Si la URL es de Google Places y falló, intentar regenerarla
                            if (url.contains(
                              'maps.googleapis.com/maps/api/place/photo',
                            )) {
                              print(
                                '⚠️ URL de imagen expirada o inválida: $url',
                              );
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final beachProvider =
                                    Provider.of<BeachProvider>(
                                      context,
                                      listen: false,
                                    );
                                if (beachProvider.selectedBeach != null) {
                                  beachProvider.regenerateExpiredImageUrls(
                                    beachProvider.selectedBeach!,
                                  );
                                }
                              });
                            }
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                          // Configuraciones adicionales para mejorar la carga
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 100),
                          memCacheWidth: 800, // Optimizar memoria
                          memCacheHeight: 600,
                        );
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Indicadores de página (solo si hay más de una foto)
                    if (photosToShow.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            photosToShow.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.beach_access,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
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
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final padding = ResponsiveBreakpoints.horizontalPadding(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (authProvider.isAuthenticated) ...[
            ElevatedButton.icon(
              onPressed: () => _pickAndUploadPhoto(context, beach),
              icon: Icon(
                Icons.add_a_photo,
                color: Colors.white,
                size: ResponsiveBreakpoints.isMobile(context) ? 18 : 20,
              ),
              label: Text(
                l10n.reportAddPhotos,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveBreakpoints.fontSize(
                    context,
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
                  vertical: ResponsiveBreakpoints.isMobile(context) ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 12 : 16),
          ],
          Text(
            beach.name,
            style: TextStyle(
              fontSize: ResponsiveBreakpoints.fontSize(
                context,
                mobile: 28,
                tablet: 32,
                desktop: 36,
              ),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: ResponsiveBreakpoints.isMobile(context) ? 20 : 24,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              SizedBox(width: ResponsiveBreakpoints.isMobile(context) ? 4 : 6),
              Expanded(
                child: Text(
                  '${beach.municipality}, ${beach.province}',
                  style: TextStyle(
                    fontSize: ResponsiveBreakpoints.fontSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(Beach beach) {
    final authProvider = context.watch<AuthProvider>();
    final padding = ResponsiveBreakpoints.horizontalPadding(context);

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: padding),
          padding: EdgeInsets.all(
            ResponsiveBreakpoints.isMobile(context) ? 16 : 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Mostrar condición solo si el usuario está autenticado
              if (authProvider.isAuthenticated) ...[
                _buildInfoItem(
                  icon: BeachConditions.getIcon(beach.currentCondition),
                  label: l10n.beachCondition,
                  value: BeachConditions.getLocalizedCondition(
                    context,
                    beach.currentCondition,
                  ),
                  color: BeachConditions.getColor(beach.currentCondition),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
              ] else ...[
                // Si no está autenticado, mostrar mensaje de bloqueo
                _buildInfoItem(
                  icon: Icons.lock_outline,
                  label: l10n.beachCondition,
                  value: 'Inicia sesión',
                  color: Colors.grey[600]!,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
              ],
              _buildInfoItem(
                icon: Icons.star,
                label: l10n.homeSortRating,
                value: beach.rating.toStringAsFixed(1),
                color: AppColors.secondary,
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildInfoItem(
                icon: Icons.people,
                label: l10n.beachReports,
                value: beach.reviewCount.toString(),
                color: AppColors.primary,
              ),
            ],
          ),
        );
      },
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Beach beach) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final l10n = AppLocalizations.of(context)!;
        final padding = ResponsiveBreakpoints.horizontalPadding(context);
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.beachDescription,
                style: TextStyle(
                  fontSize: ResponsiveBreakpoints.fontSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(
                height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12,
              ),
              Text(
                beach.getLocalizedDescription(settings.language),
                style: TextStyle(
                  fontSize: ResponsiveBreakpoints.fontSize(
                    context,
                    mobile: 16,
                    tablet: 17,
                    desktop: 18,
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoSection(BuildContext context, Beach beach) {
    final authProvider = context.watch<AuthProvider>();

    // Si el usuario no está autenticado, mostrar mensaje para iniciar sesión
    if (!authProvider.isAuthenticated) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.lock_outline, size: 48, color: Colors.blue[700]),
              const SizedBox(height: 12),
              Text(
                'Inicia sesión para ver comentarios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Los comentarios y experiencias de otros usuarios están disponibles solo para usuarios registrados.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comentarios',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              StreamBuilder<List<BeachReport>>(
                stream: FirebaseService.getBeachReports(beach.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final reports = snapshot.data ?? [];
                    final reportsWithComments = reports
                        .where(
                          (report) =>
                              report.comment != null &&
                              report.comment!.trim().isNotEmpty,
                        )
                        .toList();

                    if (reportsWithComments.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${reportsWithComments.length} ${reportsWithComments.length == 1 ? 'usuario' : 'usuarios'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '¡Comparte tu experiencia! Tu comentario ayuda a otros usuarios a conocer mejor esta playa.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<BeachReport>>(
            stream: FirebaseService.getBeachReports(beach.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error al cargar comentarios: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }

              final reports = snapshot.data ?? [];
              // Filtrar solo reportes con comentarios
              final reportsWithComments = reports
                  .where(
                    (report) =>
                        report.comment != null &&
                        report.comment!.trim().isNotEmpty,
                  )
                  .toList();

              if (reportsWithComments.isEmpty) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;

                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aún no hay comentarios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sé el primero en compartir tu experiencia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.isAuthenticated) {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReportScreen(initialBeach: beach),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Escribir comentario'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: reportsWithComments.length,
                  itemBuilder: (context, index) {
                    final report = reportsWithComments[index];
                    return _buildCommentCard(report);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(BeachReport report) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  report.userName.isNotEmpty
                      ? report.userName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (report.rating != null && report.rating! > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < report.rating!.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: AppColors.secondary,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            report.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BeachConditions.getColor(
                    report.condition,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.condition,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: BeachConditions.getColor(report.condition),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              report.comment ?? '',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(report.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Hace unos momentos';
        }
        return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      }
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _pickAndUploadPhoto(BuildContext context, Beach beach) async {
    final l10n = AppLocalizations.of(context)!;

    // Mostrar diálogo para elegir entre cámara o galería
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.reportAddPhotos),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: 32,
                ),
                title: Text(l10n.reportTakePhoto),
                subtitle: const Text('Tomar una foto con la cámara'),
                onTap: () {
                  Navigator.of(dialogContext).pop(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                  size: 32,
                ),
                title: Text(l10n.reportSelectFromGallery),
                subtitle: const Text('Seleccionar una foto de la galería'),
                onTap: () {
                  Navigator.of(dialogContext).pop(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1000,
    );

    if (picked == null) return;

    final file = File(picked.path);
    final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para subir fotos.')),
      );
      return;
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final name = '${DateTime.now().millisecondsSinceEpoch}_${uid}.jpg';
      final ref = FirebaseStorage.instance.ref().child(
        'beach_photos/${beach.id}/$name',
      );
      final upload = await ref.putFile(file);
      final url = await upload.ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('beach_photos').add({
        'beachId': beach.id,
        'url': url,
        'uid': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Recargar todas las fotos para actualizar el carrusel
      _currentBeachId = null; // Forzar recarga
      await _loadAllPhotos(beach);

      // Cerrar indicador de carga
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Foto subida con éxito!')),
        );
      }
    } catch (e) {
      // Cerrar indicador de carga en caso de error
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir la foto: $e')));
      }
    }
  }

  // Validar que una URL sea realmente una imagen
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    // Filtrar URLs que no son imágenes (enlaces de Google Maps, etc.)
    final invalidPatterns = [
      'maps.app.goo.gl',
      'google.com/maps',
      'goo.gl/maps',
      'maps.google.com',
    ];

    for (final pattern in invalidPatterns) {
      if (url.contains(pattern)) {
        print('⚠️ URL filtrada (no es imagen): $url');
        return false;
      }
    }

    // Verificar que la URL tenga una extensión de imagen válida
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final lowerUrl = url.toLowerCase();

    // Si tiene extensión, verificar que sea de imagen
    if (imageExtensions.any((ext) => lowerUrl.contains(ext))) {
      return true;
    }

    // Si no tiene extensión pero es de Firebase Storage o HTTPS, asumir que es imagen
    if (url.contains('firebasestorage.googleapis.com') ||
        url.startsWith('https://') ||
        url.startsWith('http://')) {
      return true;
    }

    return false;
  }

  Future<List<String>> _fetchAllBeachPhotos(String beachId) async {
    try {
      // Intentar con orderBy primero (requiere índice)
      final snaps = await FirebaseFirestore.instance
          .collection('beach_photos')
          .where('beachId', isEqualTo: beachId)
          .orderBy('timestamp', descending: true)
          .get();
      return snaps.docs.map((doc) => doc['url'] as String).toList();
    } catch (e) {
      // Si falla por falta de índice, intentar sin orderBy
      print('Error al obtener fotos con orderBy: $e');
      try {
        final snaps = await FirebaseFirestore.instance
            .collection('beach_photos')
            .where('beachId', isEqualTo: beachId)
            .get();
        // Ordenar manualmente por timestamp si está disponible
        final photosWithTimestamp = snaps.docs.map((doc) {
          final data = doc.data();
          return {
            'url': data['url'] as String,
            'timestamp': data['timestamp'] as Timestamp?,
          };
        }).toList();

        photosWithTimestamp.sort((a, b) {
          if (a['timestamp'] == null && b['timestamp'] == null) return 0;
          if (a['timestamp'] == null) return 1;
          if (b['timestamp'] == null) return -1;
          return (b['timestamp'] as Timestamp).compareTo(
            a['timestamp'] as Timestamp,
          );
        });

        return photosWithTimestamp.map((p) => p['url'] as String).toList();
      } catch (e2) {
        print('Error al obtener fotos sin orderBy: $e2');
        return [];
      }
    }
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

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.beachAmenities,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
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
      },
    );
  }

  Widget _buildActivities(Beach beach) {
    if (beach.activities.isEmpty) return const SizedBox.shrink();

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.beachActivities,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
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
                          BeachActivities.getLocalizedActivity(
                            context,
                            activity,
                          ),
                          style: TextStyle(
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
      },
    );
  }

  Widget _buildLocation(Beach beach) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.beachLocation,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openDirections(context, beach),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(
                      l10n.beachGetDirections,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(beach.latitude, beach.longitude),
                          zoom: 14.0,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(beach.id),
                            position: LatLng(beach.latitude, beach.longitude),
                            infoWindow: InfoWindow(
                              title: beach.name,
                              snippet:
                                  '${beach.municipality}, ${beach.province}',
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              _getMarkerHue(beach.currentCondition),
                            ),
                          ),
                        },
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        onTap: (LatLng position) =>
                            _openDirections(context, beach),
                      ),
                      // Botón flotante para abrir en Google Maps
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          onPressed: () => _openDirections(context, beach),
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.open_in_new,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Información de coordenadas
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${beach.municipality}, ${beach.province}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              if (beach.address != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.home,
                                      size: 14,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        beach.address!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (beach.postalCode != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  beach.postalCode!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                'Lat: ${beach.latitude.toStringAsFixed(6)}, '
                                'Lng: ${beach.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  double _getMarkerHue(String condition) {
    switch (condition) {
      case 'Excelente':
        return BitmapDescriptor.hueGreen;
      case 'Bueno':
        return BitmapDescriptor.hueYellow;
      case 'Moderado':
        return BitmapDescriptor.hueOrange;
      case 'Peligroso':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  Widget _buildActionButtons(BuildContext context, Beach beach) {
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final appUser = authProvider.appUser;
    final isVisited = appUser?.visitedBeaches.contains(beach.id) ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                        await FirebaseService.removeVisitedBeach(
                          userId,
                          beach.id,
                        );
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
                            backgroundColor: isVisited
                                ? Colors.grey[700]
                                : Colors.green,
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
                    isVisited
                        ? l10n.beachAlreadyVisited
                        : l10n.beachMarkAsVisited,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVisited
                        ? Colors.green
                        : AppColors.secondary,
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
                  onPressed: () => _openDirections(context, beach),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: Text(
                    l10n.beachGetDirections,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: authProvider.isAuthenticated
                      ? () => _showRatingDialog(context, beach, authProvider)
                      : null,
                  icon: const Icon(Icons.star, color: Colors.white),
                  label: Text(
                    'Calificar',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportScreen(initialBeach: beach),
                      ),
                    );
                  },
                  icon: const Icon(Icons.report, color: AppColors.primary),
                  label: Text(
                    l10n.navReport,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
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

  /// Muestra un diálogo para seleccionar la aplicación de navegación (Google Maps o Waze)
  Future<void> _showNavigationDialog(BuildContext context, Beach beach) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    // No verificamos si Waze está instalado antes de mostrar el diálogo
    // porque canLaunchUrl puede fallar en Android incluso si Waze está instalado.
    // En su lugar, intentaremos abrir Waze directamente cuando el usuario lo seleccione.

    // Mostrar diálogo de selección
    final selectedApp = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.beachNavigateWith),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opción Google Maps
              ListTile(
                leading: const Icon(Icons.map, color: Colors.blue),
                title: Text(l10n.beachNavigateGoogleMaps),
                onTap: () => Navigator.of(dialogContext).pop('google_maps'),
              ),
              // Opción Waze - siempre disponible
              // Intentaremos abrir Waze directamente, y si falla, ofreceremos instalar
              ListTile(
                leading: const Icon(Icons.navigation, color: Colors.blue),
                title: Text(l10n.beachNavigateWaze),
                onTap: () => Navigator.of(dialogContext).pop('waze'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    // Si el usuario seleccionó una opción, abrir la navegación
    if (selectedApp != null && mounted) {
      await _openDirections(context, beach, selectedApp);
    }
  }

  Future<void> _openDirections(
    BuildContext context,
    Beach beach, [
    String? navigationApp,
  ]) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    // Si no se especificó la app, mostrar diálogo de selección
    if (navigationApp == null) {
      await _showNavigationDialog(context, beach);
      return;
    }

    // Función para abrir direcciones según la app seleccionada
    Future<void> openDirections() async {
      final placeName = NavigationService.getFullPlaceName(
        name: beach.name,
        municipality: beach.municipality,
        province: beach.province,
      );

      bool success = false;

      if (navigationApp == 'waze') {
        // Intentar abrir Waze
        success = await NavigationService.openWazeWithFallback(
          latitude: beach.latitude,
          longitude: beach.longitude,
          placeName: placeName,
          redirectToStore: false, // No redirigir automáticamente a la tienda
        );

        // Si Waze falla, ofrecer Google Maps como alternativa
        if (!success) {
          // Mostrar diálogo ofreciendo Google Maps como alternativa
          if (mounted) {
            final useGoogleMaps = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text(l10n.beachWazeNotInstalled),
                  content: Text(l10n.beachWazeError),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(l10n.beachNavigateGoogleMaps),
                    ),
                  ],
                );
              },
            );

            // Si el usuario acepta, abrir Google Maps
            if (useGoogleMaps == true && mounted) {
              success = await NavigationService.openGoogleMaps(
                latitude: beach.latitude,
                longitude: beach.longitude,
                placeName: placeName,
              );

              if (!success) {
                messenger.showSnackBar(SnackBar(content: Text(l10n.mapError)));
              }
            } else if (useGoogleMaps == false && mounted) {
              // Si el usuario cancela, ofrecer instalar Waze
              messenger.showSnackBar(
                SnackBar(
                  content: Text(l10n.beachWazeNotInstalled),
                  action: SnackBarAction(
                    label: l10n.beachWazeInstall,
                    onPressed: () => NavigationService.openWazeStore(),
                  ),
                ),
              );
            }
          }
        }
      } else {
        // Abrir Google Maps (comportamiento por defecto)
        success = await NavigationService.openGoogleMaps(
          latitude: beach.latitude,
          longitude: beach.longitude,
          placeName: placeName,
        );

        if (!success) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.mapError)));
        }
      }
    }

    // Mostrar anuncio en video antes de abrir las direcciones
    if (_interstitialAdHelper?.isAdReady == true) {
      // Actualizar callbacks del helper existente para abrir direcciones después del anuncio
      _interstitialAdHelper!.updateCallbacks(
        onAdDismissed: () {
          // Recargar anuncio para la próxima vez
          _loadInterstitialAd();
          // Abrir direcciones después de cerrar el anuncio
          openDirections();
        },
        onAdFailedToShow: () {
          // Si falla el anuncio, abrir direcciones directamente
          _loadInterstitialAd();
          openDirections();
        },
      );

      // Mostrar el anuncio que ya está cargado
      final shown = await _interstitialAdHelper!.showInterstitialAd();
      if (!shown) {
        // Si no se pudo mostrar, abrir direcciones directamente
        openDirections();
      }
    } else {
      // Si no hay anuncio listo, abrir direcciones directamente
      // Intentar cargar para la próxima vez
      _loadInterstitialAd();
      openDirections();
    }
  }

  // Mostrar visor de imágenes a pantalla completa
  void _showImageViewer(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _ImageViewerScreen(photos: photos, initialIndex: initialIndex),
        fullscreenDialog: true,
      ),
    );
  }

  // Compartir playa con información completa
  void _shareBeach(BuildContext context, Beach beach) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${beach.latitude},${beach.longitude}';
    final localizedCondition = BeachConditions.getLocalizedCondition(
      context,
      beach.currentCondition,
    );

    final shareText =
        '''
🏖️ ${beach.name}

📍 ${beach.municipality}, ${beach.province}
⭐ ${beach.rating}/5.0 (${beach.reviewCount} ${l10n.beachReports.toLowerCase()})
${beach.currentCondition != 'Desconocido' ? '🚦 ${l10n.beachCondition}: $localizedCondition' : ''}

${beach.getLocalizedDescription(settings.language)}

📍 Ver en mapa: $googleMapsUrl

---
Descargado desde ${l10n.appTitle} 🇩🇴
${l10n.appDescription}
    '''
            .trim();

    Share.share(shareText, subject: '${beach.name} - ${l10n.appTitle}');
  }

  // Mostrar diálogo de calificación
  Future<void> _showRatingDialog(
    BuildContext context,
    Beach beach,
    AuthProvider authProvider,
  ) async {
    double selectedRating = 0.0;
    final TextEditingController commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Calificar ${beach.name}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    RatingBar.builder(
                      initialRating: selectedRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 40,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: AppColors.secondary),
                      onRatingUpdate: (rating) {
                        setState(() {
                          selectedRating = rating;
                        });
                      },
                    ),
                    if (selectedRating > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        '${selectedRating.toStringAsFixed(1)} de 5 estrellas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: 'Comentario (opcional)',
                        hintText: 'Escribe tu opinión sobre esta playa...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedRating > 0
                      ? () async {
                          Navigator.of(dialogContext).pop();
                          await _submitRating(
                            context,
                            beach,
                            authProvider,
                            selectedRating,
                            commentController.text.trim(),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Enviar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Enviar calificación
  Future<void> _submitRating(
    BuildContext context,
    Beach beach,
    AuthProvider authProvider,
    double rating,
    String comment,
  ) async {
    try {
      final userId = authProvider.user!.uid;
      final userName = authProvider.user!.displayName ?? 'Usuario';

      // Determinar condición basada en la calificación
      String condition;
      if (rating >= 4.5) {
        condition = 'Excelente';
      } else if (rating >= 3.5) {
        condition = 'Bueno';
      } else if (rating >= 2.5) {
        condition = 'Moderado';
      } else {
        condition = 'Peligroso';
      }

      final report = BeachReport(
        id: const Uuid().v4(),
        beachId: beach.id,
        userId: userId,
        userName: userName,
        condition: condition,
        rating: rating,
        comment: comment.isEmpty ? null : comment,
        imageUrls: const [],
        timestamp: DateTime.now(),
        helpfulCount: 0,
      );

      final reportId = await FirebaseService.createReport(report);

      if (reportId != null && mounted) {
        // Actualizar la playa en el provider
        final beachProvider = context.read<BeachProvider>();
        await beachProvider.refreshBeach(beach.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Calificación enviada! ${rating.toStringAsFixed(1)} estrellas',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar la calificación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error enviando calificación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar la calificación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Visor de imágenes a pantalla completa
class _ImageViewerScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _ImageViewerScreen({required this.photos, required this.initialIndex});

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView con las imágenes
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: _toggleControls,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.photos[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) {
                        print(
                          '❌ Error al cargar imagen en visor: $url - $error',
                        );
                        // Si la URL es de Google Places y falló, intentar regenerarla
                        if (url.contains(
                          'maps.googleapis.com/maps/api/place/photo',
                        )) {
                          print(
                            '⚠️ URL de imagen expirada o inválida en visor: $url',
                          );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final beachProvider = Provider.of<BeachProvider>(
                              context,
                              listen: false,
                            );
                            if (beachProvider.selectedBeach != null) {
                              beachProvider.regenerateExpiredImageUrls(
                                beachProvider.selectedBeach!,
                              );
                            }
                          });
                        }
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 64,
                          ),
                        );
                      },
                      // Configuraciones adicionales para mejorar la carga
                      fadeInDuration: const Duration(milliseconds: 300),
                      fadeOutDuration: const Duration(milliseconds: 100),
                    ),
                  ),
                ),
              );
            },
          ),
          // Controles superiores
          if (_showControls)
            SafeArea(
              child: Column(
                children: [
                  // Barra superior con botón de cerrar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        if (widget.photos.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentIndex + 1} / ${widget.photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 48), // Espacio para centrar
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Indicadores de página en la parte inferior
                  if (widget.photos.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.photos.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

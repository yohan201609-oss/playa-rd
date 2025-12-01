import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/beach_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../models/beach.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import 'beach_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();
  bool _locationPermissionGranted = false;
  BeachProvider? _beachProvider;

  // República Dominicana center coordinates
  static const double _centerLat = 18.7357;
  static const double _centerLng = -70.1627;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    
    // Escuchar cambios en el provider y actualizar marcadores solo cuando cambien las playas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _beachProvider = Provider.of<BeachProvider>(context, listen: false);
      _updateBeachMarkers(_beachProvider!.beaches);
      
      // Agregar listener para cambios futuros
      _beachProvider!.addListener(_onBeachesChanged);
      
      // Escuchar cambios de idioma para actualizar marcadores
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.addListener(_onLanguageChanged);
    });
  }
  
  void _onLanguageChanged() {
    // Cuando cambia el idioma, solo necesitamos actualizar el texto de los InfoWindows
    // Los colores de los marcadores NO deben cambiar porque siempre usan la condición original
    if (_beachProvider != null && mounted) {
      // Actualizar marcadores para cambiar solo el texto traducido en los InfoWindows
      _updateBeachMarkers(_beachProvider!.beaches);
    }
  }
  
  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Servicios de ubicación deshabilitados');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Permisos de ubicación denegados');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Permisos de ubicación denegados permanentemente');
        return;
      }

      setState(() {
        _locationPermissionGranted = true;
      });
      print('✅ Permisos de ubicación otorgados');
    } catch (e) {
      print('⚠️ Error al verificar permisos de ubicación: $e');
    }
  }

  void _onBeachesChanged() {
    if (_beachProvider != null && mounted) {
      _updateBeachMarkers(_beachProvider!.beaches);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Consumer<BeachProvider>(
          builder: (context, provider, child) {
            return Text(l10n.mapTitleWithCount(provider.beaches.length));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, l10n),
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnDominicanRepublic,
          ),
        ],
      ),
      body: Stack(children: [_buildMap(), _buildLegend(), _buildBeachList()]),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(_centerLat, _centerLng),
        zoom: 7.5,
      ),
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        print('✅ Mapa de Google Maps creado correctamente');
        // Actualizar marcadores después de que el mapa se haya creado
        if (_beachProvider != null) {
          _updateBeachMarkers(_beachProvider!.beaches);
        }
      },
      onTap: (LatLng position) {
        // Cerrar cualquier InfoWindow abierto al tocar el mapa
        // Esto se maneja automáticamente por Google Maps
      },
      mapType: MapType.normal,
      myLocationEnabled: _locationPermissionGranted,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      // Optimizaciones para reducir errores de renderizado
      buildingsEnabled: false,
      compassEnabled: false,
      indoorViewEnabled: false,
      trafficEnabled: false,
      liteModeEnabled: false,
    );
  }

  Widget _buildLegend() {
    final padding = ResponsiveBreakpoints.isMobile(context) ? 16.0 : 24.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Positioned(
      top: padding,
      right: padding,
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Condiciones',
              style: TextStyle(
                fontSize: ResponsiveBreakpoints.fontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                ),
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _buildLegendItem(
              color: BeachConditions.getColor(BeachConditions.excellent),
              label: 'Excelente',
            ),
            _buildLegendItem(
              color: BeachConditions.getColor(BeachConditions.good),
              label: 'Bueno',
            ),
            _buildLegendItem(
              color: BeachConditions.getColor(BeachConditions.moderate),
              label: 'Moderado',
            ),
            _buildLegendItem(
              color: BeachConditions.getColor(BeachConditions.danger),
              label: 'Peligroso',
            ),
            _buildLegendItem(
              color: BeachConditions.getColor(BeachConditions.unknown),
              label: 'Desconocido',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveBreakpoints.isMobile(context) ? 4 : 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ResponsiveBreakpoints.isMobile(context) ? 12 : 14,
            height: ResponsiveBreakpoints.isMobile(context) ? 12 : 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: ResponsiveBreakpoints.isMobile(context) ? 8 : 10),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveBreakpoints.fontSize(
                context,
                mobile: 11,
                tablet: 12,
                desktop: 13,
              ),
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeachList() {
    return Consumer<BeachProvider>(
      builder: (context, provider, child) {
        return DraggableScrollableSheet(
          controller: _scrollController,
          initialChildSize: 0.15,
          minChildSize: 0.15,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.26),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveBreakpoints.horizontalPadding(context),
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${provider.beaches.length} playas',
                          style: TextStyle(
                            fontSize: ResponsiveBreakpoints.fontSize(
                              context,
                              mobile: 18,
                              tablet: 20,
                              desktop: 22,
                            ),
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (provider.selectedProvince != 'Todas' ||
                            provider.selectedCondition != 'Todas')
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return TextButton.icon(
                                onPressed: () => provider.clearFilters(),
                                icon: const Icon(Icons.clear, size: 18),
                                label: Text(l10n.mapClear),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Beach list
                  Expanded(
                    child: provider.beaches.isEmpty
                        ? Builder(
                            builder: (context) {
                              final theme = Theme.of(context);
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.beach_access,
                                      size: 60,
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay playas con estos filtros',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: EdgeInsets.all(
                              ResponsiveBreakpoints.horizontalPadding(context),
                            ),
                            itemCount: provider.beaches.length,
                            separatorBuilder: (context, index) => SizedBox(
                              height: ResponsiveBreakpoints.isMobile(context) ? 12 : 16,
                            ),
                            itemBuilder: (context, index) {
                              final beach = provider.beaches[index];
                              return _buildBeachListItem(beach, provider);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBeachListItem(Beach beach, BeachProvider provider) {
    final conditionColor = BeachConditions.getColor(beach.currentCondition);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        provider.selectBeach(beach);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BeachDetailScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            // Beach image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                image: beach.imageUrls.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(beach.imageUrls.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: beach.imageUrls.isEmpty
                  ? Icon(
                      Icons.beach_access,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Beach info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beach.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    beach.province,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isAuthenticated) {
                            return Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: conditionColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Consumer<SettingsProvider>(
                                  builder: (context, settings, child) {
                                    return Text(
                                      BeachConditions.getLocalizedCondition(context, beach.currentCondition),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                              ],
                            );
                          }
                          // Si no está autenticado, mostrar mensaje de bloqueo
                          return Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Inicia sesión',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          );
                        },
                      ),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        beach.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Location button
            IconButton(
              icon: const Icon(Icons.my_location, size: 20),
              color: AppColors.primary,
              onPressed: () => _centerOnBeach(beach),
              tooltip: 'Centrar en el mapa',
            ),
          ],
        ),
      ),
    );
  }

  void _updateBeachMarkers(List<Beach> beaches) {
    if (!mounted) return;
    
    // Obtener el contexto del widget para las traducciones
    final context = this.context;
    
    setState(() {
      _markers = beaches.map((beach) {
        // IMPORTANTE: Usar siempre la condición original (en español) para el color del marcador
        // La condición original siempre está en español: 'Excelente', 'Bueno', 'Moderado', 'Peligroso'
        final originalCondition = beach.currentCondition;
        
        // Solo traducir para el InfoWindow (texto visible al usuario)
        final l10n = AppLocalizations.of(context);
        final localizedCondition = l10n != null 
          ? BeachConditions.getLocalizedCondition(context, originalCondition)
          : originalCondition;
        
        return Marker(
          markerId: MarkerId(beach.id),
          position: LatLng(beach.latitude, beach.longitude),
          infoWindow: InfoWindow(
            title: beach.name,
            snippet: '${beach.province} - $localizedCondition',
          ),
          // Usar siempre la condición original para determinar el color
          icon: _getMarkerIcon(originalCondition),
          onTap: () {
            // Navegar a los detalles de la playa al tocar el marcador
            if (_beachProvider != null) {
              _beachProvider!.selectBeach(beach);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BeachDetailScreen(),
                ),
              );
            }
          },
        );
      }).toSet();
    });
    print('✅ ${beaches.length} marcadores actualizados en el mapa');
  }

  BitmapDescriptor _getMarkerIcon(String condition) {
    // IMPORTANTE: Este método siempre recibe la condición original en español
    // ('Excelente', 'Bueno', 'Moderado', 'Peligroso')
    // Usar las constantes de BeachConditions para comparación exacta
    double hue;
    
    // Normalizar la condición para evitar problemas con espacios o mayúsculas
    final normalizedCondition = condition.trim();
    
    switch (normalizedCondition) {
      case BeachConditions.excellent:
        hue = BitmapDescriptor.hueGreen;
        break;
      case BeachConditions.good:
        hue = BitmapDescriptor.hueYellow;
        break;
      case BeachConditions.moderate:
        hue = BitmapDescriptor.hueOrange;
        break;
      case BeachConditions.danger:
        hue = BitmapDescriptor.hueRed;
        break;
      default:
        // Si no coincide con ninguna condición conocida, usar azul por defecto
        hue = BitmapDescriptor.hueBlue;
    }
    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  void _centerOnBeach(Beach beach) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(beach.latitude, beach.longitude),
          zoom: 12.0,
        ),
      ),
    );

    // Collapse the bottom sheet to see the map better
    _scrollController.animateTo(
      0.15,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _centerOnDominicanRepublic() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: LatLng(_centerLat, _centerLng), zoom: 7.5),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<BeachProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.homeFilters,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => provider.clearFilters(),
                        child: Text(l10n.mapClear),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.mapProvince,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Todas', ...provider.availableProvinces].map((
                      province,
                    ) {
                      return ChoiceChip(
                        label: Text(province),
                        selected: provider.selectedProvince == province,
                        onSelected: (_) {
                          provider.filterByProvince(province);
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        labelStyle: TextStyle(
                          color: provider.selectedProvince == province
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.beachCondition,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'Todas',
                          BeachConditions.excellent,
                          BeachConditions.good,
                          BeachConditions.moderate,
                          BeachConditions.danger,
                        ].map((condition) {
                          return ChoiceChip(
                            label: Text(condition),
                            selected: provider.selectedCondition == condition,
                            onSelected: (_) {
                              provider.filterByCondition(condition);
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                            labelStyle: TextStyle(
                              color: provider.selectedCondition == condition
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Remover los listeners para evitar memory leaks
    _beachProvider?.removeListener(_onBeachesChanged);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.removeListener(_onLanguageChanged);

    _mapController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

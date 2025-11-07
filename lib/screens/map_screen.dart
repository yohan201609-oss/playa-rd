import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/beach_provider.dart';
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
    });
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
    if (_beachProvider != null) {
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
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Condiciones',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11)),
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
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
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
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${provider.beaches.length} playas',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.beach_access,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay playas con estos filtros',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.beaches.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Beach image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                image: beach.imageUrls.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(beach.imageUrls.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: beach.imageUrls.isEmpty
                  ? Icon(Icons.beach_access, color: Colors.grey[400])
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    beach.province,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
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
                      Text(
                        beach.currentCondition,
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        beach.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11),
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
    
    setState(() {
      _markers = beaches.map((beach) {
        return Marker(
          markerId: MarkerId(beach.id),
          position: LatLng(beach.latitude, beach.longitude),
          infoWindow: InfoWindow(
            title: beach.name,
            snippet: '${beach.province} - ${beach.currentCondition}',
          ),
          icon: _getMarkerIcon(beach.currentCondition),
        );
      }).toSet();
    });
    // Solo registrar en debug cuando hay cambios significativos
    if (beaches.length != _markers.length) {
      print('✅ ${beaches.length} marcadores actualizados en el mapa');
    }
  }

  BitmapDescriptor _getMarkerIcon(String condition) {
    Color color;
    switch (condition) {
      case 'Excelente':
        color = AppColors.excellent;
        break;
      case 'Bueno':
        color = AppColors.good;
        break;
      case 'Moderado':
        color = AppColors.moderate;
        break;
      case 'Peligroso':
        color = AppColors.danger;
        break;
      default:
        color = Colors.grey;
    }
    return BitmapDescriptor.defaultMarkerWithHue(_colorToHue(color));
  }

  double _colorToHue(Color color) {
    if (color == AppColors.excellent) return BitmapDescriptor.hueGreen;
    if (color == AppColors.good) return BitmapDescriptor.hueYellow;
    if (color == AppColors.moderate) return BitmapDescriptor.hueOrange;
    if (color == AppColors.danger) return BitmapDescriptor.hueRed;
    return BitmapDescriptor.hueBlue;
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
    showModalBottomSheet(
      context: context,
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        labelStyle: TextStyle(
                          color: provider.selectedProvince == province
                              ? Colors.white
                              : Colors.black,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.beachCondition,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                            labelStyle: TextStyle(
                              color: provider.selectedCondition == condition
                                  ? Colors.white
                                  : Colors.black,
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
    // Remover el listener para evitar memory leaks
    _beachProvider?.removeListener(_onBeachesChanged);
    
    _mapController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

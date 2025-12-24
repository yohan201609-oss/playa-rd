import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/beach.dart';
import '../services/beach_service.dart';
import '../services/firebase_service.dart';
import '../services/preferences_service.dart';
import '../services/beach_coordinates_updater.dart';
import '../services/google_places_service.dart';
import '../utils/notification_helper.dart';

class BeachProvider with ChangeNotifier {
  List<Beach> _beaches = [];
  List<Beach> _filteredBeaches = [];
  Beach? _selectedBeach;
  String _searchQuery = '';
  String _selectedProvince = 'Todas';
  String _selectedCondition = 'Todas';
  String _sortBy = 'rating';
  bool _isLoading = false;
  final Set<String> _regeneratingImageUrls =
      {}; // Prevenir regeneraciones múltiples

  List<Beach> get beaches => _filteredBeaches;
  Beach? get selectedBeach => _selectedBeach;
  String get searchQuery => _searchQuery;
  String get selectedProvince => _selectedProvince;
  String get selectedCondition => _selectedCondition;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;

  // Obtener provincias únicas que tienen playas
  List<String> get availableProvinces {
    final provinces = _beaches.map((beach) => beach.province).toSet().toList();
    provinces.sort();
    return provinces;
  }

  BeachProvider() {
    loadBeaches();
  }

  // Cargar playas
  Future<void> loadBeaches({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Si se fuerza la recarga, limpiar caché primero
      if (forceRefresh) {
        await clearCache();
        print('🔄 Caché limpiado, forzando recarga desde Firestore');
      }

      // Intentar cargar desde Firestore primero (siempre intentar para obtener datos actualizados)
      try {
        final firestoreBeaches = await _loadFromFirestore();
        if (firestoreBeaches != null && firestoreBeaches.isNotEmpty) {
          _beaches = firestoreBeaches;
          _applyFilters();
          await _saveToCache(_beaches);
          print(
            '🔥 ${firestoreBeaches.length} playas cargadas desde Firestore',
          );
          _isLoading = false;
          notifyListeners();

          // Sincronizar favoritos después de cargar desde Firestore
          await _syncUserFavorites();
          return;
        }
      } catch (e) {
        print('⚠️ Error cargando desde Firestore: $e');
        // Si falla Firestore, intentar usar caché
      }

      // Si Firestore falló o no tiene datos, intentar cargar desde caché (modo offline)
      final cachedBeaches = await _loadFromCache();
      if (cachedBeaches != null && cachedBeaches.isNotEmpty) {
        _beaches = cachedBeaches;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
        print('📦 ${cachedBeaches.length} playas cargadas desde caché');

        // Sincronizar favoritos después de cargar desde caché
        await _syncUserFavorites();
        return;
      }

      // Si no hay datos en Firestore ni caché, cargar datos estáticos
      _beaches = BeachService.getDominicanBeaches();
      _applyFilters();

      // Guardar en caché para uso offline
      await _saveToCache(_beaches);
      print('💾 ${_beaches.length} playas guardadas en caché');

      // Sincronizar favoritos después de cargar datos estáticos
      await _syncUserFavorites();
    } catch (e) {
      print('Error cargando playas: $e');
      // Si hay error y no hay caché, usar datos por defecto
      if (_beaches.isEmpty) {
        _beaches = BeachService.getDominicanBeaches();
        _applyFilters();
        // Intentar sincronizar favoritos incluso si hubo error
        await _syncUserFavorites();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Forzar recarga desde Firestore
  Future<void> refreshBeaches() async {
    await loadBeaches(forceRefresh: true);
  }

  // Sincronizar favoritos del usuario actual
  Future<void> _syncUserFavorites() async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        final appUser = await FirebaseService.getUserData(currentUser.uid);
        if (appUser != null) {
          syncFavorites(appUser.favoriteBeaches);
          print(
            '💖 Favoritos sincronizados: ${appUser.favoriteBeaches.length} playas',
          );
        }
      }
    } catch (e) {
      print('⚠️ Error sincronizando favoritos: $e');
    }
  }

  // Cargar playas desde Firestore
  Future<List<Beach>?> _loadFromFirestore() async {
    try {
      final beaches = await FirebaseService.getBeachesOnce();
      if (beaches.isNotEmpty) {
        return beaches;
      }
      return null;
    } catch (e) {
      print('Error cargando desde Firestore: $e');
      return null;
    }
  }

  // Guardar playas en caché local
  Future<void> _saveToCache(List<Beach> beaches) async {
    try {
      final beachesJson = beaches.map((beach) {
        return {
          'id': beach.id,
          'name': beach.name,
          'province': beach.province,
          'municipality': beach.municipality,
          'postalCode': beach.postalCode,
          'address': beach.address,
          'description': beach.description,
          'descriptionEn': beach.descriptionEn,
          'latitude': beach.latitude,
          'longitude': beach.longitude,
          'imageUrls': beach.imageUrls,
          'rating': beach.rating,
          'reviewCount': beach.reviewCount,
          'currentCondition': beach.currentCondition,
          'amenities': beach.amenities,
          'activities': beach.activities,
          'isFavorite': beach.isFavorite,
        };
      }).toList();

      await PreferencesService.prefs.setString(
        'cached_beaches',
        jsonEncode(beachesJson),
      );
      await PreferencesService.prefs.setString(
        'cache_timestamp',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error guardando caché: $e');
    }
  }

  // Cargar playas desde caché local
  Future<List<Beach>?> _loadFromCache() async {
    try {
      final cachedData = PreferencesService.prefs.getString('cached_beaches');
      final cacheTimestamp = PreferencesService.prefs.getString(
        'cache_timestamp',
      );

      if (cachedData == null || cacheTimestamp == null) {
        return null;
      }

      // Verificar si el caché no es muy viejo (máximo 1 hora para asegurar datos actualizados)
      final cacheDate = DateTime.parse(cacheTimestamp);
      final hoursSinceCache = DateTime.now().difference(cacheDate).inHours;

      if (hoursSinceCache > 1) {
        print(
          '⏰ Caché expirado ($hoursSinceCache horas), se intentará cargar desde Firestore',
        );
        return null;
      }

      final beachesJson = jsonDecode(cachedData) as List;
      final beaches = beachesJson.map((json) {
        return Beach(
          id: json['id'],
          name: json['name'],
          province: json['province'],
          municipality: json['municipality'],
          postalCode: json['postalCode'],
          address: json['address'],
          description: json['description'],
          descriptionEn: json['descriptionEn'],
          latitude: json['latitude'],
          longitude: json['longitude'],
          imageUrls: List<String>.from(json['imageUrls'] ?? []),
          rating: (json['rating'] as num).toDouble(),
          reviewCount: json['reviewCount'],
          currentCondition: json['currentCondition'] ?? 'Desconocido',
          amenities: Map<String, dynamic>.from(json['amenities'] ?? {}),
          activities: List<String>.from(json['activities'] ?? []),
          isFavorite: json['isFavorite'] ?? false,
        );
      }).toList();

      return beaches;
    } catch (e) {
      print('Error cargando desde caché: $e');
      return null;
    }
  }

  // Limpiar caché
  Future<void> clearCache() async {
    await PreferencesService.remove('cached_beaches');
    await PreferencesService.remove('cache_timestamp');
    print('🗑️ Caché limpiado');
  }

  // Buscar playas
  void searchBeaches(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filtrar por provincia
  void filterByProvince(String province) {
    _selectedProvince = province;
    _applyFilters();
    notifyListeners();
  }

  // Filtrar por condición
  void filterByCondition(String condition) {
    _selectedCondition = condition;
    _applyFilters();
    notifyListeners();
  }

  // Cambiar orden
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
    notifyListeners();
  }

  // Aplicar todos los filtros
  void _applyFilters() {
    _filteredBeaches = _beaches;

    // Buscar
    if (_searchQuery.isNotEmpty) {
      _filteredBeaches = BeachService.searchBeaches(
        _filteredBeaches,
        _searchQuery,
      );
    }

    // Filtrar por provincia
    if (_selectedProvince != 'Todas') {
      _filteredBeaches = BeachService.filterByProvince(
        _filteredBeaches,
        _selectedProvince,
      );
    }

    // Filtrar por condición
    if (_selectedCondition != 'Todas') {
      _filteredBeaches = BeachService.filterByCondition(
        _filteredBeaches,
        _selectedCondition,
      );
    }

    // Ordenar
    _filteredBeaches = BeachService.sortBeaches(_filteredBeaches, _sortBy);
  }

  // Seleccionar playa
  void selectBeach(Beach beach) {
    _selectedBeach = beach;
    notifyListeners();
  }

  // Actualizar una playa específica (útil después de crear reportes)
  Future<void> refreshBeach(String beachId) async {
    try {
      // Obtener la playa actualizada desde Firestore
      final updatedBeach = await FirebaseService.getBeachById(beachId);

      if (updatedBeach != null) {
        // Actualizar en la lista de playas
        final index = _beaches.indexWhere((b) => b.id == beachId);
        if (index != -1) {
          _beaches[index] = updatedBeach;
          _applyFilters();

          // Si es la playa seleccionada, actualizarla también
          if (_selectedBeach?.id == beachId) {
            _selectedBeach = updatedBeach;
          }

          notifyListeners();
          print('✅ Playa ${updatedBeach.name} actualizada en el provider');
        }
      }
    } catch (e) {
      print('⚠️ Error actualizando playa en provider: $e');
    }
  }

  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedProvince = 'Todas';
    _selectedCondition = 'Todas';
    _applyFilters();
    notifyListeners();
  }

  // Sincronizar favoritos del usuario con las playas
  void syncFavorites(List<String> favoriteIds) {
    for (int i = 0; i < _beaches.length; i++) {
      final isFavorite = favoriteIds.contains(_beaches[i].id);
      if (_beaches[i].isFavorite != isFavorite) {
        _beaches[i] = _beaches[i].copyWith(isFavorite: isFavorite);
      }
    }
    _applyFilters();
    notifyListeners();
  }

  // Toggle favorito
  Future<void> toggleFavorite(Beach beach, String userId) async {
    try {
      final wasFavorite = beach.isFavorite;
      final newFavoriteState = !beach.isFavorite;

      print(
        '🔄 Cambiando estado de favorito para ${beach.name}: $wasFavorite -> $newFavoriteState',
      );

      // Actualizar en Firebase primero
      if (wasFavorite) {
        await FirebaseService.removeFavoriteBeach(userId, beach.id);
      } else {
        await FirebaseService.addFavoriteBeach(userId, beach.id);
      }

      // Si la actualización en Firebase fue exitosa, actualizar localmente
      final index = _beaches.indexWhere((b) => b.id == beach.id);
      if (index != -1) {
        _beaches[index] = beach.copyWith(isFavorite: newFavoriteState);
        _applyFilters();
        notifyListeners();
        print('✅ Estado de favorito actualizado localmente para ${beach.name}');

        // Enviar notificación solo cuando se añade como favorito (no cuando se quita)
        if (!wasFavorite) {
          try {
            await NotificationHelper.sendFavoriteBeachNotification(beach.name);
            print('📱 Notificación de favorito enviada para ${beach.name}');
          } catch (e) {
            print('⚠️ Error enviando notificación: $e');
          }
        }
      } else {
        print('⚠️ No se encontró la playa en la lista local');
      }
    } catch (e) {
      print('❌ Error toggle favorito: $e');
      // Revertir cambio local si falló la actualización en Firebase
      final index = _beaches.indexWhere((b) => b.id == beach.id);
      if (index != -1) {
        _beaches[index] = beach.copyWith(isFavorite: beach.isFavorite);
        _applyFilters();
        notifyListeners();
        print('🔄 Estado de favorito revertido debido al error');
      }
      rethrow; // Re-lanzar el error para que la UI pueda manejarlo
    }
  }

  // Actualizar coordenadas de una playa usando Google Geocoding API
  Future<bool> updateBeachCoordinates(Beach beach) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedBeach = await BeachCoordinatesUpdater.updateBeachCoordinates(
        beach,
      );

      if (updatedBeach != null) {
        // Actualizar en la lista local
        final index = _beaches.indexWhere((b) => b.id == beach.id);
        if (index != -1) {
          _beaches[index] = updatedBeach;
          _applyFilters();

          // Actualizar en caché
          await _saveToCache(_beaches);

          // Actualizar en Firestore si está disponible
          try {
            await FirebaseService.updateBeach(updatedBeach);
          } catch (e) {
            print('⚠️ Error actualizando en Firestore: $e');
          }

          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Error actualizando coordenadas: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Obtener todas las playas sin filtros (para uso interno)
  List<Beach> get allBeaches => _beaches;

  // Actualizar coordenadas de todas las playas
  Future<Map<String, dynamic>> updateAllBeachesCoordinates({
    Function(int current, int total, Beach beach)? onProgress,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      int updated = 0;
      int failed = 0;

      // Usar _beaches (todas las playas sin filtros) en lugar de beaches (filtradas)
      final beachesToUpdate = List<Beach>.from(_beaches);

      final updatedBeaches =
          await BeachCoordinatesUpdater.updateMultipleBeachesCoordinates(
            beachesToUpdate,
            onProgress: (current, total, beach) {
              if (onProgress != null) {
                onProgress(current, total, beach);
              }
            },
          );

      // Actualizar la lista
      for (int i = 0; i < updatedBeaches.length; i++) {
        final originalBeach = _beaches[i];
        final updatedBeach = updatedBeaches[i];

        // Verificar si las coordenadas cambiaron
        if (originalBeach.latitude != updatedBeach.latitude ||
            originalBeach.longitude != updatedBeach.longitude) {
          _beaches[i] = updatedBeach;
          updated++;

          // Actualizar en Firestore
          try {
            await FirebaseService.updateBeach(updatedBeach);
          } catch (e) {
            print(
              '⚠️ Error actualizando ${updatedBeach.name} en Firestore: $e',
            );
          }
        } else {
          failed++;
        }
      }

      // Actualizar caché
      await _saveToCache(_beaches);
      _applyFilters();

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'updated': updated,
        'failed': failed,
        'total': _beaches.length,
      };
    } catch (e) {
      print('❌ Error actualizando todas las coordenadas: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Buscar e importar playas desde Google Places API
  Future<Map<String, dynamic>> searchAndImportBeachesFromGoogle({
    int maxResults = 50,
    String? province,
    Function(int current, int total, String name)? onProgress,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔍 Iniciando búsqueda de playas desde Google Places API...');

      // Buscar playas usando Google Places API
      final newBeaches = await GooglePlacesService.searchAndConvertBeaches(
        maxResults: maxResults,
        province: province,
        onProgress: (current, total, name) {
          if (onProgress != null) {
            onProgress(current, total, name);
          }
        },
      );

      if (newBeaches.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'error': 'No se encontraron playas',
          'imported': 0,
          'skipped': 0,
        };
      }

      print('✅ ${newBeaches.length} playas encontradas, procesando...');

      int imported = 0;
      int skipped = 0;
      int updated = 0;

      // Procesar cada playa
      for (final newBeach in newBeaches) {
        // Verificar si la playa ya existe (por nombre o coordenadas cercanas)
        final existingIndex = _beaches.indexWhere((existing) {
          // Verificar por nombre similar
          if (existing.name.toLowerCase() == newBeach.name.toLowerCase()) {
            return true;
          }

          // Verificar por coordenadas cercanas (menos de 100 metros)
          final distance = _calculateDistance(
            existing.latitude,
            existing.longitude,
            newBeach.latitude,
            newBeach.longitude,
          );

          return distance < 0.1; // 100 metros
        });

        if (existingIndex != -1) {
          // La playa ya existe, actualizar información si es más completa
          final existing = _beaches[existingIndex];

          // Actualizar si la nueva playa tiene más información
          if (newBeach.imageUrls.isNotEmpty && existing.imageUrls.isEmpty) {
            _beaches[existingIndex] = existing.copyWith(
              imageUrls: newBeach.imageUrls,
              rating: newBeach.rating > existing.rating
                  ? newBeach.rating
                  : existing.rating,
              reviewCount: newBeach.reviewCount > existing.reviewCount
                  ? newBeach.reviewCount
                  : existing.reviewCount,
              address: newBeach.address ?? existing.address,
              description:
                  newBeach.description.length > existing.description.length
                  ? newBeach.description
                  : existing.description,
            );
            updated++;
            print('🔄 Playa actualizada: ${existing.name}');
          } else {
            skipped++;
            print('⏭️ Playa ya existe, saltada: ${newBeach.name}');
          }
        } else {
          // Nueva playa, agregarla
          _beaches.add(newBeach);
          imported++;
          print('✅ Nueva playa agregada: ${newBeach.name}');

          // Guardar en Firestore
          try {
            await FirebaseService.updateBeach(newBeach);
          } catch (e) {
            print('⚠️ Error guardando ${newBeach.name} en Firestore: $e');
          }
        }
      }

      // Actualizar caché y filtros
      await _saveToCache(_beaches);
      _applyFilters();

      _isLoading = false;
      notifyListeners();

      print('✅ Importación completada:');
      print('   - Importadas: $imported');
      print('   - Actualizadas: $updated');
      print('   - Omitidas: $skipped');
      print('   - Total: ${_beaches.length}');

      return {
        'success': true,
        'imported': imported,
        'updated': updated,
        'skipped': skipped,
        'total': _beaches.length,
      };
    } catch (e) {
      print('❌ Error importando playas: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Calcular distancia entre dos puntos (método auxiliar)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Fórmula de Haversine
    const double earthRadius = 6371; // Radio de la Tierra en km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Actualizar fotos de todas las playas desde Google Places API
  Future<Map<String, dynamic>> updateAllBeachesPhotos({
    Function(int current, int total, String name)? onProgress,
    bool onlyMissingPhotos = true, // Solo actualizar playas sin fotos
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('📸 Iniciando actualización de fotos...');

      // Filtrar playas que necesitan fotos
      final beachesToUpdate = onlyMissingPhotos
          ? _beaches.where((beach) => beach.imageUrls.isEmpty).toList()
          : _beaches;

      if (beachesToUpdate.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'updated': 0,
          'skipped': _beaches.length,
          'total': _beaches.length,
          'message': 'Todas las playas ya tienen fotos',
        };
      }

      print('📸 ${beachesToUpdate.length} playa(s) necesitan fotos');

      int updated = 0;
      int skipped = 0;
      int failed = 0;

      // Procesar cada playa
      for (int i = 0; i < beachesToUpdate.length; i++) {
        final beach = beachesToUpdate[i];

        // Reportar progreso
        if (onProgress != null) {
          onProgress(i + 1, beachesToUpdate.length, beach.name);
        }

        print(
          '🔄 Procesando ${i + 1}/${beachesToUpdate.length}: ${beach.name}',
        );

        try {
          // Obtener fotos desde Google Places API
          final photos = await GooglePlacesService.getBeachPhotos(
            beach.name,
            province: beach.province,
            municipality: beach.municipality,
            latitude: beach.latitude,
            longitude: beach.longitude,
            maxPhotos: 5,
          );

          if (photos.isNotEmpty) {
            // Actualizar playa con nuevas fotos
            final index = _beaches.indexWhere((b) => b.id == beach.id);
            if (index != -1) {
              // Si la playa ya tiene fotos, combinarlas (eliminar duplicados)
              final existingPhotos = _beaches[index].imageUrls;
              final allPhotos = <String>[...existingPhotos];

              for (final photo in photos) {
                if (!allPhotos.contains(photo)) {
                  allPhotos.add(photo);
                }
              }

              // Limitar a 5 fotos máximo
              final finalPhotos = allPhotos.length > 5
                  ? allPhotos.sublist(0, 5)
                  : allPhotos;

              _beaches[index] = _beaches[index].copyWith(
                imageUrls: finalPhotos,
              );

              updated++;
              print(
                '✅ Fotos actualizadas para: ${beach.name} (${finalPhotos.length} fotos)',
              );

              // Actualizar en Firestore
              try {
                await FirebaseService.updateBeach(_beaches[index]);
              } catch (e) {
                print('⚠️ Error guardando en Firestore: $e');
              }
            }
          } else {
            skipped++;
            print('⚠️ No se encontraron fotos para: ${beach.name}');
          }
        } catch (e) {
          failed++;
          print('❌ Error obteniendo fotos para ${beach.name}: $e');
        }

        // Pausa entre solicitudes para no exceder límites de API
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Actualizar caché y filtros
      await _saveToCache(_beaches);
      _applyFilters();

      _isLoading = false;
      notifyListeners();

      print('✅ Actualización de fotos completada:');
      print('   - Actualizadas: $updated');
      print('   - Omitidas: $skipped');
      print('   - Fallidas: $failed');
      print('   - Total: ${_beaches.length}');

      return {
        'success': true,
        'updated': updated,
        'skipped': skipped,
        'failed': failed,
        'total': _beaches.length,
      };
    } catch (e) {
      print('❌ Error actualizando fotos: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // Actualizar fotos de una playa específica
  Future<bool> updateBeachPhotos(Beach beach) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('📸 Obteniendo fotos para: ${beach.name}');

      // Obtener fotos desde Google Places API
      final photos = await GooglePlacesService.getBeachPhotos(
        beach.name,
        province: beach.province,
        municipality: beach.municipality,
        latitude: beach.latitude,
        longitude: beach.longitude,
        maxPhotos: 5,
      );

      if (photos.isEmpty) {
        _isLoading = false;
        notifyListeners();
        print('⚠️ No se encontraron fotos para: ${beach.name}');
        return false;
      }

      // Actualizar playa
      final index = _beaches.indexWhere((b) => b.id == beach.id);
      if (index != -1) {
        // Combinar fotos existentes con nuevas (eliminar duplicados)
        final existingPhotos = _beaches[index].imageUrls;
        final allPhotos = <String>[...existingPhotos];

        for (final photo in photos) {
          if (!allPhotos.contains(photo)) {
            allPhotos.add(photo);
          }
        }

        // Limitar a 5 fotos máximo
        final finalPhotos = allPhotos.length > 5
            ? allPhotos.sublist(0, 5)
            : allPhotos;

        _beaches[index] = _beaches[index].copyWith(imageUrls: finalPhotos);

        // Actualizar caché
        await _saveToCache(_beaches);
        _applyFilters();

        // Actualizar en Firestore
        try {
          await FirebaseService.updateBeach(_beaches[index]);
        } catch (e) {
          print('⚠️ Error guardando en Firestore: $e');
        }

        _isLoading = false;
        notifyListeners();

        print(
          '✅ Fotos actualizadas para: ${beach.name} (${finalPhotos.length} fotos)',
        );
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Error actualizando fotos: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Regenerar URLs de imágenes expiradas
  Future<void> regenerateExpiredImageUrls(Beach beach) async {
    // Prevenir regeneraciones múltiples para la misma playa
    if (_regeneratingImageUrls.contains(beach.id)) {
      print('⏳ Ya se está regenerando imágenes para: ${beach.name}');
      return;
    }

    try {
      // Verificar si la playa tiene URLs de Google Places que pueden haber expirado
      final hasExpiredUrls = beach.imageUrls.any(
        (url) => url.contains('maps.googleapis.com/maps/api/place/photo'),
      );

      if (!hasExpiredUrls) {
        return; // No hay URLs de Google Places que regenerar
      }

      _regeneratingImageUrls.add(beach.id);
      print('🔄 Regenerando URLs de imágenes para: ${beach.name}');

      // Obtener nuevas fotos desde Google Places API
      final photos = await GooglePlacesService.getBeachPhotos(
        beach.name,
        province: beach.province,
        municipality: beach.municipality,
        latitude: beach.latitude,
        longitude: beach.longitude,
        maxPhotos: 5,
      );

      if (photos.isNotEmpty) {
        // Actualizar playa con nuevas fotos
        final index = _beaches.indexWhere((b) => b.id == beach.id);
        if (index != -1) {
          _beaches[index] = _beaches[index].copyWith(imageUrls: photos);

          // Actualizar caché
          await _saveToCache(_beaches);
          _applyFilters();

          // Actualizar en Firestore
          try {
            await FirebaseService.updateBeach(_beaches[index]);
            print(
              '✅ URLs de imágenes regeneradas y guardadas para: ${beach.name}',
            );
          } catch (e) {
            print('⚠️ Error guardando en Firestore: $e');
          }

          notifyListeners();
        }
      } else {
        print('⚠️ No se pudieron obtener nuevas fotos para: ${beach.name}');
      }
    } catch (e) {
      print('❌ Error regenerando URLs de imágenes: $e');
    } finally {
      // Remover de la lista de regeneraciones en progreso
      _regeneratingImageUrls.remove(beach.id);
    }
  }
}

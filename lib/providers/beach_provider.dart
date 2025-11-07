import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/beach.dart';
import '../services/beach_service.dart';
import '../services/firebase_service.dart';
import '../services/preferences_service.dart';
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
  Future<void> loadBeaches() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar desde caché primero (modo offline)
      final cachedBeaches = await _loadFromCache();
      if (cachedBeaches != null && cachedBeaches.isNotEmpty) {
        _beaches = cachedBeaches;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
        print('📦 ${cachedBeaches.length} playas cargadas desde caché');
      }

      // Luego cargar datos frescos
      _beaches = BeachService.getDominicanBeaches();
      _applyFilters();
      
      // Guardar en caché para uso offline
      await _saveToCache(_beaches);
      print('💾 ${_beaches.length} playas guardadas en caché');
    } catch (e) {
      print('Error cargando playas: $e');
      // Si hay error y no hay caché, usar datos por defecto
      if (_beaches.isEmpty) {
        _beaches = BeachService.getDominicanBeaches();
        _applyFilters();
      }
    }

    _isLoading = false;
    notifyListeners();
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
          'description': beach.description,
          'latitude': beach.latitude,
          'longitude': beach.longitude,
          'imageUrls': beach.imageUrls,
          'rating': beach.rating,
          'reviewCount': beach.reviewCount,
          'currentCondition': beach.currentCondition,
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
      final cacheTimestamp = PreferencesService.prefs.getString('cache_timestamp');
      
      if (cachedData == null || cacheTimestamp == null) {
        return null;
      }

      // Verificar si el caché no es muy viejo (máximo 24 horas)
      final cacheDate = DateTime.parse(cacheTimestamp);
      final hoursSinceCache = DateTime.now().difference(cacheDate).inHours;
      
      if (hoursSinceCache > 24) {
        print('⏰ Caché expirado ($hoursSinceCache horas)');
        return null;
      }

      final beachesJson = jsonDecode(cachedData) as List;
      final beaches = beachesJson.map((json) {
        return Beach(
          id: json['id'],
          name: json['name'],
          province: json['province'],
          municipality: json['municipality'],
          description: json['description'],
          latitude: json['latitude'],
          longitude: json['longitude'],
          imageUrls: List<String>.from(json['imageUrls'] ?? []),
          rating: (json['rating'] as num).toDouble(),
          reviewCount: json['reviewCount'],
          currentCondition: json['currentCondition'] ?? 'Desconocido',
          amenities: const {},
          activities: const [],
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
      
      if (beach.isFavorite) {
        await FirebaseService.removeFavoriteBeach(userId, beach.id);
      } else {
        await FirebaseService.addFavoriteBeach(userId, beach.id);
      }

      // Actualizar localmente
      final index = _beaches.indexWhere((b) => b.id == beach.id);
      if (index != -1) {
        _beaches[index] = beach.copyWith(isFavorite: !beach.isFavorite);
        _applyFilters();
        notifyListeners();
        
        // Enviar notificación solo cuando se añade como favorito (no cuando se quita)
        if (!wasFavorite) {
          await NotificationHelper.sendFavoriteBeachNotification(beach.name);
          print('📱 Notificación de favorito enviada para ${beach.name}');
        }
      }
    } catch (e) {
      print('Error toggle favorito: $e');
    }
  }
}

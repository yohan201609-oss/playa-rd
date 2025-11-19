import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/beach_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/beach_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/app_logo.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'beach_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyFavorites = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // Logo en el AppBar - Usando tu logo existente
        title: Row(
          children: [
            AppLogo.small(useWhiteVersion: true),
            const SizedBox(width: 12),
            Text('${l10n.appTitle} 🇩🇴'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          _buildAdBanner(),
          _buildQuickFilters(l10n),
          Expanded(child: _buildBeachList(l10n)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    final padding = ResponsiveBreakpoints.horizontalPadding(context);
    return Container(
      padding: EdgeInsets.all(padding),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.homeSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<BeachProvider>().searchBeaches('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveBreakpoints.isMobile(context) ? 20 : 24,
          ),
        ),
        onChanged: (value) {
          context.read<BeachProvider>().searchBeaches(value);
        },
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      alignment: Alignment.center,
      child: const BannerAdWidget(
        adSize: AdSize.banner,
      ),
    );
  }

  Widget _buildQuickFilters(AppLocalizations l10n) {
    final authProvider = context.watch<AuthProvider>();
    final padding = ResponsiveBreakpoints.horizontalPadding(context);
    
    return Consumer<BeachProvider>(
      builder: (context, provider, child) {
        return Container(
          height: ResponsiveBreakpoints.isMobile(context) ? 50 : 60,
          padding: EdgeInsets.symmetric(horizontal: padding),
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Filtro de favoritos (solo si está autenticado)
              if (authProvider.isAuthenticated)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: _showOnlyFavorites ? Colors.white : const Color(0xFFFF4081),
                        ),
                        const SizedBox(width: 4),
                        Text(l10n.homeFilterFavorites),
                      ],
                    ),
                    selected: _showOnlyFavorites,
                    onSelected: (_) {
                      setState(() {
                        _showOnlyFavorites = !_showOnlyFavorites;
                      });
                    },
                    selectedColor: const Color(0xFFFF4081),
                    backgroundColor: const Color(0xFFFF4081).withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: _showOnlyFavorites ? Colors.white : const Color(0xFFFF4081),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              _buildFilterChip(
                label: l10n.homeFilterAll,
                selected: provider.selectedProvince == 'Todas' && !_showOnlyFavorites,
                onTap: () {
                  provider.filterByProvince('Todas');
                  setState(() {
                    _showOnlyFavorites = false;
                  });
                },
              ),
              ...provider.availableProvinces.map(
                (province) => _buildFilterChip(
                  label: province,
                  selected: provider.selectedProvince == province && !_showOnlyFavorites,
                  onTap: () {
                    provider.filterByProvince(province);
                    setState(() {
                      _showOnlyFavorites = false;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBeachList(AppLocalizations l10n) {
    return Consumer<BeachProvider>(
      builder: (context, beachProvider, child) {
        if (beachProvider.isLoading) {
          return const LoadingShimmer();
        }

        // Filtrar por favoritos si está activado
        final beaches = _showOnlyFavorites
            ? beachProvider.beaches.where((beach) => beach.isFavorite).toList()
            : beachProvider.beaches;

        if (beaches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showOnlyFavorites ? Icons.favorite_border : Icons.beach_access,
                  size: ResponsiveBreakpoints.isMobile(context) ? 100 : 120,
                  color: Colors.grey[400],
                ),
                SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 16 : 24),
                Text(
                  _showOnlyFavorites
                      ? l10n.homeNoFavorites
                      : l10n.homeNoBeaches,
                  style: TextStyle(
                    fontSize: ResponsiveBreakpoints.fontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: ResponsiveBreakpoints.isMobile(context) ? 8 : 12),
                TextButton(
                  onPressed: () {
                    beachProvider.clearFilters();
                    _searchController.clear();
                    setState(() {
                      _showOnlyFavorites = false;
                    });
                  },
                  child: Text(l10n.filter),
                ),
              ],
            ),
          );
        }

        final padding = ResponsiveBreakpoints.horizontalPadding(context);
        final isMobile = ResponsiveBreakpoints.isMobile(context);
        
        return RefreshIndicator(
          onRefresh: () => beachProvider.loadBeaches(),
          child: isMobile
              ? ListView.builder(
                  padding: EdgeInsets.all(padding),
                  itemCount: beaches.length,
                  itemBuilder: (context, index) {
                    final beach = beaches[index];
                    return BeachCard(
                      beach: beach,
                      onTap: () {
                        beachProvider.selectBeach(beach);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BeachDetailScreen(),
                          ),
                        );
                      },
                      onFavorite: () async {
                        final authProvider = context.read<AuthProvider>();
                        if (authProvider.isAuthenticated) {
                          await beachProvider.toggleFavorite(beach, authProvider.user!.uid);
                          await authProvider.reloadUserData();
                        } else {
                          _showLoginPrompt(context);
                        }
                      },
                    );
                  },
                )
              : ResponsiveContainer(
                  child: GridView.builder(
                    padding: EdgeInsets.all(padding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveBreakpoints.gridColumns(context),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: ResponsiveBreakpoints.isTablet(context) ? 0.75 : 0.7,
                    ),
                    itemCount: beaches.length,
                    itemBuilder: (context, index) {
                      final beach = beaches[index];
                      return BeachCard(
                        beach: beach,
                        onTap: () {
                          beachProvider.selectBeach(beach);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BeachDetailScreen(),
                            ),
                          );
                        },
                        onFavorite: () async {
                          final authProvider = context.read<AuthProvider>();
                          if (authProvider.isAuthenticated) {
                            await beachProvider.toggleFavorite(beach, authProvider.user!.uid);
                            await authProvider.reloadUserData();
                          } else {
                            _showLoginPrompt(context);
                          }
                        },
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<BeachProvider>(
          builder: (context, provider, child) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Header fijo
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          ResponsiveBreakpoints.horizontalPadding(context),
                          20,
                          ResponsiveBreakpoints.horizontalPadding(context),
                          0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.homeFilters,
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
                            ),
                            TextButton(
                              onPressed: () {
                                provider.clearFilters();
                                _searchController.clear();
                              },
                              child: Text(l10n.homeClearFilters),
                            ),
                          ],
                        ),
                      ),
                      // Contenido scrollable
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.all(
                            ResponsiveBreakpoints.horizontalPadding(context),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.beachCondition,
                                style: TextStyle(
                                  fontSize: ResponsiveBreakpoints.fontSize(
                                    context,
                                    mobile: 16,
                                    tablet: 18,
                                    desktop: 20,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Consumer<SettingsProvider>(
                                builder: (context, settings, child) {
                                  return Wrap(
                                    spacing: 8,
                                    children:
                                        [
                                          'Todas',
                                          BeachConditions.excellent,
                                          BeachConditions.good,
                                          BeachConditions.moderate,
                                          BeachConditions.danger,
                                        ].map((condition) {
                                          final displayText = condition == 'Todas'
                                              ? condition
                                              : BeachConditions.getLocalizedCondition(context, condition);
                                          return ChoiceChip(
                                        label: Text(displayText),
                                        selected: provider.selectedCondition == condition,
                                        onSelected: (_) {
                                          provider.filterByCondition(condition);
                                        },
                                        selectedColor: AppColors.primary,
                                        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                                        labelStyle: TextStyle(
                                          color: provider.selectedCondition == condition
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.homeSortBy,
                                style: TextStyle(
                                  fontSize: ResponsiveBreakpoints.fontSize(
                                    context,
                                    mobile: 16,
                                    tablet: 18,
                                    desktop: 20,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children:
                                    [
                                      {'label': l10n.homeSortRating, 'value': 'rating'},
                                      {'label': l10n.homeSortName, 'value': 'name'},
                                      {'label': l10n.homeSortCondition, 'value': 'condition'},
                                    ].map((sort) {
                                      return ChoiceChip(
                                        label: Text(sort['label'] as String),
                                        selected: provider.sortBy == sort['value'],
                                        onSelected: (_) {
                                          provider.setSortBy(sort['value'] as String);
                                        },
                                        selectedColor: AppColors.secondary,
                                        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                                        labelStyle: TextStyle(
                                          color: provider.sortBy == sort['value']
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                        ),
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      // Botón fijo al fondo
                      Container(
                        padding: EdgeInsets.all(
                          ResponsiveBreakpoints.horizontalPadding(context),
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              offset: const Offset(0, -2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveBreakpoints.isMobile(context) ? 16 : 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                l10n.homeApplyFilters,
                                style: TextStyle(
                                  fontSize: ResponsiveBreakpoints.fontSize(
                                    context,
                                    mobile: 16,
                                    tablet: 17,
                                    desktop: 18,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
      },
    );
  }

  void _showLoginPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.homeLoginToSaveFavorites),
        action: SnackBarAction(
          label: l10n.profileLogin,
          onPressed: () {
            // TODO: Navegar a pantalla de login
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/beach_provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../widgets/beach_card.dart';
import 'beach_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar playas y sincronizar favoritos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final beachProvider = context.read<BeachProvider>();
      final authProvider = context.read<AuthProvider>();
      
      beachProvider.loadBeaches().then((_) {
        // Sincronizar favoritos después de cargar playas
        if (authProvider.appUser != null) {
          beachProvider.syncFavorites(authProvider.appUser!.favoriteBeaches);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final beachProvider = context.watch<BeachProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileMyFavorites,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientTop, AppColors.gradientTop.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: _buildBody(context, authProvider, beachProvider, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AuthProvider authProvider,
    BeachProvider beachProvider,
    AppLocalizations l10n,
  ) {
    if (!authProvider.isAuthenticated) {
      return _buildLoginRequired(l10n);
    }

    final appUser = authProvider.appUser;
    if (appUser == null) {
      return _buildLoading();
    }

    // Filtrar playas favoritas
    print('ℹ️ Playas totales: ${beachProvider.beaches.length}');
    print('ℹ️ IDs favoritos del usuario: ${appUser.favoriteBeaches}');
    
    final favoriteBeaches = beachProvider.beaches
        .where((beach) => beach.isFavorite)
        .toList();
    
    print('✅ Playas favoritas encontradas: ${favoriteBeaches.length}');

    if (favoriteBeaches.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return Column(
      children: [
        _buildHeader(favoriteBeaches.length, l10n),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: favoriteBeaches.length,
            itemBuilder: (context, index) {
              final beach = favoriteBeaches[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BeachCard(
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
                    final userId = authProvider.user?.uid;
                    if (userId != null) {
                      await beachProvider.toggleFavorite(beach, userId);
                      // Recargar datos del usuario para actualizar la lista
                      await authProvider.reloadUserData();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int count, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4081), Color(0xFFFF6E9F)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4081).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileMyFavorites,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${count == 1 ? 'playa favorita' : 'playas favoritas'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4081).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 80,
                color: const Color(0xFFFF4081).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes favoritos aún',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Explora las playas y marca tus favoritas tocando el ícono de corazón',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Cambiar a tab de inicio
              },
              icon: const Icon(Icons.explore, color: Colors.white),
              label: const Text(
                'Explorar Playas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4081),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.profileLoginPrompt,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia sesión para ver tus playas favoritas',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}


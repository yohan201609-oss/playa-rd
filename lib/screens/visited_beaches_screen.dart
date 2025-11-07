import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/beach_provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../widgets/beach_card.dart';
import 'beach_detail_screen.dart';
import '../services/firebase_service.dart';

class VisitedBeachesScreen extends StatefulWidget {
  const VisitedBeachesScreen({super.key});

  @override
  State<VisitedBeachesScreen> createState() => _VisitedBeachesScreenState();
}

class _VisitedBeachesScreenState extends State<VisitedBeachesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar playas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final beachProvider = context.read<BeachProvider>();
      final authProvider = context.read<AuthProvider>();
      
      beachProvider.loadBeaches().then((_) {
        if (authProvider.appUser != null) {
          // Las playas visitadas se manejan localmente
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
        title: const Text(
          'Playas Visitadas',
          style: TextStyle(fontWeight: FontWeight.bold),
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

    // Filtrar playas visitadas
    final visitedBeaches = beachProvider.beaches
        .where((beach) => appUser.visitedBeaches.contains(beach.id))
        .toList();

    if (visitedBeaches.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return Column(
      children: [
        _buildHeader(visitedBeaches.length, l10n),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: visitedBeaches.length,
            itemBuilder: (context, index) {
              final beach = visitedBeaches[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Dismissible(
                  key: Key(beach.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminar de visitadas'),
                        content: Text('¿Quitar "${beach.name}" de playas visitadas?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    final userId = authProvider.user?.uid;
                    if (userId != null) {
                      await FirebaseService.removeVisitedBeach(userId, beach.id);
                      await authProvider.reloadUserData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${beach.name} eliminada de visitadas'),
                            action: SnackBarAction(
                              label: 'Deshacer',
                              onPressed: () async {
                                await FirebaseService.addVisitedBeach(userId, beach.id);
                                await authProvider.reloadUserData();
                              },
                            ),
                          ),
                        );
                      }
                    }
                  },
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
                        await authProvider.reloadUserData();
                      }
                    },
                  ),
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
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.beach_access_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Playas Visitadas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${count == 1 ? 'playa visitada' : 'playas visitadas'}',
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
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.beach_access_outlined,
                size: 80,
                color: AppColors.secondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No has visitado playas aún',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cuando visites una playa, márcala como visitada para ganar puntos y llevar un registro',
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
                backgroundColor: AppColors.secondary,
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
            const Text(
              'Inicia sesión para ver tus playas visitadas',
              style: TextStyle(color: Colors.grey),
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



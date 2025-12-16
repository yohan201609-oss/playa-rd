import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/beach_provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_logo.dart';
import '../services/admob_service.dart';
import 'login_screen.dart';
import 'favorites_screen.dart';
import 'visited_beaches_screen.dart';
import 'my_reports_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'test_notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  InterstitialAdHelper? _interstitialAdHelper;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingPhoto = false;
  bool _isAvatarPressed = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  Future<void> _loadInterstitialAd() async {
    _interstitialAdHelper = InterstitialAdHelper(
      useHotelRestaurantTargeting: true,
    );
    await _interstitialAdHelper?.loadInterstitialAd();
  }

  Future<void> _showInterstitialAdAndNavigate(
    VoidCallback navigationCallback,
  ) async {
    if (_interstitialAdHelper?.isAdReady == true) {
      // Mostrar el anuncio y esperar a que se cierre
      final shown = await _interstitialAdHelper!.showInterstitialAd();
      if (shown) {
        // Esperar un momento para que el anuncio se cierre completamente
        await Future.delayed(const Duration(milliseconds: 500));
        // Recargar el anuncio para la próxima vez
        _loadInterstitialAd();
      }
    }
    // Ejecutar la navegación después del anuncio (o inmediatamente si no hay anuncio)
    if (mounted) {
      navigationCallback();
    }
  }

  @override
  void dispose() {
    _interstitialAdHelper?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con gradiente
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gradientTop,
                      AppColors.gradientTop.withOpacity(0.85),
                      AppColors.gradientBottom,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildUserAvatar(authProvider),
                      const SizedBox(height: 12),
                      _buildUserInfo(authProvider, l10n),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenido
          SliverToBody(
            child: authProvider.isAuthenticated
                ? _buildAuthenticatedView(context, authProvider, l10n)
                : _buildGuestView(context, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(AuthProvider authProvider) {
    return Hero(
      tag: 'user_avatar',
      child: GestureDetector(
        onTapDown: authProvider.isAuthenticated
            ? (_) => setState(() => _isAvatarPressed = true)
            : null,
        onTapUp: authProvider.isAuthenticated
            ? (_) {
                setState(() => _isAvatarPressed = false);
                _showPhotoPickerDialog(context, authProvider);
              }
            : null,
        onTapCancel: authProvider.isAuthenticated
            ? () => setState(() => _isAvatarPressed = false)
            : null,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildAvatarImage(authProvider),
              // Mostrar indicador de carga o overlay al presionar
              if (authProvider.isAuthenticated)
                Positioned.fill(
                  child: ClipOval(
                    child: _isUploadingPhoto
                        ? Container(
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : _isAvatarPressed
                        ? Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              // Botón de editar en la esquina inferior derecha
              if (authProvider.isAuthenticated && !_isUploadingPhoto)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return _buildDefaultAvatar();
    }

    // Priorizar foto de Firestore (appUser), luego Firebase Auth (user)
    final photoUrl =
        authProvider.appUser?.photoUrl ?? authProvider.user?.photoURL;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: SizedBox.expand(
          child: Image.network(
            photoUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar();
            },
          ),
        ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 50,
      color: AppColors.primary.withOpacity(0.6),
    );
  }

  Widget _buildUserInfo(AuthProvider authProvider, AppLocalizations l10n) {
    if (authProvider.isAuthenticated) {
      return Column(
        children: [
          Text(
            authProvider.appUser?.displayName ??
                authProvider.user?.displayName ??
                'Usuario',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authProvider.user?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Text(
      l10n.profileWelcome,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedView(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) {
    final beachProvider = context.watch<BeachProvider>();
    final favoriteCount = beachProvider.beaches
        .where((b) => b.isFavorite)
        .length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Estadísticas
          _buildStatsCard(context, authProvider, l10n, favoriteCount),
          const SizedBox(height: 20),

          // Anuncio banner
          _buildAdBanner(),
          const SizedBox(height: 20),

          // Opciones del menú
          _buildMenuSection(
            title: l10n.profileTitle,
            items: [
              _MenuItemData(
                icon: Icons.favorite,
                title: l10n.profileMyFavorites,
                subtitle: l10n.profileFavoritesBeaches,
                iconColor: const Color(0xFFFF4081),
                onTap: () {
                  _showInterstitialAdAndNavigate(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesScreen(),
                      ),
                    );
                  });
                },
              ),
              _MenuItemData(
                icon: Icons.beach_access,
                title: l10n.profileVisited,
                subtitle: 'Playas que he visitado',
                iconColor: AppColors.secondary,
                onTap: () {
                  _showInterstitialAdAndNavigate(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VisitedBeachesScreen(),
                      ),
                    );
                  });
                },
              ),
              _MenuItemData(
                icon: Icons.report,
                title: l10n.profileMyReports,
                subtitle: l10n.profileReportsSent,
                iconColor: Colors.orange,
                onTap: () {
                  _showInterstitialAdAndNavigate(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyReportsScreen(),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Configuración y ayuda
          _buildMenuSection(
            title: 'General',
            items: [
              _MenuItemData(
                icon: Icons.settings,
                title: l10n.profileSettings,
                subtitle: l10n.profileSettingsPreferences,
                iconColor: AppColors.primary,
                onTap: () {
                  _showInterstitialAdAndNavigate(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  });
                },
              ),
              _MenuItemData(
                icon: Icons.help,
                title: l10n.profileHelp,
                subtitle: l10n.profileHelpFAQ,
                iconColor: Colors.blue,
                onTap: () {
                  _showInterstitialAdAndNavigate(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    );
                  });
                },
              ),
              _MenuItemData(
                icon: Icons.info,
                title: l10n.profileAbout,
                subtitle: l10n.profileAboutVersion,
                iconColor: Colors.teal,
                onTap: () {
                  _showAboutDialog(context, l10n);
                },
              ),
              // ⚠️ SOLO PARA DESARROLLO - Eliminar en producción
              if (const bool.fromEnvironment('dart.vm.product') == false)
                _MenuItemData(
                  icon: Icons.bug_report,
                  title: '🧪 Prueba Notificaciones',
                  subtitle: 'Pantalla de pruebas (solo desarrollo)',
                  iconColor: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TestNotificationsScreen(),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Botón de cerrar sesión
          _buildLogoutButton(context, authProvider, l10n),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGuestView(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Logo y mensaje de bienvenida
          const AppLogo(height: 100),
          const SizedBox(height: 24),

          Text(
            l10n.profileLoginPrompt,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            'Descubre, guarda y comparte las mejores playas de República Dominicana',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Características
          _buildFeatureItem(
            icon: Icons.favorite,
            title: l10n.profileSaveBeaches,
            color: const Color(0xFFFF4081),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.wb_sunny,
            title: l10n.profileCheckWeather,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.people,
            title: l10n.profileShareCommunity,
            color: AppColors.primary,
          ),
          const SizedBox(height: 40),

          // Botones de acción
          _buildLoginButton(context, l10n),
          const SizedBox(height: 12),
          _buildSignupButton(context, l10n),
          const SizedBox(height: 32),

          // Anuncio banner
          _buildAdBanner(),
          const SizedBox(height: 32),

          // Opciones generales (sin autenticación)
          _buildMenuSection(
            title: 'General',
            items: [
              _MenuItemData(
                icon: Icons.settings,
                title: l10n.profileSettings,
                subtitle: l10n.profileSettingsPreferences,
                iconColor: AppColors.primary,
                onTap: () {
                  _showInterstitialAdAndNavigate(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  });
                },
              ),
              _MenuItemData(
                icon: Icons.help,
                title: l10n.profileHelp,
                subtitle: l10n.profileHelpFAQ,
                iconColor: Colors.blue,
                onTap: () {
                  _showInterstitialAdAndNavigate(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    );
                  });
                },
              ),
              _MenuItemData(
                icon: Icons.info,
                title: l10n.profileAbout,
                subtitle: l10n.profileAboutVersion,
                iconColor: Colors.teal,
                onTap: () {
                  _showAboutDialog(context, l10n);
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations l10n,
    int favoriteCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.favorite,
            count: favoriteCount,
            label: l10n.profileFavorites,
            color: const Color(0xFFFF4081),
          ),
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              return Container(
                height: 50,
                width: 1,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              );
            },
          ),
          _buildStatItem(
            icon: Icons.report,
            count: authProvider.appUser?.reportsCount ?? 0,
            label: l10n.profileReports,
            color: Colors.orange,
          ),
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              return Container(
                height: 50,
                width: 1,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              );
            },
          ),
          _buildStatItem(
            icon: Icons.beach_access,
            count: authProvider.appUser?.visitedBeaches.length ?? 0,
            label: l10n.profileVisited,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gradientTop,
            AppColors.gradientTop.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          l10n.profileLogin,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSignupButton(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(isSignUp: true),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          l10n.profileSignup,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItemData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == items.length - 1;

                  return Column(
                    children: [
                      _buildMenuItem(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        iconColor: item.iconColor,
                        onTap: item.onTap,
                      ),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.only(left: 72),
                          child: Divider(
                            height: 1,
                            color: isDark ? Colors.grey[700] : Colors.grey[200],
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          size: 20,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.logout, color: Colors.red, size: 24),
        ),
        title: Text(
          l10n.profileLogout,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.red,
            size: 20,
          ),
        ),
        onTap: () => _showLogoutDialog(context, authProvider, l10n),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.profileLogout,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          l10n.profileLogoutConfirm,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: const BannerAdWidget(
        adSize: AdSize.banner,
        useHotelRestaurantTargeting: true,
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const AppLogo.small(),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Playas RD',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Versión 1.0.0',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              'Descubre las mejores playas de República Dominicana. Consulta el clima, guarda tus favoritas y comparte con la comunidad.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 Playas RD',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cerrar',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo para seleccionar foto de perfil
  Future<void> _showPhotoPickerDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Cambiar foto de perfil',
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: 32,
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar la cámara'),
                onTap: () =>
                    Navigator.of(dialogContext).pop(ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: AppColors.primary.withOpacity(0.05),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                  size: 32,
                ),
                title: const Text('Seleccionar de galería'),
                subtitle: const Text('Elegir una foto existente'),
                onTap: () =>
                    Navigator.of(dialogContext).pop(ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: AppColors.primary.withOpacity(0.05),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );

    if (source == null || !mounted) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        await _uploadProfilePhoto(File(image.path), authProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al ${source == ImageSource.camera ? 'tomar' : 'seleccionar'} la imagen: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Subir foto de perfil
  Future<void> _uploadProfilePhoto(
    File imageFile,
    AuthProvider authProvider,
  ) async {
    if (!mounted) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final success = await authProvider.updateProfilePhoto(imageFile);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Foto de perfil actualizada con éxito!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ??
                  'Error al actualizar la foto de perfil',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la foto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });
}

// Widget helper para SliverToBody
class SliverToBody extends StatelessWidget {
  final Widget child;

  const SliverToBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: child);
  }
}

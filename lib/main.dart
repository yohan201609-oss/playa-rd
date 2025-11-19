import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/beach_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/report_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_initializer.dart';
import 'utils/constants.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlayasRDApp());
}

class PlayasRDApp extends StatefulWidget {
  const PlayasRDApp({super.key});

  @override
  State<PlayasRDApp> createState() => _PlayasRDAppState();
}

class _PlayasRDAppState extends State<PlayasRDApp> {
  late final Future<AppInitializationResult> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = AppInitializer().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppInitializationResult>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SimpleSplashScreen(),
          );
        }

        if (snapshot.hasError || !(snapshot.data?.isReady ?? false)) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _InitializationErrorScreen(error: snapshot.error),
          );
        }

        return _buildMainApp();
      },
    );
  }

  Widget _buildMainApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BeachProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ProxyProvider2<AuthProvider, BeachProvider, void>(
          update: (context, auth, beach, _) {
            if (auth.onFavoritesChanged == null) {
              auth.onFavoritesChanged = (favoriteIds) {
                print(
                  '🔄 Sincronizando ${favoriteIds.length} favoritos con las playas',
                );
                beach.syncFavorites(favoriteIds);
              };
            }
            if (auth.appUser != null) {
              print('👤 Usuario: ${auth.appUser!.email}');
              print(
                '💖 Favoritos del usuario: ${auth.appUser!.favoriteBeaches}',
              );
              beach.syncFavorites(auth.appUser!.favoriteBeaches);
            } else {
              print('👤 No hay usuario autenticado');
              beach.syncFavorites([]);
            }
            return;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          final locale = settings.getLocale();

          return MaterialApp(
            key: ValueKey('app_${settings.language}'),
            title: 'Playas RD',
            debugShowCheckedModeBanner: false,
            themeMode: settings.getFlutterThemeMode(),
            locale: locale,
            supportedLocales: const [Locale('es', ''), Locale('en', '')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: MainScreen(key: ValueKey('main_${settings.language}')),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        secondary: AppColors.secondary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        secondary: AppColors.secondary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _buildScreens(String language) {
    return <Widget>[
      HomeScreen(key: ValueKey('home_$language')),
      MapScreen(key: ValueKey('map_$language')),
      ReportScreen(key: ValueKey('report_$language')),
      ProfileScreen(key: ValueKey('profile_$language')),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);
    final screens = _buildScreens(settings.language);

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: _onItemTapped,
        elevation: 8,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: l10n.navMap,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            activeIcon: const Icon(Icons.add_circle),
            label: l10n.navReport,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

class _InitializationErrorScreen extends StatelessWidget {
  final Object? error;

  const _InitializationErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    final details = error != null ? 'Detalles: $error' : '';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 72,
              ),
              const SizedBox(height: 16),
              const Text(
                'No pudimos preparar la app',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                details.isEmpty
                    ? 'Revisa tu conexión e intenta nuevamente.'
                    : 'Revisa tu conexión e intenta nuevamente.\n$details',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

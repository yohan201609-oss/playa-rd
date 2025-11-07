import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/beach_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/report_screen.dart';
import 'screens/profile_screen.dart';
import 'services/firebase_service.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'utils/constants.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SharedPreferences
  try {
    await PreferencesService.init();
    print('✅ Preferencias inicializadas');
  } catch (e) {
    print('⚠️ Error inicializando preferencias: $e');
  }

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Variables de entorno cargadas');
  } catch (e) {
    print('⚠️ No se pudo cargar .env: $e');
    print('El servicio de clima no estará disponible');
  }

  // Inicializar Firebase con configuración de plataforma
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');

    // Sincronizar playas locales con Firestore (solo la primera vez)
    try {
      await FirebaseService.syncBeachesToFirestore();
    } catch (e) {
      print('⚠️ Error sincronizando playas: $e');
    }
  } catch (e) {
    print('⚠️ Firebase no configurado: $e');
    print('La app funcionará con datos locales sin autenticación');
  }

  // Inicializar servicio de notificaciones
  try {
    await NotificationService().initialize();
    print('✅ Servicio de notificaciones inicializado');
  } catch (e) {
    print('⚠️ Error inicializando notificaciones: $e');
    print('Las notificaciones no estarán disponibles');
  }

  runApp(const PlayasRDApp());
}

class PlayasRDApp extends StatelessWidget {
  const PlayasRDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BeachProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        // Conectar AuthProvider con BeachProvider para sincronizar favoritos
        ProxyProvider2<AuthProvider, BeachProvider, void>(
          update: (context, auth, beach, _) {
            // Configurar el callback una sola vez
            if (auth.onFavoritesChanged == null) {
              auth.onFavoritesChanged = (favoriteIds) {
                print(
                  '🔄 Sincronizando ${favoriteIds.length} favoritos con las playas',
                );
                beach.syncFavorites(favoriteIds);
              };
            }
            // Sincronizar favoritos cada vez que auth cambie
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
          return MaterialApp(
            title: 'Playas RD',
            debugShowCheckedModeBanner: false,
            themeMode: settings.getFlutterThemeMode(),
            locale: settings.getLocale(),
            supportedLocales: const [Locale('es', ''), Locale('en', '')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const MainScreen(),
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

  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const MapScreen(),
    const ReportScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_selectedIndex],
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

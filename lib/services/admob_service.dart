import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'dart:io';

/// Servicio para manejar AdMob (anuncios de Google)
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool _initialized = false;
  // Usar anuncios de producción por defecto
  // Cambiar a true solo si necesitas probar con anuncios de prueba
  bool _isTestMode = false; // false = producción, true = test

  // IDs de anuncios de prueba (para desarrollo)
  // Reemplaza estos con tus IDs reales cuando estés listo para producción
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // IDs de producción
  static const String _productionBannerAdUnitId = 'ca-app-pub-2612958934827252/5832453782';
  static const String _productionInterstitialAdUnitId = 'ca-app-pub-2612958934827252/7996540555';
  // TODO: Crear unidad de anuncio recompensado en AdMob y actualizar este ID
  static const String _productionRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  /// IDs de anuncios según el modo (test o producción)
  String get bannerAdUnitId => _isTestMode ? _testBannerAdUnitId : _productionBannerAdUnitId;
  String get interstitialAdUnitId => _isTestMode ? _testInterstitialAdUnitId : _productionInterstitialAdUnitId;
  String get rewardedAdUnitId => _isTestMode ? _testRewardedAdUnitId : _productionRewardedAdUnitId;

  /// Inicializar AdMob
  Future<void> initialize() async {
    if (_initialized) {
      print('✅ AdMobService ya está inicializado');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      print('✅ AdMobService inicializado correctamente');
      print('📱 Modo: ${_isTestMode ? "TEST" : "PRODUCCIÓN"}');
      print('📱 Plataforma: ${Platform.isAndroid ? "Android" : "iOS"}');
    } catch (e) {
      print('❌ Error inicializando AdMob: $e');
      rethrow;
    }
  }

  /// Verificar si AdMob está inicializado
  bool get isInitialized => _initialized;

  /// Cambiar entre modo test y producción
  void setTestMode(bool testMode) {
    _isTestMode = testMode;
    print('📱 Modo AdMob cambiado a: ${_isTestMode ? "TEST" : "PRODUCCIÓN"}');
  }

  /// Obtener un RequestConfiguration personalizado (opcional)
  RequestConfiguration getRequestConfiguration() {
    return RequestConfiguration(
      testDeviceIds: _isTestMode ? ['test-device-id'] : [],
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
    );
  }

  /// Configurar RequestConfiguration
  Future<void> configureRequest() async {
    try {
      await MobileAds.instance.updateRequestConfiguration(getRequestConfiguration());
      print('✅ RequestConfiguration configurado');
    } catch (e) {
      print('❌ Error configurando RequestConfiguration: $e');
    }
  }

  /// Crear un AdRequest personalizado para anuncios de hoteles y restaurantes
  /// 
  /// NOTA: AdMob no ofrece categorías de contenido en el dashboard para unidades individuales.
  /// El targeting se realiza mediante palabras clave (keywords) en el código, que es
  /// la forma más efectiva de segmentar anuncios por categoría.
  /// 
  /// Este método incluye más de 40 palabras clave organizadas por categorías:
  /// - Hoteles y alojamiento
  /// - Restaurantes y gastronomía  
  /// - Turismo y viajes
  /// - Playas y destinos
  AdRequest createHotelRestaurantAdRequest({
    List<String>? additionalKeywords,
    String? contentUrl,
    // Parámetros adicionales para targeting
    String? beachName,
    String? province,
  }) {
    // Palabras clave relacionadas con hoteles y restaurantes
    // Priorizadas para maximizar anuncios de turismo y evitar anuncios genéricos
    final keywords = <String>[
      // Categoría: Hoteles y Alojamiento (prioridad alta)
      'hotel',
      'hoteles',
      'resort',
      'all-inclusive',
      'all inclusive',
      'alojamiento',
      'hospedaje',
      'accommodation',
      'hotel booking',
      'reservación hotel',
      'reservas hotel',
      'booking hotel',
      'pension',
      'hostal',
      'villa',
      'apartamento turistico',
      'tourist accommodation',
      
      // Categoría: Restaurantes y Gastronomía (prioridad alta)
      'restaurante',
      'restaurantes',
      'comida local',
      'gastronomía dominicana',
      'dining',
      'restaurant',
      'cocina caribeña',
      'chef',
      'mariscos',
      'seafood',
      'comida tipica',
      'traditional food',
      
      // Categoría: Turismo y Viajes (prioridad alta)
      'turismo',
      'turismo dominicano',
      'viajes',
      'vacaciones',
      'travel',
      'viaje',
      'tourism',
      'vacation',
      'trip',
      'tour',
      'excursion',
      'travel agency',
      'agencia de viajes',
      'tour operator',
      
      // Categoría: Playas y Destinos (prioridad alta)
      'playa',
      'playas',
      'beach',
      'beaches',
      'beach resort',
      'resort playa',
      'caribbean',
      'caribe',
      'republica dominicana',
      'dominican republic',
      'punta cana',
      'bavaro',
      'puerto plata',
      'santo domingo',
      'tropical',
      'paradise',
      'beach vacation',
      'vacaciones playa',
      
      // Categoría: Actividades turísticas
      'snorkeling',
      'buceo',
      'diving',
      'excursion',
      'tour guiado',
      'guided tour',
      'actividades acuaticas',
      'water activities',
    ];

    // Agregar palabras clave adicionales si se proporcionan
    if (additionalKeywords != null && additionalKeywords.isNotEmpty) {
      keywords.addAll(additionalKeywords);
    }

    // Agregar palabras clave específicas del contexto si están disponibles
    if (beachName != null && beachName.isNotEmpty) {
      keywords.add(beachName.toLowerCase());
    }
    if (province != null && province.isNotEmpty) {
      keywords.add(province.toLowerCase());
    }

    // Construir contentUrl si no se proporciona pero hay contexto de playa
    String? finalContentUrl = contentUrl;
    if (finalContentUrl == null) {
      // URL contextual que ayuda al targeting - más específica para turismo
      if (beachName != null) {
        finalContentUrl = 'https://playasrd.com/beach/${beachName.toLowerCase().replaceAll(' ', '-')}';
      } else {
        // URL genérica pero específica de turismo en República Dominicana
        finalContentUrl = 'https://playasrd.com/turismo-republica-dominicana';
      }
    }

    return AdRequest(
      keywords: keywords,
      contentUrl: finalContentUrl,
      // Las palabras clave son la forma principal de targeting en AdMob
      // Google utiliza estas palabras clave para mostrar anuncios relevantes
      // de hoteles, restaurantes y turismo
      // NOTA: AdMob no garantiza qué anuncios específicos se mostrarán,
      // pero estas palabras clave ayudan a priorizar anuncios relevantes
    );
  }
}

/// Widget para mostrar anuncios banner
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final String? adUnitId;
  final bool useHotelRestaurantTargeting;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.adUnitId,
    this.useHotelRestaurantTargeting = true,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Verificar que AdMob esté inicializado
    final adService = AdMobService();
    if (!adService.isInitialized) {
      print('⚠️ AdMob no está inicializado. Esperando inicialización...');
      // Esperar un poco y reintentar
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _loadBannerAd();
      });
      return;
    }

    final adUnitId = widget.adUnitId ?? adService.bannerAdUnitId;

    // Usar AdRequest personalizado para hoteles y restaurantes si está habilitado
    final adRequest = widget.useHotelRestaurantTargeting
        ? adService.createHotelRestaurantAdRequest()
        : const AdRequest();

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: widget.adSize,
      request: adRequest,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
            _retryCount = 0; // Resetear contador en éxito
          });
          print('✅ Anuncio banner cargado (hoteles y restaurantes)');
        },
        onAdFailedToLoad: (ad, error) {
          _handleAdLoadError(ad as BannerAd, error);
        },
        onAdOpened: (_) => print('📱 Anuncio banner abierto'),
        onAdClosed: (_) => print('📱 Anuncio banner cerrado'),
      ),
    );

    _bannerAd?.load();
  }

  void _handleAdLoadError(BannerAd ad, LoadAdError error) {
    ad.dispose();
    _isAdLoaded = false;

    // Mensajes de error más descriptivos
    final errorCode = error.code;
    final errorMessage = error.message;
    final errorDomain = error.domain;

    print('❌ Error cargando anuncio banner:');
    print('   Código: $errorCode');
    print('   Dominio: $errorDomain');
    print('   Mensaje: $errorMessage');

    // Manejar errores específicos
    switch (errorCode) {
      case 0: // ERROR_CODE_INTERNAL_ERROR
        print('   ⚠️ Error interno de AdMob');
        break;
      case 1: // ERROR_CODE_INVALID_REQUEST
        print('   ⚠️ Solicitud inválida - Verifica el Ad Unit ID');
        break;
      case 2: // ERROR_CODE_NETWORK_ERROR
        print('   ⚠️ Error de red - Verifica la conexión a internet');
        // Reintentar solo si no hemos excedido el máximo
        if (_retryCount < _maxRetries) {
          _retryOnNetworkError();
          return; // Reintentar, no mostrar error final
        }
        break;
      case 3: // ERROR_CODE_NO_FILL
        print('   ⚠️ No hay anuncios disponibles en este momento');
        break;
      case 8: // ERROR_CODE_APP_ID_MISSING
        print('   ⚠️ App ID de AdMob faltante - Verifica AndroidManifest.xml');
        break;
      default:
        print('   ⚠️ Error desconocido');
    }

    // Si llegamos aquí, no se puede reintentar o no es un error de red
    setState(() {
      _isAdLoaded = false;
    });
  }

  void _retryOnNetworkError() {
    if (_retryCount >= _maxRetries) {
      print('❌ Máximo de reintentos alcanzado ($_maxRetries). No se mostrará el anuncio.');
      setState(() {
        _isAdLoaded = false;
      });
      return;
    }

    _retryCount++;
    final delay = Duration(seconds: _retryDelay.inSeconds * _retryCount);
    print('🔄 Reintentando cargar anuncio en ${delay.inSeconds} segundos (intento $_retryCount/$_maxRetries)...');

    Future.delayed(delay, () {
      if (mounted) {
        _loadBannerAd();
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Clase helper para manejar anuncios intersticiales
class InterstitialAdHelper {
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  final bool _useHotelRestaurantTargeting;
  VoidCallback? _onAdDismissed;
  VoidCallback? _onAdFailedToShow;

  InterstitialAdHelper({
    bool useHotelRestaurantTargeting = true,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  })  : _useHotelRestaurantTargeting = useHotelRestaurantTargeting,
        _onAdDismissed = onAdDismissed,
        _onAdFailedToShow = onAdFailedToShow;

  /// Cargar un anuncio intersticial
  Future<void> loadInterstitialAd() async {
    final adService = AdMobService();
    
    // Usar AdRequest personalizado para hoteles y restaurantes si está habilitado
    final adRequest = _useHotelRestaurantTargeting
        ? adService.createHotelRestaurantAdRequest()
        : const AdRequest();

    await InterstitialAd.load(
      adUnitId: adService.interstitialAdUnitId,
      request: adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;
          print('✅ Anuncio intersticial cargado (hoteles y restaurantes)');
          _setFullScreenContentCallback();
        },
        onAdFailedToLoad: (error) {
          print('❌ Error cargando anuncio intersticial: $error');
          _isAdReady = false;
        },
      ),
    );
  }

  void _setFullScreenContentCallback() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAdReady = false;
        print('📱 Anuncio intersticial cerrado');
        // Ejecutar callback personalizado si existe
        _onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isAdReady = false;
        print('❌ Error mostrando anuncio intersticial: $error');
        // Ejecutar callback personalizado si existe
        _onAdFailedToShow?.call();
      },
    );
  }

  /// Mostrar el anuncio intersticial
  Future<bool> showInterstitialAd() async {
    if (_isAdReady && _interstitialAd != null) {
      await _interstitialAd!.show();
      return true;
    }
    return false;
  }

  /// Actualizar callbacks después de cargar el anuncio
  void updateCallbacks({
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) {
    _onAdDismissed = onAdDismissed;
    _onAdFailedToShow = onAdFailedToShow;
    // Reconfigurar callbacks si el anuncio ya está cargado
    if (_isAdReady) {
      _setFullScreenContentCallback();
    }
  }

  /// Verificar si el anuncio está listo
  bool get isAdReady => _isAdReady;

  /// Liberar recursos
  void dispose() {
    _interstitialAd?.dispose();
    _isAdReady = false;
  }
}

/// Clase helper para manejar anuncios con recompensa
class RewardedAdHelper {
  RewardedAd? _rewardedAd;
  bool _isAdReady = false;
  final bool _useHotelRestaurantTargeting;

  RewardedAdHelper({bool useHotelRestaurantTargeting = true})
      : _useHotelRestaurantTargeting = useHotelRestaurantTargeting;

  /// Cargar un anuncio con recompensa
  Future<void> loadRewardedAd() async {
    final adService = AdMobService();
    
    // Usar AdRequest personalizado para hoteles y restaurantes si está habilitado
    final adRequest = _useHotelRestaurantTargeting
        ? adService.createHotelRestaurantAdRequest()
        : const AdRequest();

    await RewardedAd.load(
      adUnitId: adService.rewardedAdUnitId,
      request: adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdReady = true;
          print('✅ Anuncio con recompensa cargado (hoteles y restaurantes)');
          _setFullScreenContentCallback();
        },
        onAdFailedToLoad: (error) {
          print('❌ Error cargando anuncio con recompensa: $error');
          _isAdReady = false;
        },
      ),
    );
  }

  void _setFullScreenContentCallback() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAdReady = false;
        print('📱 Anuncio con recompensa cerrado');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isAdReady = false;
        print('❌ Error mostrando anuncio con recompensa: $error');
      },
    );
  }

  /// Mostrar el anuncio con recompensa
  Future<bool> showRewardedAd({
    required Function(RewardItem) onRewarded,
    Function()? onAdFailedToShow,
  }) async {
    if (_isAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded(reward);
        },
      );
      return true;
    } else {
      onAdFailedToShow?.call();
      return false;
    }
  }

  /// Verificar si el anuncio está listo
  bool get isAdReady => _isAdReady;

  /// Liberar recursos
  void dispose() {
    _rewardedAd?.dispose();
    _isAdReady = false;
  }
}

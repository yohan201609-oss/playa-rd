// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Playas RD';

  @override
  String get appDescription =>
      'Descubre las mejores playas de República Dominicana';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get share => 'Compartir';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get navHome => 'Inicio';

  @override
  String get navMap => 'Mapa';

  @override
  String get navReport => 'Reportar';

  @override
  String get navProfile => 'Perfil';

  @override
  String get homeTitle => 'Playas RD';

  @override
  String get homeSearchHint => 'Buscar playas...';

  @override
  String get homeFilterAll => 'Todas';

  @override
  String get homeFilterFavorites => 'Favoritos';

  @override
  String get homeFilters => 'Filtros';

  @override
  String get homeClearFilters => 'Limpiar';

  @override
  String get homeSortBy => 'Ordenar por';

  @override
  String get homeSortRating => 'Calificación';

  @override
  String get homeSortName => 'Nombre';

  @override
  String get homeSortCondition => 'Condición';

  @override
  String get homeApplyFilters => 'Aplicar';

  @override
  String get homeLoginToSaveFavorites => 'Inicia sesión para guardar favoritos';

  @override
  String get homeNoBeaches => 'No se encontraron playas';

  @override
  String get homeNoFavorites => 'Aún no tienes playas favoritas';

  @override
  String homeBeachesCount(int count) {
    return '$count playas encontradas';
  }

  @override
  String get beachCondition => 'Condición';

  @override
  String get beachActivities => 'Actividades';

  @override
  String get beachAmenities => 'Servicios';

  @override
  String get beachLocation => 'Ubicación';

  @override
  String get beachWeather => 'Clima';

  @override
  String get beachReports => 'Reportes';

  @override
  String get beachNoReports => 'No hay reportes aún';

  @override
  String get beachGetDirections => 'Cómo llegar';

  @override
  String get beachAddToFavorites => 'Agregar a favoritos';

  @override
  String get beachRemoveFromFavorites => 'Quitar de favoritos';

  @override
  String get beachShareBeach => 'Compartir playa';

  @override
  String get beachMarkAsVisited => 'Marcar como visitada';

  @override
  String get beachAlreadyVisited => 'Ya visitada';

  @override
  String get beachDescription => 'Descripción';

  @override
  String get conditionExcellent => 'Excelente';

  @override
  String get conditionGood => 'Bueno';

  @override
  String get conditionModerate => 'Moderado';

  @override
  String get conditionDanger => 'Peligroso';

  @override
  String get conditionUnknown => 'Desconocido';

  @override
  String get activitySwimming => 'Natación';

  @override
  String get activitySurfing => 'Surf';

  @override
  String get activitySnorkeling => 'Snorkel';

  @override
  String get activityDiving => 'Buceo';

  @override
  String get activityKayaking => 'Kayak';

  @override
  String get activityFishing => 'Pesca';

  @override
  String get activityVolleyball => 'Voleibol';

  @override
  String get activityJetski => 'Moto acuática';

  @override
  String get activityEcotourism => 'Ecoturismo';

  @override
  String get activityPhotography => 'Fotografía';

  @override
  String get activityRelaxation => 'Relajación';

  @override
  String get activityTranquility => 'Tranquilidad';

  @override
  String get activityAdventure => 'Aventura';

  @override
  String get activityHiking => 'Caminata';

  @override
  String get activityNature => 'Naturaleza';

  @override
  String get activitySunset => 'Atardecer';

  @override
  String get activityRiver => 'Río';

  @override
  String get activityFamilies => 'Familias';

  @override
  String get mapTitle => 'Mapa';

  @override
  String mapTitleWithCount(int count) {
    return 'Mapa de Playas ($count)';
  }

  @override
  String get mapShowList => 'Mostrar lista';

  @override
  String get mapMyLocation => 'Mi ubicación';

  @override
  String get mapError => 'Error al cargar el mapa';

  @override
  String get mapLocationPermission => 'Permiso de ubicación denegado';

  @override
  String get mapClear => 'Limpiar';

  @override
  String get mapProvince => 'Provincia';

  @override
  String get mapApplyFilters => 'Aplicar filtros';

  @override
  String get reportTitle => 'Reportar Condición';

  @override
  String get reportHelpCommunity => 'Ayuda a la comunidad';

  @override
  String get reportHelpDescription =>
      'Reporta las condiciones actuales de una playa';

  @override
  String get reportWhichBeach => '¿Qué playa visitaste?';

  @override
  String get reportSelectBeach => 'Selecciona una playa';

  @override
  String get reportHowConditions => '¿Cómo están las condiciones?';

  @override
  String get reportCondition => 'Condición de la playa';

  @override
  String get reportAddComment => 'Agrega un comentario';

  @override
  String get reportCommentOptional => 'Comentario (opcional)';

  @override
  String get reportDescription => 'Descripción (opcional)';

  @override
  String get reportDescriptionHint => 'Describe las condiciones actuales...';

  @override
  String get reportAddPhotos => 'Agregar fotos';

  @override
  String get reportPhotos => 'Fotos';

  @override
  String get reportPhotoFrom => 'Foto desde';

  @override
  String get reportCamera => 'Cámara';

  @override
  String get reportGallery => 'Galería';

  @override
  String get reportTakePhoto => 'Tomar foto';

  @override
  String get reportSelectFromGallery => 'Seleccionar de galería';

  @override
  String get reportMaxPhotos => 'Máximo 3 fotos';

  @override
  String get reportSubmit => 'Enviar reporte';

  @override
  String get reportSubmitting => 'Enviando...';

  @override
  String get reportSuccess => 'Reporte enviado correctamente';

  @override
  String get reportError => 'Error al enviar el reporte';

  @override
  String get reportSelectBeachFirst => 'Por favor selecciona una playa primero';

  @override
  String get reportSelectCondition => 'Por favor selecciona una condición';

  @override
  String get profileTitle => 'Mi Perfil';

  @override
  String get profileWelcome => 'Bienvenido a';

  @override
  String get profileDiscoverBeaches => 'Descubre las mejores playas';

  @override
  String get profileLogin => 'Iniciar sesión';

  @override
  String get profileSignup => 'Crear cuenta nueva';

  @override
  String get profileSaveBeaches => 'Guarda tus playas favoritas';

  @override
  String get profileCheckWeather => 'Consulta el clima en tiempo real';

  @override
  String get profileShareCommunity => 'Comparte con la comunidad';

  @override
  String get profileFavorites => 'Favoritos';

  @override
  String get profileReports => 'Reportes';

  @override
  String get profileVisited => 'Visitadas';

  @override
  String get profileMyFavorites => 'Mis Favoritos';

  @override
  String get profileFavoritesBeaches => 'Playas que me gustan';

  @override
  String get profileMyReports => 'Mis Reportes';

  @override
  String get profileReportsSent => 'Reportes enviados';

  @override
  String get profileSettings => 'Configuración';

  @override
  String get profileSettingsPreferences => 'Preferencias de la app';

  @override
  String get profileHelp => 'Ayuda';

  @override
  String get profileHelpFAQ => 'Preguntas frecuentes';

  @override
  String get profileAbout => 'Acerca de';

  @override
  String get profileAboutVersion => 'Versión y créditos';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileLogoutConfirm => '¿Estás seguro que deseas cerrar sesión?';

  @override
  String get profileLoginPrompt => 'Inicia sesión para disfrutar';

  @override
  String get profileLoginDescription =>
      'Guarda tus playas favoritas y\ncomparte con la comunidad';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Según el sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeAuto => 'Sistema';

  @override
  String get settingsUnits => 'Unidades';

  @override
  String get settingsTemperature => 'Unidad de temperatura';

  @override
  String get settingsCelsius => 'Celsius (°C)';

  @override
  String get settingsFahrenheit => 'Fahrenheit (°F)';

  @override
  String get settingsNotifications => 'Notificaciones y Permisos';

  @override
  String get settingsNotificationsEnable => 'Notificaciones';

  @override
  String get settingsNotificationsDesc => 'Recibir alertas y actualizaciones';

  @override
  String get settingsLocation => 'Ubicación';

  @override
  String get settingsLocationDesc => 'Permitir acceso a tu ubicación';

  @override
  String get settingsDataSync => 'Datos y Sincronización';

  @override
  String get settingsAutoSync => 'Sincronización automática';

  @override
  String get settingsAutoSyncDesc => 'Sincronizar datos automáticamente';

  @override
  String get settingsDataCollection => 'Recopilación de datos';

  @override
  String get settingsDataCollectionDesc => 'Ayudar a mejorar la app';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAdvanced => 'Avanzado';

  @override
  String get settingsClearCache => 'Limpiar caché';

  @override
  String get settingsClearCacheDesc => 'Liberar espacio de almacenamiento';

  @override
  String get settingsClearCacheConfirm =>
      '¿Estás seguro que deseas limpiar el caché? Esto eliminará las imágenes y datos temporales para liberar espacio.';

  @override
  String get settingsClearCacheSuccess => 'Caché limpiado correctamente';

  @override
  String get settingsResetSettings => 'Restablecer configuración';

  @override
  String get settingsResetSettingsDesc => 'Volver a valores por defecto';

  @override
  String get settingsResetConfirm =>
      '¿Estás seguro que deseas restablecer todas las configuraciones a sus valores por defecto?';

  @override
  String get settingsResetSuccess => 'Configuración restablecida';

  @override
  String get weatherCurrent => 'Clima Actual';

  @override
  String weatherFeelsLike(String temp) {
    return 'Sensación $temp';
  }

  @override
  String get weatherHumidity => 'Humedad';

  @override
  String get weatherWind => 'Viento';

  @override
  String get weatherUVIndex => 'Índice UV';

  @override
  String get weatherPressure => 'Presión';

  @override
  String get weatherVisibility => 'Visibilidad';

  @override
  String get weatherCloudiness => 'Nubosidad';

  @override
  String get weatherSunrise => 'Amanecer';

  @override
  String get weatherSunset => 'Atardecer';

  @override
  String get weatherLoading => 'Cargando clima...';

  @override
  String get weatherError => 'Error al cargar clima';

  @override
  String get weatherRefresh => 'Actualizar';

  @override
  String get weatherRecommendationExcellent => 'Excelente para la playa';

  @override
  String weatherRecommendationNotRecommended(String reason) {
    return 'No recomendado - $reason';
  }

  @override
  String weatherRecommendationWarning(String reason) {
    return 'Advertencia - $reason';
  }

  @override
  String weatherRecommendationCaution(String reason) {
    return 'Precaución - $reason';
  }

  @override
  String get weatherRecommendationCool =>
      'Fresco - Puede estar frío para nadar';

  @override
  String get weatherReasonThunderstorm => 'Tormenta eléctrica';

  @override
  String get weatherReasonRain => 'Lluvia';

  @override
  String get weatherReasonStrongWinds => 'Vientos fuertes';

  @override
  String get weatherReasonHighUV => 'Índice UV muy alto';

  @override
  String get weatherReasonHighTemperature => 'Temperatura muy alta';

  @override
  String get authLogin => 'Iniciar Sesión';

  @override
  String get authSignup => 'Crear Cuenta';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authName => 'Nombre completo';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authNoAccount => '¿No tienes cuenta?';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get authSignInWith => 'O inicia sesión con';

  @override
  String get authGoogle => 'Google';

  @override
  String get authEmailError => 'Por favor ingresa un correo válido';

  @override
  String get authPasswordError =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authNameError => 'Por favor ingresa tu nombre';

  @override
  String get authSuccess => '¡Bienvenido!';

  @override
  String get authError => 'Error al autenticar';

  @override
  String get aboutVersion => 'Versión 1.0.0';

  @override
  String get aboutDescription =>
      'Descubre las mejores playas de República Dominicana 🇩🇴';

  @override
  String get aboutDevelopedWith => 'Desarrollado con amor para los dominicanos';

  @override
  String get errorGeneric => 'Ocurrió un error inesperado';

  @override
  String get errorNetwork => 'Error de conexión';

  @override
  String get errorNoInternet => 'Sin conexión a internet';

  @override
  String get errorLocationPermission => 'Permiso de ubicación denegado';

  @override
  String get errorLocationDisabled => 'Ubicación desactivada';

  @override
  String get errorCameraPermission => 'Permiso de cámara denegado';

  @override
  String get errorPhotoLibrary => 'Error al acceder a la galería';
}

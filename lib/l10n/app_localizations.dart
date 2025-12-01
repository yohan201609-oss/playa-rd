import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Playas RD'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In es, this message translates to:
  /// **'Descubre las mejores playas de República Dominicana'**
  String get appDescription;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In es, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get navMap;

  /// No description provided for @navReport.
  ///
  /// In es, this message translates to:
  /// **'Reportar'**
  String get navReport;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'Playas RD'**
  String get homeTitle;

  /// No description provided for @homeSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar playas...'**
  String get homeSearchHint;

  /// No description provided for @homeFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get homeFilterAll;

  /// No description provided for @homeFilterFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get homeFilterFavorites;

  /// No description provided for @homeFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get homeFilters;

  /// No description provided for @homeClearFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get homeClearFilters;

  /// No description provided for @homeSortBy.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por'**
  String get homeSortBy;

  /// No description provided for @homeSortRating.
  ///
  /// In es, this message translates to:
  /// **'Calificación'**
  String get homeSortRating;

  /// No description provided for @homeSortName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get homeSortName;

  /// No description provided for @homeSortCondition.
  ///
  /// In es, this message translates to:
  /// **'Condición'**
  String get homeSortCondition;

  /// No description provided for @homeApplyFilters.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get homeApplyFilters;

  /// No description provided for @homeLoginToSaveFavorites.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para guardar favoritos'**
  String get homeLoginToSaveFavorites;

  /// No description provided for @homeNoBeaches.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron playas'**
  String get homeNoBeaches;

  /// No description provided for @homeNoFavorites.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes playas favoritas'**
  String get homeNoFavorites;

  /// No description provided for @homeBeachesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} playas encontradas'**
  String homeBeachesCount(int count);

  /// No description provided for @beachCondition.
  ///
  /// In es, this message translates to:
  /// **'Condición'**
  String get beachCondition;

  /// No description provided for @beachActivities.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get beachActivities;

  /// No description provided for @beachAmenities.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get beachAmenities;

  /// No description provided for @beachLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get beachLocation;

  /// No description provided for @beachWeather.
  ///
  /// In es, this message translates to:
  /// **'Clima'**
  String get beachWeather;

  /// No description provided for @beachReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get beachReports;

  /// No description provided for @beachNoReports.
  ///
  /// In es, this message translates to:
  /// **'No hay reportes aún'**
  String get beachNoReports;

  /// No description provided for @beachGetDirections.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get beachGetDirections;

  /// No description provided for @beachNavigateWith.
  ///
  /// In es, this message translates to:
  /// **'Navegar con'**
  String get beachNavigateWith;

  /// No description provided for @beachNavigateGoogleMaps.
  ///
  /// In es, this message translates to:
  /// **'Google Maps'**
  String get beachNavigateGoogleMaps;

  /// No description provided for @beachNavigateWaze.
  ///
  /// In es, this message translates to:
  /// **'Waze'**
  String get beachNavigateWaze;

  /// No description provided for @beachWazeNotInstalled.
  ///
  /// In es, this message translates to:
  /// **'Waze no está instalado'**
  String get beachWazeNotInstalled;

  /// No description provided for @beachWazeNotInstalledDesc.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas instalar Waze desde la tienda de aplicaciones?'**
  String get beachWazeNotInstalledDesc;

  /// No description provided for @beachWazeError.
  ///
  /// In es, this message translates to:
  /// **'Waze no pudo abrir esta ubicación. ¿Deseas usar Google Maps en su lugar?'**
  String get beachWazeError;

  /// No description provided for @beachWazeInstall.
  ///
  /// In es, this message translates to:
  /// **'Instalar Waze'**
  String get beachWazeInstall;

  /// No description provided for @beachAddToFavorites.
  ///
  /// In es, this message translates to:
  /// **'Agregar a favoritos'**
  String get beachAddToFavorites;

  /// No description provided for @beachRemoveFromFavorites.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get beachRemoveFromFavorites;

  /// No description provided for @beachShareBeach.
  ///
  /// In es, this message translates to:
  /// **'Compartir playa'**
  String get beachShareBeach;

  /// No description provided for @beachMarkAsVisited.
  ///
  /// In es, this message translates to:
  /// **'Marcar como visitada'**
  String get beachMarkAsVisited;

  /// No description provided for @beachAlreadyVisited.
  ///
  /// In es, this message translates to:
  /// **'Ya visitada'**
  String get beachAlreadyVisited;

  /// No description provided for @beachDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get beachDescription;

  /// No description provided for @conditionExcellent.
  ///
  /// In es, this message translates to:
  /// **'Excelente'**
  String get conditionExcellent;

  /// No description provided for @conditionGood.
  ///
  /// In es, this message translates to:
  /// **'Bueno'**
  String get conditionGood;

  /// No description provided for @conditionModerate.
  ///
  /// In es, this message translates to:
  /// **'Moderado'**
  String get conditionModerate;

  /// No description provided for @conditionDanger.
  ///
  /// In es, this message translates to:
  /// **'Peligroso'**
  String get conditionDanger;

  /// No description provided for @conditionUnknown.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get conditionUnknown;

  /// No description provided for @activitySwimming.
  ///
  /// In es, this message translates to:
  /// **'Natación'**
  String get activitySwimming;

  /// No description provided for @activitySurfing.
  ///
  /// In es, this message translates to:
  /// **'Surf'**
  String get activitySurfing;

  /// No description provided for @activitySnorkeling.
  ///
  /// In es, this message translates to:
  /// **'Snorkel'**
  String get activitySnorkeling;

  /// No description provided for @activityDiving.
  ///
  /// In es, this message translates to:
  /// **'Buceo'**
  String get activityDiving;

  /// No description provided for @activityKayaking.
  ///
  /// In es, this message translates to:
  /// **'Kayak'**
  String get activityKayaking;

  /// No description provided for @activityFishing.
  ///
  /// In es, this message translates to:
  /// **'Pesca'**
  String get activityFishing;

  /// No description provided for @activityVolleyball.
  ///
  /// In es, this message translates to:
  /// **'Voleibol'**
  String get activityVolleyball;

  /// No description provided for @activityJetski.
  ///
  /// In es, this message translates to:
  /// **'Moto acuática'**
  String get activityJetski;

  /// No description provided for @activityEcotourism.
  ///
  /// In es, this message translates to:
  /// **'Ecoturismo'**
  String get activityEcotourism;

  /// No description provided for @activityPhotography.
  ///
  /// In es, this message translates to:
  /// **'Fotografía'**
  String get activityPhotography;

  /// No description provided for @activityRelaxation.
  ///
  /// In es, this message translates to:
  /// **'Relajación'**
  String get activityRelaxation;

  /// No description provided for @activityTranquility.
  ///
  /// In es, this message translates to:
  /// **'Tranquilidad'**
  String get activityTranquility;

  /// No description provided for @activityAdventure.
  ///
  /// In es, this message translates to:
  /// **'Aventura'**
  String get activityAdventure;

  /// No description provided for @activityHiking.
  ///
  /// In es, this message translates to:
  /// **'Caminata'**
  String get activityHiking;

  /// No description provided for @activityNature.
  ///
  /// In es, this message translates to:
  /// **'Naturaleza'**
  String get activityNature;

  /// No description provided for @activitySunset.
  ///
  /// In es, this message translates to:
  /// **'Atardecer'**
  String get activitySunset;

  /// No description provided for @activityRiver.
  ///
  /// In es, this message translates to:
  /// **'Río'**
  String get activityRiver;

  /// No description provided for @activityFamilies.
  ///
  /// In es, this message translates to:
  /// **'Familias'**
  String get activityFamilies;

  /// No description provided for @mapTitle.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get mapTitle;

  /// No description provided for @mapTitleWithCount.
  ///
  /// In es, this message translates to:
  /// **'Mapa de Playas ({count})'**
  String mapTitleWithCount(int count);

  /// No description provided for @mapShowList.
  ///
  /// In es, this message translates to:
  /// **'Mostrar lista'**
  String get mapShowList;

  /// No description provided for @mapMyLocation.
  ///
  /// In es, this message translates to:
  /// **'Mi ubicación'**
  String get mapMyLocation;

  /// No description provided for @mapError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el mapa'**
  String get mapError;

  /// No description provided for @mapLocationPermission.
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación denegado'**
  String get mapLocationPermission;

  /// No description provided for @mapClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get mapClear;

  /// No description provided for @mapProvince.
  ///
  /// In es, this message translates to:
  /// **'Provincia'**
  String get mapProvince;

  /// No description provided for @mapApplyFilters.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get mapApplyFilters;

  /// No description provided for @reportTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar Condición'**
  String get reportTitle;

  /// No description provided for @reportHelpCommunity.
  ///
  /// In es, this message translates to:
  /// **'Ayuda a la comunidad'**
  String get reportHelpCommunity;

  /// No description provided for @reportHelpDescription.
  ///
  /// In es, this message translates to:
  /// **'Reporta las condiciones actuales de una playa'**
  String get reportHelpDescription;

  /// No description provided for @reportWhichBeach.
  ///
  /// In es, this message translates to:
  /// **'¿Qué playa visitaste?'**
  String get reportWhichBeach;

  /// No description provided for @reportSelectBeach.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una playa'**
  String get reportSelectBeach;

  /// No description provided for @reportHowConditions.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo están las condiciones?'**
  String get reportHowConditions;

  /// No description provided for @reportCondition.
  ///
  /// In es, this message translates to:
  /// **'Condición de la playa'**
  String get reportCondition;

  /// No description provided for @reportAddComment.
  ///
  /// In es, this message translates to:
  /// **'Agrega un comentario'**
  String get reportAddComment;

  /// No description provided for @reportCommentOptional.
  ///
  /// In es, this message translates to:
  /// **'Comentario (opcional)'**
  String get reportCommentOptional;

  /// No description provided for @reportDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get reportDescription;

  /// No description provided for @reportDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Describe las condiciones actuales...'**
  String get reportDescriptionHint;

  /// No description provided for @reportAddPhotos.
  ///
  /// In es, this message translates to:
  /// **'Agregar fotos'**
  String get reportAddPhotos;

  /// No description provided for @reportPhotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get reportPhotos;

  /// No description provided for @reportPhotoFrom.
  ///
  /// In es, this message translates to:
  /// **'Foto desde'**
  String get reportPhotoFrom;

  /// No description provided for @reportCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get reportCamera;

  /// No description provided for @reportGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get reportGallery;

  /// No description provided for @reportTakePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get reportTakePhoto;

  /// No description provided for @reportSelectFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar de galería'**
  String get reportSelectFromGallery;

  /// No description provided for @reportMaxPhotos.
  ///
  /// In es, this message translates to:
  /// **'Máximo 3 fotos'**
  String get reportMaxPhotos;

  /// No description provided for @reportSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar reporte'**
  String get reportSubmit;

  /// No description provided for @reportSubmitting.
  ///
  /// In es, this message translates to:
  /// **'Enviando...'**
  String get reportSubmitting;

  /// No description provided for @reportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Reporte enviado correctamente'**
  String get reportSuccess;

  /// No description provided for @reportError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar el reporte'**
  String get reportError;

  /// No description provided for @reportSelectBeachFirst.
  ///
  /// In es, this message translates to:
  /// **'Por favor selecciona una playa primero'**
  String get reportSelectBeachFirst;

  /// No description provided for @reportSelectCondition.
  ///
  /// In es, this message translates to:
  /// **'Por favor selecciona una condición'**
  String get reportSelectCondition;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get profileTitle;

  /// No description provided for @profileWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a'**
  String get profileWelcome;

  /// No description provided for @profileDiscoverBeaches.
  ///
  /// In es, this message translates to:
  /// **'Descubre las mejores playas'**
  String get profileDiscoverBeaches;

  /// No description provided for @profileLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get profileLogin;

  /// No description provided for @profileSignup.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta nueva'**
  String get profileSignup;

  /// No description provided for @profileSaveBeaches.
  ///
  /// In es, this message translates to:
  /// **'Guarda tus playas favoritas'**
  String get profileSaveBeaches;

  /// No description provided for @profileCheckWeather.
  ///
  /// In es, this message translates to:
  /// **'Consulta el clima en tiempo real'**
  String get profileCheckWeather;

  /// No description provided for @profileShareCommunity.
  ///
  /// In es, this message translates to:
  /// **'Comparte con la comunidad'**
  String get profileShareCommunity;

  /// No description provided for @profileFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get profileFavorites;

  /// No description provided for @profileReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get profileReports;

  /// No description provided for @profileVisited.
  ///
  /// In es, this message translates to:
  /// **'Visitadas'**
  String get profileVisited;

  /// No description provided for @profileMyFavorites.
  ///
  /// In es, this message translates to:
  /// **'Mis Favoritos'**
  String get profileMyFavorites;

  /// No description provided for @profileFavoritesBeaches.
  ///
  /// In es, this message translates to:
  /// **'Playas que me gustan'**
  String get profileFavoritesBeaches;

  /// No description provided for @profileMyReports.
  ///
  /// In es, this message translates to:
  /// **'Mis Reportes'**
  String get profileMyReports;

  /// No description provided for @profileReportsSent.
  ///
  /// In es, this message translates to:
  /// **'Reportes enviados'**
  String get profileReportsSent;

  /// No description provided for @profileSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get profileSettings;

  /// No description provided for @profileSettingsPreferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias de la app'**
  String get profileSettingsPreferences;

  /// No description provided for @profileHelp.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get profileHelp;

  /// No description provided for @profileHelpFAQ.
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes'**
  String get profileHelpFAQ;

  /// No description provided for @profileAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get profileAbout;

  /// No description provided for @profileAboutVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión y créditos'**
  String get profileAboutVersion;

  /// No description provided for @profileLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro que deseas cerrar sesión?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileLoginPrompt.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para disfrutar'**
  String get profileLoginPrompt;

  /// No description provided for @profileLoginDescription.
  ///
  /// In es, this message translates to:
  /// **'Guarda tus playas favoritas y\ncomparte con la comunidad'**
  String get profileLoginDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In es, this message translates to:
  /// **'Según el sistema'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeAuto.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsThemeAuto;

  /// No description provided for @settingsUnits.
  ///
  /// In es, this message translates to:
  /// **'Unidades'**
  String get settingsUnits;

  /// No description provided for @settingsTemperature.
  ///
  /// In es, this message translates to:
  /// **'Unidad de temperatura'**
  String get settingsTemperature;

  /// No description provided for @settingsCelsius.
  ///
  /// In es, this message translates to:
  /// **'Celsius (°C)'**
  String get settingsCelsius;

  /// No description provided for @settingsFahrenheit.
  ///
  /// In es, this message translates to:
  /// **'Fahrenheit (°F)'**
  String get settingsFahrenheit;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones y Permisos'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsEnable.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotificationsEnable;

  /// No description provided for @settingsNotificationsDesc.
  ///
  /// In es, this message translates to:
  /// **'Recibir alertas y actualizaciones'**
  String get settingsNotificationsDesc;

  /// No description provided for @settingsLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get settingsLocation;

  /// No description provided for @settingsLocationDesc.
  ///
  /// In es, this message translates to:
  /// **'Permitir acceso a tu ubicación'**
  String get settingsLocationDesc;

  /// No description provided for @settingsDataSync.
  ///
  /// In es, this message translates to:
  /// **'Datos y Sincronización'**
  String get settingsDataSync;

  /// No description provided for @settingsAutoSync.
  ///
  /// In es, this message translates to:
  /// **'Sincronización automática'**
  String get settingsAutoSync;

  /// No description provided for @settingsAutoSyncDesc.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar datos automáticamente'**
  String get settingsAutoSyncDesc;

  /// No description provided for @settingsDataCollection.
  ///
  /// In es, this message translates to:
  /// **'Recopilación de datos'**
  String get settingsDataCollection;

  /// No description provided for @settingsDataCollectionDesc.
  ///
  /// In es, this message translates to:
  /// **'Ayudar a mejorar la app'**
  String get settingsDataCollectionDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsAdvanced.
  ///
  /// In es, this message translates to:
  /// **'Avanzado'**
  String get settingsAdvanced;

  /// No description provided for @settingsClearCache.
  ///
  /// In es, this message translates to:
  /// **'Limpiar caché'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheDesc.
  ///
  /// In es, this message translates to:
  /// **'Liberar espacio de almacenamiento'**
  String get settingsClearCacheDesc;

  /// No description provided for @settingsClearCacheConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro que deseas limpiar el caché? Esto eliminará las imágenes y datos temporales para liberar espacio.'**
  String get settingsClearCacheConfirm;

  /// No description provided for @settingsClearCacheSuccess.
  ///
  /// In es, this message translates to:
  /// **'Caché limpiado correctamente'**
  String get settingsClearCacheSuccess;

  /// No description provided for @settingsResetSettings.
  ///
  /// In es, this message translates to:
  /// **'Restablecer configuración'**
  String get settingsResetSettings;

  /// No description provided for @settingsResetSettingsDesc.
  ///
  /// In es, this message translates to:
  /// **'Volver a valores por defecto'**
  String get settingsResetSettingsDesc;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro que deseas restablecer todas las configuraciones a sus valores por defecto?'**
  String get settingsResetConfirm;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In es, this message translates to:
  /// **'Configuración restablecida'**
  String get settingsResetSuccess;

  /// No description provided for @weatherCurrent.
  ///
  /// In es, this message translates to:
  /// **'Clima Actual'**
  String get weatherCurrent;

  /// No description provided for @weatherFeelsLike.
  ///
  /// In es, this message translates to:
  /// **'Sensación {temp}'**
  String weatherFeelsLike(String temp);

  /// No description provided for @weatherHumidity.
  ///
  /// In es, this message translates to:
  /// **'Humedad'**
  String get weatherHumidity;

  /// No description provided for @weatherWind.
  ///
  /// In es, this message translates to:
  /// **'Viento'**
  String get weatherWind;

  /// No description provided for @weatherUVIndex.
  ///
  /// In es, this message translates to:
  /// **'Índice UV'**
  String get weatherUVIndex;

  /// No description provided for @weatherPressure.
  ///
  /// In es, this message translates to:
  /// **'Presión'**
  String get weatherPressure;

  /// No description provided for @weatherVisibility.
  ///
  /// In es, this message translates to:
  /// **'Visibilidad'**
  String get weatherVisibility;

  /// No description provided for @weatherCloudiness.
  ///
  /// In es, this message translates to:
  /// **'Nubosidad'**
  String get weatherCloudiness;

  /// No description provided for @weatherSunrise.
  ///
  /// In es, this message translates to:
  /// **'Amanecer'**
  String get weatherSunrise;

  /// No description provided for @weatherSunset.
  ///
  /// In es, this message translates to:
  /// **'Atardecer'**
  String get weatherSunset;

  /// No description provided for @weatherLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando clima...'**
  String get weatherLoading;

  /// No description provided for @weatherError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar clima'**
  String get weatherError;

  /// No description provided for @weatherRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get weatherRefresh;

  /// No description provided for @weatherRecommendationExcellent.
  ///
  /// In es, this message translates to:
  /// **'Excelente para la playa'**
  String get weatherRecommendationExcellent;

  /// No description provided for @weatherRecommendationNotRecommended.
  ///
  /// In es, this message translates to:
  /// **'No recomendado - {reason}'**
  String weatherRecommendationNotRecommended(String reason);

  /// No description provided for @weatherRecommendationWarning.
  ///
  /// In es, this message translates to:
  /// **'Advertencia - {reason}'**
  String weatherRecommendationWarning(String reason);

  /// No description provided for @weatherRecommendationCaution.
  ///
  /// In es, this message translates to:
  /// **'Precaución - {reason}'**
  String weatherRecommendationCaution(String reason);

  /// No description provided for @weatherRecommendationCool.
  ///
  /// In es, this message translates to:
  /// **'Fresco - Puede estar frío para nadar'**
  String get weatherRecommendationCool;

  /// No description provided for @weatherReasonThunderstorm.
  ///
  /// In es, this message translates to:
  /// **'Tormenta eléctrica'**
  String get weatherReasonThunderstorm;

  /// No description provided for @weatherReasonRain.
  ///
  /// In es, this message translates to:
  /// **'Lluvia'**
  String get weatherReasonRain;

  /// No description provided for @weatherReasonStrongWinds.
  ///
  /// In es, this message translates to:
  /// **'Vientos fuertes'**
  String get weatherReasonStrongWinds;

  /// No description provided for @weatherReasonHighUV.
  ///
  /// In es, this message translates to:
  /// **'Índice UV muy alto'**
  String get weatherReasonHighUV;

  /// No description provided for @weatherReasonHighTemperature.
  ///
  /// In es, this message translates to:
  /// **'Temperatura muy alta'**
  String get weatherReasonHighTemperature;

  /// No description provided for @authLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get authLogin;

  /// No description provided for @authSignup.
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get authSignup;

  /// No description provided for @authEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPassword;

  /// No description provided for @authName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get authName;

  /// No description provided for @authForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get authHaveAccount;

  /// No description provided for @authSignInWith.
  ///
  /// In es, this message translates to:
  /// **'O inicia sesión con'**
  String get authSignInWith;

  /// No description provided for @authGoogle.
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get authGoogle;

  /// No description provided for @authEmailError.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un correo válido'**
  String get authEmailError;

  /// No description provided for @authPasswordError.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get authPasswordError;

  /// No description provided for @authNameError.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu nombre'**
  String get authNameError;

  /// No description provided for @authSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido!'**
  String get authSuccess;

  /// No description provided for @authError.
  ///
  /// In es, this message translates to:
  /// **'Error al autenticar'**
  String get authError;

  /// No description provided for @aboutVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión 1.0.0'**
  String get aboutVersion;

  /// No description provided for @aboutDescription.
  ///
  /// In es, this message translates to:
  /// **'Descubre las mejores playas de República Dominicana 🇩🇴'**
  String get aboutDescription;

  /// No description provided for @aboutDevelopedWith.
  ///
  /// In es, this message translates to:
  /// **'Desarrollado con amor para los dominicanos'**
  String get aboutDevelopedWith;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión'**
  String get errorNetwork;

  /// No description provided for @errorNoInternet.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet'**
  String get errorNoInternet;

  /// No description provided for @errorLocationPermission.
  ///
  /// In es, this message translates to:
  /// **'Permiso de ubicación denegado'**
  String get errorLocationPermission;

  /// No description provided for @errorLocationDisabled.
  ///
  /// In es, this message translates to:
  /// **'Ubicación desactivada'**
  String get errorLocationDisabled;

  /// No description provided for @errorCameraPermission.
  ///
  /// In es, this message translates to:
  /// **'Permiso de cámara denegado'**
  String get errorCameraPermission;

  /// No description provided for @errorPhotoLibrary.
  ///
  /// In es, this message translates to:
  /// **'Error al acceder a la galería'**
  String get errorPhotoLibrary;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

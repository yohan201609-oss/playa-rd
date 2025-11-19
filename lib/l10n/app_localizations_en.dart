// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Playas RD';

  @override
  String get appDescription =>
      'Discover the best beaches in the Dominican Republic';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get share => 'Share';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get navHome => 'Home';

  @override
  String get navMap => 'Map';

  @override
  String get navReport => 'Report';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeTitle => 'Playas RD';

  @override
  String get homeSearchHint => 'Search beaches...';

  @override
  String get homeFilterAll => 'All';

  @override
  String get homeFilterFavorites => 'Favorites';

  @override
  String get homeFilters => 'Filters';

  @override
  String get homeClearFilters => 'Clear';

  @override
  String get homeSortBy => 'Sort by';

  @override
  String get homeSortRating => 'Rating';

  @override
  String get homeSortName => 'Name';

  @override
  String get homeSortCondition => 'Condition';

  @override
  String get homeApplyFilters => 'Apply';

  @override
  String get homeLoginToSaveFavorites => 'Sign in to save favorites';

  @override
  String get homeNoBeaches => 'No beaches found';

  @override
  String get homeNoFavorites => 'You have no favorite beaches yet';

  @override
  String homeBeachesCount(int count) {
    return '$count beaches found';
  }

  @override
  String get beachCondition => 'Condition';

  @override
  String get beachActivities => 'Activities';

  @override
  String get beachAmenities => 'Amenities';

  @override
  String get beachLocation => 'Location';

  @override
  String get beachWeather => 'Weather';

  @override
  String get beachReports => 'Reports';

  @override
  String get beachNoReports => 'No reports yet';

  @override
  String get beachGetDirections => 'Get directions';

  @override
  String get beachAddToFavorites => 'Add to favorites';

  @override
  String get beachRemoveFromFavorites => 'Remove from favorites';

  @override
  String get beachShareBeach => 'Share beach';

  @override
  String get beachMarkAsVisited => 'Mark as visited';

  @override
  String get beachAlreadyVisited => 'Already visited';

  @override
  String get beachDescription => 'Description';

  @override
  String get conditionExcellent => 'Excellent';

  @override
  String get conditionGood => 'Good';

  @override
  String get conditionModerate => 'Moderate';

  @override
  String get conditionDanger => 'Dangerous';

  @override
  String get conditionUnknown => 'Unknown';

  @override
  String get activitySwimming => 'Swimming';

  @override
  String get activitySurfing => 'Surfing';

  @override
  String get activitySnorkeling => 'Snorkeling';

  @override
  String get activityDiving => 'Diving';

  @override
  String get activityKayaking => 'Kayaking';

  @override
  String get activityFishing => 'Fishing';

  @override
  String get activityVolleyball => 'Volleyball';

  @override
  String get activityJetski => 'Jet Ski';

  @override
  String get activityEcotourism => 'Ecotourism';

  @override
  String get activityPhotography => 'Photography';

  @override
  String get activityRelaxation => 'Relaxation';

  @override
  String get activityTranquility => 'Tranquility';

  @override
  String get activityAdventure => 'Adventure';

  @override
  String get activityHiking => 'Hiking';

  @override
  String get activityNature => 'Nature';

  @override
  String get activitySunset => 'Sunset';

  @override
  String get activityRiver => 'River';

  @override
  String get activityFamilies => 'Families';

  @override
  String get mapTitle => 'Map';

  @override
  String mapTitleWithCount(int count) {
    return 'Beach Map ($count)';
  }

  @override
  String get mapShowList => 'Show list';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapError => 'Error loading map';

  @override
  String get mapLocationPermission => 'Location permission denied';

  @override
  String get mapClear => 'Clear';

  @override
  String get mapProvince => 'Province';

  @override
  String get mapApplyFilters => 'Apply filters';

  @override
  String get reportTitle => 'Report Condition';

  @override
  String get reportHelpCommunity => 'Help the community';

  @override
  String get reportHelpDescription => 'Report current beach conditions';

  @override
  String get reportWhichBeach => 'Which beach did you visit?';

  @override
  String get reportSelectBeach => 'Select a beach';

  @override
  String get reportHowConditions => 'How are the conditions?';

  @override
  String get reportCondition => 'Beach condition';

  @override
  String get reportAddComment => 'Add a comment';

  @override
  String get reportCommentOptional => 'Comment (optional)';

  @override
  String get reportDescription => 'Description (optional)';

  @override
  String get reportDescriptionHint => 'Describe the current conditions...';

  @override
  String get reportAddPhotos => 'Add photos';

  @override
  String get reportPhotos => 'Photos';

  @override
  String get reportPhotoFrom => 'Photo from';

  @override
  String get reportCamera => 'Camera';

  @override
  String get reportGallery => 'Gallery';

  @override
  String get reportTakePhoto => 'Take photo';

  @override
  String get reportSelectFromGallery => 'Select from gallery';

  @override
  String get reportMaxPhotos => 'Maximum 3 photos';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSubmitting => 'Submitting...';

  @override
  String get reportSuccess => 'Report submitted successfully';

  @override
  String get reportError => 'Error submitting report';

  @override
  String get reportSelectBeachFirst => 'Please select a beach first';

  @override
  String get reportSelectCondition => 'Please select a condition';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileWelcome => 'Welcome to';

  @override
  String get profileDiscoverBeaches => 'Discover the best beaches';

  @override
  String get profileLogin => 'Sign in';

  @override
  String get profileSignup => 'Create new account';

  @override
  String get profileSaveBeaches => 'Save your favorite beaches';

  @override
  String get profileCheckWeather => 'Check real-time weather';

  @override
  String get profileShareCommunity => 'Share with the community';

  @override
  String get profileFavorites => 'Favorites';

  @override
  String get profileReports => 'Reports';

  @override
  String get profileVisited => 'Visited';

  @override
  String get profileMyFavorites => 'My Favorites';

  @override
  String get profileFavoritesBeaches => 'Beaches I like';

  @override
  String get profileMyReports => 'My Reports';

  @override
  String get profileReportsSent => 'Reports sent';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSettingsPreferences => 'App preferences';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileHelpFAQ => 'Frequently asked questions';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAboutVersion => 'Version and credits';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileLoginPrompt => 'Sign in to enjoy';

  @override
  String get profileLoginDescription =>
      'Save your favorite beaches and\nshare with the community';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsUnits => 'Units';

  @override
  String get settingsTemperature => 'Temperature unit';

  @override
  String get settingsCelsius => 'Celsius (°C)';

  @override
  String get settingsFahrenheit => 'Fahrenheit (°F)';

  @override
  String get settingsNotifications => 'Notifications and Permissions';

  @override
  String get settingsNotificationsEnable => 'Notifications';

  @override
  String get settingsNotificationsDesc => 'Receive alerts and updates';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsLocationDesc => 'Allow access to your location';

  @override
  String get settingsDataSync => 'Data and Sync';

  @override
  String get settingsAutoSync => 'Auto-sync';

  @override
  String get settingsAutoSyncDesc => 'Sync data automatically';

  @override
  String get settingsDataCollection => 'Data collection';

  @override
  String get settingsDataCollectionDesc => 'Help improve the app';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsClearCache => 'Clear cache';

  @override
  String get settingsClearCacheDesc => 'Free up storage space';

  @override
  String get settingsClearCacheConfirm =>
      'Are you sure you want to clear the cache? This will delete temporary images and data to free up space.';

  @override
  String get settingsClearCacheSuccess => 'Cache cleared successfully';

  @override
  String get settingsResetSettings => 'Reset settings';

  @override
  String get settingsResetSettingsDesc => 'Return to default values';

  @override
  String get settingsResetConfirm =>
      'Are you sure you want to reset all settings to their default values?';

  @override
  String get settingsResetSuccess => 'Settings reset';

  @override
  String get weatherCurrent => 'Current Weather';

  @override
  String weatherFeelsLike(String temp) {
    return 'Feels like $temp';
  }

  @override
  String get weatherHumidity => 'Humidity';

  @override
  String get weatherWind => 'Wind';

  @override
  String get weatherUVIndex => 'UV Index';

  @override
  String get weatherPressure => 'Pressure';

  @override
  String get weatherVisibility => 'Visibility';

  @override
  String get weatherCloudiness => 'Cloudiness';

  @override
  String get weatherSunrise => 'Sunrise';

  @override
  String get weatherSunset => 'Sunset';

  @override
  String get weatherLoading => 'Loading weather...';

  @override
  String get weatherError => 'Error loading weather';

  @override
  String get weatherRefresh => 'Refresh';

  @override
  String get weatherRecommendationExcellent => 'Excellent for the beach';

  @override
  String weatherRecommendationNotRecommended(String reason) {
    return 'Not recommended - $reason';
  }

  @override
  String weatherRecommendationWarning(String reason) {
    return 'Warning - $reason';
  }

  @override
  String weatherRecommendationCaution(String reason) {
    return 'Caution - $reason';
  }

  @override
  String get weatherRecommendationCool => 'Cool - May be cold for swimming';

  @override
  String get weatherReasonThunderstorm => 'Thunderstorm';

  @override
  String get weatherReasonRain => 'Rain';

  @override
  String get weatherReasonStrongWinds => 'Strong winds';

  @override
  String get weatherReasonHighUV => 'Very high UV index';

  @override
  String get weatherReasonHighTemperature => 'Very high temperature';

  @override
  String get authLogin => 'Sign In';

  @override
  String get authSignup => 'Sign Up';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authName => 'Full name';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSignInWith => 'Or sign in with';

  @override
  String get authGoogle => 'Google';

  @override
  String get authEmailError => 'Please enter a valid email';

  @override
  String get authPasswordError => 'Password must be at least 6 characters';

  @override
  String get authNameError => 'Please enter your name';

  @override
  String get authSuccess => 'Welcome!';

  @override
  String get authError => 'Authentication error';

  @override
  String get aboutVersion => 'Version 1.0.0';

  @override
  String get aboutDescription =>
      'Discover the best beaches in the Dominican Republic 🇩🇴';

  @override
  String get aboutDevelopedWith => 'Developed with love for Dominicans';

  @override
  String get errorGeneric => 'An unexpected error occurred';

  @override
  String get errorNetwork => 'Connection error';

  @override
  String get errorNoInternet => 'No internet connection';

  @override
  String get errorLocationPermission => 'Location permission denied';

  @override
  String get errorLocationDisabled => 'Location disabled';

  @override
  String get errorCameraPermission => 'Camera permission denied';

  @override
  String get errorPhotoLibrary => 'Error accessing photo library';
}

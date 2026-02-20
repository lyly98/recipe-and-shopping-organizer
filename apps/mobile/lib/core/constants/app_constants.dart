class AppConstants {
  // API constants
  // Host is set via --dart-define=API_HOST=... when running on device/emulator.
  // - iOS Simulator: default localhost works
  // - Android Emulator: run with --dart-define=API_HOST=10.0.2.2
  // - Physical Android: run with --dart-define=API_HOST=YOUR_MAC_IP (e.g. 192.168.1.10)
  static String get apiBaseUrl =>
      'http://${const String.fromEnvironment('API_HOST', defaultValue: 'localhost')}:8000';

  // Storage constants
  static const String tokenKey = 'authToken';
  static const String userDataKey = 'userData';
  static const String refreshTokenKey = 'refreshToken';

  // App constants
  static const String appName = 'Recipe Organizer';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.recipe.organizer';
  static const String iOSAppId = '123456789';
  static const String appcastUrl = 'https://your-appcast-url.com/appcast.xml';

  // Timeout durations
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Route constants
  static const String initialRoute = '/';
  static const String homeRoute = '/home';
  static const String chatRoute = '/chat';
  static const String surveyRoute = '/survey';
  static const String categoryRoute = '/category';
  static const String recipeRoute = '/recipe';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String languageSettingsRoute = '/settings/language';
  static const String localizationDemoRoute = '/demo/localization';
  static const String localizationAssetsDemoRoute = '/demo/localization/assets';

  // Hive box names
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String offlineSyncBox = 'offlineSync';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Accessibility
  static const Duration accessibilityTooltipDuration = Duration(seconds: 5);
  static const double accessibilityTouchTargetMinSize = 48.0;

  // App Review
  static const int minSessionsBeforeReview = 5;
  static const int minDaysBeforeReview = 7;
  static const int minActionsBeforeReview = 10;
}

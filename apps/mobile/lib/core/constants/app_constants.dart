class AppConstants {
  // API constants
  // Host is set via --dart-define=API_HOST=... when running on device/emulator.
  // - iOS Simulator: default localhost works
  // - Android Emulator: run with --dart-define=API_HOST=10.0.2.2
  // - Physical Android: run with --dart-define=API_HOST=YOUR_MAC_IP (e.g. 192.168.1.10)
  static String get apiBaseUrl =>
      'http://${const String.fromEnvironment('API_HOST', defaultValue: 'localhost')}:8000';

  /// Resolves a recipe image URL so it uses the current API host (works on device/emulator).
  /// Pass a stored URL (e.g. http://localhost:8000/static/uploads/...) or a path (/static/uploads/...).
  static String? resolveRecipeImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final base = apiBaseUrl.replaceFirst(RegExp(r'/$'), '');
    if (url.startsWith('http://') || url.startsWith('https://')) {
      try {
        final uri = Uri.parse(url);
        return '$base${uri.path}${uri.query.isNotEmpty ? '?${uri.query}' : ''}';
      } catch (_) {
        return url;
      }
    }
    if (url.startsWith('/')) return base + url;
    return url;
  }

  // Storage constants
  static const String tokenKey = 'authToken';
  static const String userDataKey = 'userData';
  static const String refreshTokenKey = 'refreshToken';

  // App constants
  static const String appName = 'Chandir';
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
  static const String categoriesManagementRoute = '/categories';
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

/// App-wide configuration.
class AppConfig {
  AppConfig._();

  static const String appName = 'Project Tracker';
  static const String appVersion = '1.0.0';

  /// Backend base URL. Use localhost for web/Windows. For Android emulator, use
  /// [apiBaseUrlAndroid] or set this to 'http://10.0.2.2:8080'.
  static const String apiBaseUrl = 'http://localhost:8080';

  /// Use this for Android emulator (host machine = 10.0.2.2).
  static const String apiBaseUrlAndroid = 'http://10.0.2.2:8080';
}

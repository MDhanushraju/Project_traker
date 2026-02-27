import '../core/network/api_config.dart';

/// App-wide configuration.
class AppConfig {
  AppConfig._();

  static const String appName = 'Project Tracker';
  static const String appVersion = '1.0.0';

  /// Backend base URL (see api_config.dart: kApiBaseUrlLocal = http://localhost:8080).
  static String get apiBaseUrl => currentApiBaseUrl;

  /// Use this for Android emulator (host machine = 10.0.2.2).
  static const String apiBaseUrlAndroid = 'http://10.0.2.2:8080';
}

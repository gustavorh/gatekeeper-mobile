class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://192.168.1.122:9000';
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/users/profile';
  static const String clockInEndpoint = '/shifts/clock-in';
  static const String clockOutEndpoint = '/shifts/clock-out';
  static const String shiftHistoryEndpoint = '/shifts/history';

  // App Settings
  static const String appName = 'Gatekeeper Mobile';
  static const String appVersion = '1.0.0';

  // Environment
  static const bool isDebug = true;
  static const bool enableLogging = true;
}

class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'DELEGO_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}

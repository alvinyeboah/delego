class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'DELEGO_API_BASE_URL',
    defaultValue: 'https://delego.alvinyeboah.com',
  );
}

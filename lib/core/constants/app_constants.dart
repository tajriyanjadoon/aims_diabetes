/// Application-wide constants including networking configuration and environment flags.
abstract final class AppConstants {
  static const String appName = 'AIMSD';

  /// Base URL of the FastAPI backend.
  /// Defaults to Android emulator's loopback IP (`http://10.0.2.2:8000`).
  /// For physical devices or other environments, override via:
  /// `--dart-define=API_BASE_URL=http://<YOUR_IP>:8000`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// API route prefix for all endpoints.
  static const String apiPrefix = '/api/v1';

  /// Complete base API URL, e.g. `http://10.0.2.2:8000/api/v1`.
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  /// The master switch: false = local mock/dummy data, true = real FastAPI backend.
  static const bool useLiveBackend = false;

  /// Default HTTP request timeouts.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);
}

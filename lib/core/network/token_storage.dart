import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure device storage for JWT access and refresh tokens.
/// Utilizes Android Keystore and iOS Keychain via [FlutterSecureStorage].
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  String? _accessCache;

  /// Reads the short-lived access token.
  /// Uses an in-memory cache to avoid repeated disk/keystore I/O on every request.
  Future<String?> readAccess() async {
    return _accessCache ??= await _storage.read(key: _accessKey);
  }

  /// Reads the long-lived refresh token.
  Future<String?> readRefresh() async {
    return _storage.read(key: _refreshKey);
  }

  /// Persists new tokens into hardware-backed secure storage.
  Future<void> save({required String access, String? refresh}) async {
    _accessCache = access;
    await _storage.write(key: _accessKey, value: access);
    if (refresh != null) {
      await _storage.write(key: _refreshKey, value: refresh);
    }
  }

  /// Clears stored credentials on logout or expired session.
  Future<void> clear() async {
    _accessCache = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

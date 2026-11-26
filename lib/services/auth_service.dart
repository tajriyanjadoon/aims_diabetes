import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/token_storage.dart';
import '../models/user_model.dart';

/// Service responsible for authentication and identity against the FastAPI backend.
///
/// Communicates through [ApiClient] and stores tokens securely using [TokenStorage].
/// All network failures surface as [ApiException].
class AuthService {
  AuthService(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  /// Registers a new user with [name], [email], and [password].
  ///
  /// Upon successful registration (HTTP 201), saves the returned
  /// [access_token] and [refresh_token], and returns the parsed [UserModel].
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return _handleAuthResponse(response);
  }

  /// Logs in an existing user with [email] and [password].
  ///
  /// Upon successful login (HTTP 200), saves the returned
  /// [access_token] and [refresh_token], and returns the parsed [UserModel].
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return _handleAuthResponse(response);
  }

  /// Manually refreshes the JWT access token using the stored refresh token.
  Future<void> refreshToken() async {
    final refresh = await _tokenStorage.readRefresh();
    if (refresh == null || refresh.isEmpty) {
      await logout();
      throw ApiException('No refresh token available', statusCode: 401);
    }

    final response = await _apiClient.post(
      '/auth/refresh',
      data: {'refresh_token': refresh},
    );

    if (response is Map) {
      final access = response['access_token'] as String;
      final newRefresh = (response['refresh_token'] as String?) ?? refresh;
      await _tokenStorage.save(access: access, refresh: newRefresh);
    }
  }

  /// Submits a password reset request for [email].
  ///
  /// Note: The backend endpoint validates the email and logs the request.
  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }

  /// Changes the user's password using [currentPassword] and [newPassword].
  ///
  /// This protected endpoint automatically includes the Bearer access token.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/auth/change-password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  /// Checks if an active session exists (i.e. access token is present).
  Future<bool> hasSession() async {
    final token = await _tokenStorage.readAccess();
    return token != null && token.isNotEmpty;
  }

  /// Logs out by clearing all stored JWT credentials from device secure storage.
  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  /// Helper to extract tokens from authentication payload, save them, and parse the user.
  Future<UserModel> _handleAuthResponse(dynamic response) async {
    if (response is! Map) {
      throw ApiException('Unexpected response format from auth endpoint');
    }

    final accessToken = response['access_token'] as String?;
    final refreshToken = response['refresh_token'] as String?;
    final userData = response['user'];

    if (accessToken == null) {
      throw ApiException('Auth response missing access_token');
    }

    if (userData is! Map<String, dynamic>) {
      throw ApiException('Auth response missing user profile data');
    }

    await _tokenStorage.save(
      access: accessToken,
      refresh: refreshToken,
    );

    return UserModel.fromJson(userData);
  }
}

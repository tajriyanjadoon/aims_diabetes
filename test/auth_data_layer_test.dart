import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:aims_diabetes/core/network/api_client.dart';
import 'package:aims_diabetes/core/network/api_exception.dart';
import 'package:aims_diabetes/core/network/token_storage.dart';
import 'package:aims_diabetes/models/user_model.dart';
import 'package:aims_diabetes/services/auth_service.dart';

// In-memory fake secure storage for test isolation
class FakeSecureStorage extends FlutterSecureStorage {
  FakeSecureStorage() : super();
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

// Fake ApiClient that simulates backend responses without live networking
class FakeApiClient extends ApiClient {
  FakeApiClient(super.tokens, super.onSessionExpired);

  final List<String> requestedPaths = [];
  dynamic lastPostedData;
  dynamic postResponse;
  Exception? postError;

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    requestedPaths.add(path);
    lastPostedData = data;
    if (postError != null) throw postError!;
    return postResponse;
  }
}

void main() {
  group('UserModel', () {
    test('Correctly deserializes full backend response JSON', () {
      final json = {
        'id': 7,
        'name': 'Sara Connor',
        'email': 'sara@example.com',
        'age': 34,
        'gender': 'Female',
        'height_cm': 165.0,
        'weight_kg': 62.5,
        'diabetes_type': 'Type 2',
        'photo_url': 'https://example.com/photo.jpg',
        'bmi': 22.96,
        'bmi_category': 'Normal',
        'created_at': '2026-10-22T20:15:00',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 7);
      expect(user.name, 'Sara Connor');
      expect(user.email, 'sara@example.com');
      expect(user.age, 34);
      expect(user.gender, 'Female');
      expect(user.heightCm, 165.0);
      expect(user.weightKg, 62.5);
      expect(user.diabetesType, 'Type 2');
      expect(user.bmi, 22.96);
      expect(user.bmiCategory, 'Normal');
      expect(user.createdAt, isNotNull);
    });

    test('Correctly deserializes new user registration payload with null profile fields', () {
      final json = {
        'id': 10,
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': null,
        'gender': null,
        'height_cm': null,
        'weight_kg': null,
        'bmi': null,
        'created_at': '2026-11-26T10:00:00',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 10);
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.age, isNull);
      expect(user.bmi, isNull);
      expect(user.heightCm, isNull);
    });

    test('toJson and copyWith work as expected', () {
      const user = UserModel(
        id: 1,
        name: 'Alice',
        email: 'alice@example.com',
        age: 28,
      );

      final map = user.toJson();
      expect(map['id'], 1);
      expect(map['name'], 'Alice');
      expect(map['age'], 28);
      expect(map.containsKey('height_cm'), isFalse);

      final updated = user.copyWith(name: 'Alice Smith', heightCm: 170.0);
      expect(updated.name, 'Alice Smith');
      expect(updated.heightCm, 170.0);
      expect(updated.email, 'alice@example.com');
    });
  });

  group('AuthService', () {
    late TokenStorage tokenStorage;
    late FakeApiClient apiClient;
    late AuthService authService;

    final sampleAuthResponse = {
      'access_token': 'jwt_access_12345',
      'refresh_token': 'jwt_refresh_67890',
      'token_type': 'bearer',
      'expires_in': 3600,
      'user': {
        'id': 5,
        'name': 'Bob Ross',
        'email': 'bob@example.com',
        'age': 45,
      },
    };

    setUp(() {
      tokenStorage = TokenStorage(storage: FakeSecureStorage());
      apiClient = FakeApiClient(tokenStorage, () {});
      authService = AuthService(apiClient, tokenStorage);
    });

    test('login persists tokens and returns UserModel', () async {
      apiClient.postResponse = sampleAuthResponse;

      final user = await authService.login(
        email: 'bob@example.com',
        password: 'password123',
      );

      expect(user.id, 5);
      expect(user.name, 'Bob Ross');
      expect(apiClient.requestedPaths, contains('/auth/login'));
      expect(apiClient.lastPostedData['email'], 'bob@example.com');
      expect(await tokenStorage.readAccess(), 'jwt_access_12345');
      expect(await tokenStorage.readRefresh(), 'jwt_refresh_67890');
      expect(await authService.hasSession(), isTrue);
    });

    test('register persists tokens and returns UserModel', () async {
      apiClient.postResponse = sampleAuthResponse;

      final user = await authService.register(
        name: 'Bob Ross',
        email: 'bob@example.com',
        password: 'password123',
      );

      expect(user.id, 5);
      expect(apiClient.requestedPaths, contains('/auth/register'));
      expect(apiClient.lastPostedData['name'], 'Bob Ross');
      expect(await tokenStorage.readAccess(), 'jwt_access_12345');
    });

    test('refreshToken updates stored credentials', () async {
      await tokenStorage.save(access: 'old_access', refresh: 'old_refresh');
      apiClient.postResponse = {
        'access_token': 'new_access_token',
        'refresh_token': 'new_refresh_token',
        'token_type': 'bearer',
      };

      await authService.refreshToken();

      expect(apiClient.requestedPaths, contains('/auth/refresh'));
      expect(await tokenStorage.readAccess(), 'new_access_token');
      expect(await tokenStorage.readRefresh(), 'new_refresh_token');
    });

    test('forgotPassword sends email payload', () async {
      apiClient.postResponse = {'message': 'Password reset request received'};

      await authService.forgotPassword('bob@example.com');

      expect(apiClient.requestedPaths, contains('/auth/forgot-password'));
      expect(apiClient.lastPostedData['email'], 'bob@example.com');
    });

    test('changePassword sends current and new password', () async {
      apiClient.postResponse = {'message': 'Password changed successfully'};

      await authService.changePassword(
        currentPassword: 'old_pass_123',
        newPassword: 'new_pass_456',
      );

      expect(apiClient.requestedPaths, contains('/auth/change-password'));
      expect(apiClient.lastPostedData['current_password'], 'old_pass_123');
      expect(apiClient.lastPostedData['new_password'], 'new_pass_456');
    });

    test('logout clears stored credentials', () async {
      await tokenStorage.save(access: 'token_to_clear');
      expect(await authService.hasSession(), isTrue);

      await authService.logout();

      expect(await authService.hasSession(), isFalse);
      expect(await tokenStorage.readAccess(), isNull);
    });

    test('Propagates ApiException on authentication failure', () async {
      apiClient.postError = ApiException('Incorrect email or password', statusCode: 401);

      expect(
        () => authService.login(email: 'bad@example.com', password: 'wrong'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Incorrect email or password')),
      );
    });
  });
}

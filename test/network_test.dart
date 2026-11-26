import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aims_diabetes/core/constants/app_constants.dart';
import 'package:aims_diabetes/core/network/api_exception.dart';
import 'package:aims_diabetes/core/network/token_storage.dart';

// In-memory fake implementation of FlutterSecureStorage for testing
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

void main() {
  group('AppConstants', () {
    test('Default values conform to architecture specification', () {
      expect(AppConstants.appName, 'AIMSD');
      expect(AppConstants.apiPrefix, '/api/v1');
      expect(AppConstants.apiBaseUrl, contains('/api/v1'));
      expect(AppConstants.connectTimeout.inSeconds, 10);
      expect(AppConstants.receiveTimeout.inSeconds, 60);
    });
  });

  group('TokenStorage', () {
    test('Stores, caches, reads, and clears access and refresh tokens', () async {
      final fakeStorage = FakeSecureStorage();
      final tokenStorage = TokenStorage(storage: fakeStorage);

      expect(await tokenStorage.readAccess(), isNull);
      expect(await tokenStorage.readRefresh(), isNull);

      await tokenStorage.save(access: 'test_access', refresh: 'test_refresh');
      expect(await tokenStorage.readAccess(), 'test_access');
      expect(await tokenStorage.readRefresh(), 'test_refresh');

      await tokenStorage.clear();
      expect(await tokenStorage.readAccess(), isNull);
      expect(await tokenStorage.readRefresh(), isNull);
    });
  });

  group('ApiException', () {
    test('Parses string detail from FastAPI response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {'detail': 'Invalid email format'},
        ),
      );

      final exception = ApiException.from(dioException);
      expect(exception.message, 'Invalid email format');
      expect(exception.statusCode, 400);
      expect(exception.isUnauthorized, isFalse);
    });

    test('Parses validation error list from FastAPI 422 response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 422,
          data: {
            'detail': [
              {
                'loc': ['body', 'glucose_value'],
                'msg': 'Value must be between 20 and 600',
                'type': 'value_error',
              }
            ]
          },
        ),
      );

      final exception = ApiException.from(dioException);
      expect(exception.message, 'Value must be between 20 and 600');
      expect(exception.statusCode, 422);
      expect(exception.isValidationError, isTrue);
    });

    test('Handles offline / network timeout appropriately', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = ApiException.from(dioException);
      expect(exception.isOffline, isTrue);
      expect(exception.message, contains('timed out'));
    });
  });
}

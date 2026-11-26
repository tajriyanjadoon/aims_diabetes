import 'dart:async';
import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// The central HTTP client for communicating with the AIMS-Diabetes FastAPI backend.
///
/// Features:
/// - Base URL configuration with `/api/v1` prefix.
/// - Bearer token injection via [TokenStorage].
/// - Automated, sequential 401 token refresh via [QueuedInterceptorsWrapper] to prevent concurrent refresh races.
/// - Automatic `tz_offset` parameter injection for date-grouped GET requests.
/// - Unified exception mapping via [ApiException].
class ApiClient {
  ApiClient(this._tokens, this._onSessionExpired) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        Headers.contentTypeHeader: Headers.jsonContentType,
        Headers.acceptHeader: Headers.jsonContentType,
      },
    ));

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokens.readAccess();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        final requestPath = err.requestOptions.path;
        final isAuthEndpoint = requestPath.contains('/auth/');

        // If not a 401 or already calling an auth endpoint, pass through
        if (err.response?.statusCode != 401 || isAuthEndpoint) {
          return handler.next(err);
        }

        final refreshToken = await _tokens.readRefresh();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _tokens.clear();
          _onSessionExpired();
          return handler.next(err);
        }

        try {
          // Use a clean, non-intercepted Dio instance for the refresh call to prevent recursion
          final refreshDio = Dio(BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
          ));

          final response = await refreshDio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
          );

          final data = response.data;
          final newAccess = data['access_token'] as String;
          final newRefresh = (data['refresh_token'] as String?) ?? refreshToken;

          await _tokens.save(access: newAccess, refresh: newRefresh);

          // Retry the original request with the renewed access token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccess';

          final clonedResponse = await _dio.fetch(retryOptions);
          return handler.resolve(clonedResponse);
        } catch (_) {
          await _tokens.clear();
          _onSessionExpired();
          return handler.next(err);
        }
      },
    ));
  }

  late final Dio _dio;
  final TokenStorage _tokens;
  final void Function() _onSessionExpired;

  /// Exposes the underlying [Dio] instance if raw access is needed (e.g. multipart uploads).
  Dio get rawDio => _dio;

  /// Sends a GET request.
  /// Automatically appends `tz_offset` (minutes east of UTC) so the server groups data by the user's local day.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    final tzOffset = DateTime.now().timeZoneOffset.inMinutes;
    final mergedQuery = <String, dynamic>{
      'tz_offset': tzOffset,
      ...?queryParameters,
    };

    return _wrap(() => _dio.get(
      path,
      queryParameters: mergedQuery,
      options: options,
    ));
  }

  /// Sends a POST request.
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _wrap(() => _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ));
  }

  /// Sends a PUT request.
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _wrap(() => _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ));
  }

  /// Sends a DELETE request.
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _wrap(() => _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ));
  }

  /// Wraps an asynchronous HTTP call, unwraps data, and maps errors into [ApiException].
  Future<dynamic> _wrap(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return response.data;
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}

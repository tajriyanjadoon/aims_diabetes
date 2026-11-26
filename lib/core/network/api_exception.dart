import 'package:dio/dio.dart';

/// Represents a failure during API communication with the FastAPI backend.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
  bool get isRateLimited => statusCode == 429;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isOffline => statusCode == null;

  /// Creates an [ApiException] from any error, extracting FastAPI's `detail` field when available.
  factory ApiException.from(Object error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      final res = error.response;
      if (res == null) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          return ApiException('Connection timed out. Please try again.');
        }
        return ApiException('Cannot reach the server. Check your connection.');
      }

      final statusCode = res.statusCode;
      final data = res.data;

      if (data is Map) {
        final detail = data['detail'];
        if (detail is String) {
          return ApiException(detail, statusCode: statusCode);
        } else if (detail is List && detail.isNotEmpty) {
          // FastAPI / Pydantic validation error list: [{"loc": ..., "msg": ...}]
          final first = detail.first;
          if (first is Map && first.containsKey('msg')) {
            return ApiException(first['msg'].toString(), statusCode: statusCode);
          }
          return ApiException(detail.join(', '), statusCode: statusCode);
        }
      }

      return ApiException(
        'Request failed with status $statusCode.',
        statusCode: statusCode,
      );
    }

    return ApiException(error.toString());
  }

  @override
  String toString() => message;
}

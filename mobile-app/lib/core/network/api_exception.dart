import 'package:dio/dio.dart';

enum ApiErrorType {
  network,
  unauthorized,
  forbidden,
  notFound,
  validation,
  serverError,
  timeout,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    required this.type,
    this.errors,
  });

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Connection timed out. Please try again.',
          type: ApiErrorType.timeout,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          type: ApiErrorType.network,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          type: ApiErrorType.cancelled,
        );
      case DioExceptionType.badResponse:
        return _handleStatusCode(e);
      default:
        return ApiException(
          message: e.message ?? 'An unexpected error occurred.',
          type: ApiErrorType.unknown,
        );
    }
  }

  static ApiException _handleStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map ? data['message'] ?? 'An error occurred' : 'An error occurred';
    final errors = data is Map ? data['errors'] : null;

    switch (statusCode) {
      case 400:
        return ApiException(
          message: message,
          statusCode: 400,
          type: ApiErrorType.validation,
          errors: errors is Map ? Map<String, dynamic>.from(errors) : null,
        );
      case 401:
        return ApiException(
          message: 'Session expired. Please log in again.',
          statusCode: 401,
          type: ApiErrorType.unauthorized,
        );
      case 403:
        return ApiException(
          message: 'You do not have permission to perform this action.',
          statusCode: 403,
          type: ApiErrorType.forbidden,
        );
      case 404:
        return ApiException(
          message: 'Resource not found.',
          statusCode: 404,
          type: ApiErrorType.notFound,
        );
      case 422:
        return ApiException(
          message: message,
          statusCode: 422,
          type: ApiErrorType.validation,
          errors: errors is Map ? Map<String, dynamic>.from(errors) : null,
        );
      case 500:
      case 502:
      case 503:
        return ApiException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
          type: ApiErrorType.serverError,
        );
      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          type: ApiErrorType.unknown,
        );
    }
  }

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode, type: $type)';
}

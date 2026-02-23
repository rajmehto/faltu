import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:hive/hive.dart';

import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final box = Hive.box(AppConstants.settingsBox);
    final token = box.get(AppConstants.accessTokenKey);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final box = Hive.box(AppConstants.settingsBox);
        final newToken = box.get(AppConstants.accessTokenKey);
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        final dio = Get.find<Dio>();
        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {}
      }

      Get.offAllNamed('/login');
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final box = Hive.box(AppConstants.settingsBox);
      final refreshToken = box.get(AppConstants.refreshTokenKey);

      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        '${Get.find<Dio>().options.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['data']['accessToken'];
        final newRefreshToken = response.data['data']['refreshToken'];
        await box.put(AppConstants.accessTokenKey, newAccessToken);
        await box.put(AppConstants.refreshTokenKey, newRefreshToken);
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  int _retryCount = 0;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);

    if (shouldRetry && _retryCount < maxRetries) {
      _retryCount++;
      await Future.delayed(Duration(seconds: _retryCount * 2));

      try {
        final response = await dio.fetch(err.requestOptions);
        _retryCount = 0;
        handler.resolve(response);
        return;
      } catch (retryErr) {
        if (retryErr is DioException) {
          handler.next(retryErr);
          return;
        }
      }
    }

    _retryCount = 0;
    handler.next(err);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ [${options.method}] ${options.uri}');
      if (options.data != null) {
        debugPrint('  Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('← [${response.statusCode}] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✕ [${err.response?.statusCode}] ${err.requestOptions.uri}');
      debugPrint('  Error: ${err.message}');
    }
    handler.next(err);
  }
}

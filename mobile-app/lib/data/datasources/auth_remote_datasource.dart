import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSource(this._client);

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? displayName,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (displayName != null) 'displayName': displayName,
      },
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'emailOrUsername': emailOrUsername,
        'password': password,
      },
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
    String? email,
    String? displayName,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/social/login',
      data: {
        'provider': provider,
        'token': token,
        if (email != null) 'email': email,
        if (displayName != null) 'displayName': displayName,
      },
    );
    return response.data!;
  }

  Future<void> logout(String refreshToken) async {
    await _client.post('/auth/logout', data: {'refreshToken': refreshToken});
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return response.data!;
  }

  Future<void> forgotPassword(String email) async {
    await _client.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _client.post(
      '/auth/reset-password',
      data: {'token': token, 'password': newPassword},
    );
  }

  Future<void> sendPhoneOtp(String phone) async {
    await _client.post('/auth/phone/send-otp', data: {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/phone/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );
    return response.data!;
  }

  Future<void> verifyEmail(String token) async {
    await _client.post('/auth/verify-email', data: {'token': token});
  }

  Future<Map<String, dynamic>> enable2FA() async {
    final response = await _client.post<Map<String, dynamic>>('/auth/2fa/enable');
    return response.data!;
  }

  Future<void> verify2FA(String code) async {
    await _client.post('/auth/2fa/verify', data: {'code': code});
  }

  Future<void> disable2FA(String code) async {
    await _client.post('/auth/2fa/disable', data: {'code': code});
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await _client.post('/auth/fcm-token', data: {'fcmToken': fcmToken});
  }
}

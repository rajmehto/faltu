import '../../core/network/api_exception.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? displayName,
  }) async {
    final data = await _dataSource.register(
      username: username,
      email: email,
      password: password,
      phone: phone,
      displayName: displayName,
    );

    return (
      user: UserModel.fromJson(data['user']),
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final data = await _dataSource.login(
      emailOrUsername: emailOrUsername,
      password: password,
    );

    return (
      user: UserModel.fromJson(data['user']),
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  Future<({UserModel user, String accessToken, String refreshToken})> socialLogin({
    required String provider,
    required String token,
    String? email,
    String? displayName,
  }) async {
    final data = await _dataSource.socialLogin(
      provider: provider,
      token: token,
      email: email,
      displayName: displayName,
    );

    return (
      user: UserModel.fromJson(data['user']),
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  Future<void> logout(String refreshToken) async {
    await _dataSource.logout(refreshToken);
  }

  Future<void> forgotPassword(String email) async {
    await _dataSource.forgotPassword(email);
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dataSource.resetPassword(token: token, newPassword: newPassword);
  }

  Future<void> sendPhoneOtp(String phone) async {
    await _dataSource.sendPhoneOtp(phone);
  }

  Future<({UserModel user, String accessToken, String refreshToken})> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    final data = await _dataSource.verifyPhoneOtp(phone: phone, otp: otp);
    return (
      user: UserModel.fromJson(data['user']),
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dataSource.updateFcmToken(fcmToken);
    } catch (_) {}
  }
}

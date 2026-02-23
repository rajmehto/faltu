import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';

class AuthController extends GetxController {
  final AuthRepositoryImpl _repo = Get.find<AuthRepositoryImpl>();
  final AuthService _authService = Get.find<AuthService>();
  final AnalyticsService _analytics = Get.find<AnalyticsService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> login({
    required String emailOrUsername,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repo.login(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      await _authService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _authService.saveUser(result.user);
      await _analytics.logLogin('email');
      await _setupAfterLogin();

      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Login Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? phone,
    String? displayName,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repo.register(
        username: username,
        email: email,
        password: password,
        phone: phone,
        displayName: displayName,
      );

      await _authService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _authService.saveUser(result.user);
      await _analytics.logSignUp('email');
      await _setupAfterLogin();

      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Registration Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final token = await _authService.getGoogleIdToken();
      if (token == null) return;

      final result = await _repo.socialLogin(
        provider: 'google',
        token: token,
      );

      await _authService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _authService.saveUser(result.user);
      await _analytics.logLogin('google');
      await _setupAfterLogin();

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithFacebook() async {
    isLoading.value = true;
    try {
      final token = await _authService.getFacebookAccessToken();
      if (token == null) return;

      final result = await _repo.socialLogin(
        provider: 'facebook',
        token: token,
      );

      await _authService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _authService.saveUser(result.user);
      await _analytics.logLogin('facebook');
      await _setupAfterLogin();

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    isLoading.value = true;
    try {
      final credential = await _authService.getAppleCredential();
      if (credential == null) return;

      final result = await _repo.socialLogin(
        provider: 'apple',
        token: credential['identityToken']!,
        displayName: credential['fullName'],
      );

      await _authService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _authService.saveUser(result.user);
      await _analytics.logLogin('apple');
      await _setupAfterLogin();

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginAsGuest() async {
    Get.offAllNamed('/home');
  }

  Future<void> forgotPassword(String email) async {
    isLoading.value = true;
    try {
      await _repo.forgotPassword(email);
      Get.snackbar(
        'Email Sent',
        'Password reset instructions sent to $email',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _setupAfterLogin() async {
    final userId = _authService.userId;
    if (userId != null) {
      await _analytics.setUserId(userId);
    }

    await _notificationService.initialize();

    final fcmToken = await _notificationService.getFcmToken();
    if (fcmToken != null) {
      await _repo.updateFcmToken(fcmToken);
    }

    final box = Hive.box(AppConstants.settingsBox);
    await box.put(AppConstants.onboardingCompleteKey, true);
  }
}

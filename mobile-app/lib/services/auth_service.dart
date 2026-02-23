import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:hive/hive.dart';

import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  bool get isLoggedIn => currentUser.value != null;
  String? get userId => currentUser.value?.userId;
  String? get accessToken => Hive.box(AppConstants.settingsBox).get(AppConstants.accessTokenKey);

  Future<AuthService> init() async {
    await _loadStoredUser();
    return this;
  }

  Future<void> _loadStoredUser() async {
    final box = Hive.box(AppConstants.userBox);
    final userData = box.get('currentUser');
    if (userData != null) {
      currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
  }

  Future<void> saveUser(UserModel user) async {
    currentUser.value = user;
    final box = Hive.box(AppConstants.userBox);
    await box.put('currentUser', user.toJson());
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(AppConstants.accessTokenKey, accessToken);
    await box.put(AppConstants.refreshTokenKey, refreshToken);
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();

    currentUser.value = null;

    final settingsBox = Hive.box(AppConstants.settingsBox);
    await settingsBox.delete(AppConstants.accessTokenKey);
    await settingsBox.delete(AppConstants.refreshTokenKey);

    final userBox = Hive.box(AppConstants.userBox);
    await userBox.delete('currentUser');

    Get.offAllNamed('/login');
  }

  Future<OAuthCredential?> getGoogleCredential() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<String?> getGoogleIdToken() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    return googleAuth.idToken;
  }

  Future<String?> getFacebookAccessToken() async {
    final result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) return null;
    return result.accessToken?.tokenString;
  }

  Future<Map<String, String>?> getAppleCredential() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    return {
      'identityToken': credential.identityToken ?? '',
      'authorizationCode': credential.authorizationCode,
      'fullName': '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
    };
  }

  void updateUser(UserModel user) {
    currentUser.value = user;
    final box = Hive.box(AppConstants.userBox);
    box.put('currentUser', user.toJson());
  }

  void updateWallet({double? coins, double? diamonds, double? earnings}) {
    if (currentUser.value == null) return;
    final updatedWallet = UserWallet(
      coins: coins ?? currentUser.value!.wallet.coins,
      diamonds: diamonds ?? currentUser.value!.wallet.diamonds,
      earnings: earnings ?? currentUser.value!.wallet.earnings,
    );
    updateUser(currentUser.value!.copyWith(wallet: updatedWallet));
  }
}

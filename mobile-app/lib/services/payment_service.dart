import 'package:get/get.dart';
import 'package:stripe_flutter/stripe_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../core/config/app_config.dart';
import '../data/models/wallet_model.dart';

class PaymentService extends GetxService {
  Razorpay? _razorpay;

  @override
  void onInit() {
    super.onInit();
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    _razorpay = Razorpay();
  }

  Future<bool> purchaseCoinsWithStripe({
    required CoinPackage package,
    required String paymentIntentClientSecret,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: 'Tango Live',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFE91E8C),
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        Get.snackbar(
          'Payment Failed',
          e.error.localizedMessage ?? 'Payment failed',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }
  }

  Future<bool> purchaseCoinsWithRazorpay({
    required CoinPackage package,
    required String orderId,
    required String userEmail,
    required String userName,
    required String userPhone,
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onFailure,
    required void Function(ExternalWalletResponse) onExternalWallet,
  }) async {
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);

    final options = {
      'key': AppConfig.razorpayKeyId,
      'amount': (package.price * 100).toInt(),
      'name': 'Tango Live',
      'description': '${package.totalCoins} Coins',
      'order_id': orderId,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#E91E8C',
      },
    };

    _razorpay!.open(options);
    return true;
  }

  void clearRazorpayListeners() {
    _razorpay?.clear();
  }

  Future<bool> addCardWithStripe() async {
    try {
      final params = await Stripe.instance.collectBankAccountToken(
        params: const CollectBankAccountParams(
          paymentMethodType: PaymentMethodType.Card,
          accountHolderType: BankAccountHolderType.Individual,
          country: 'US',
          currency: 'usd',
        ),
      );
      return params != null;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> createSetupIntent() async {
    return null;
  }

  @override
  void onClose() {
    _razorpay?.clear();
    super.onClose();
  }
}

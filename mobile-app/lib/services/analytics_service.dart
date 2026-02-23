import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> init() async {}

  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logStreamStarted(String streamId, String category) async {
    await logEvent('stream_started', parameters: {
      'stream_id': streamId,
      'category': category,
    });
  }

  Future<void> logStreamWatched({
    required String streamId,
    required int watchDurationSeconds,
    required String streamerId,
  }) async {
    await logEvent('stream_watched', parameters: {
      'stream_id': streamId,
      'watch_duration_seconds': watchDurationSeconds,
      'streamer_id': streamerId,
    });
  }

  Future<void> logGiftSent({
    required String giftId,
    required String giftName,
    required double value,
    required String currency,
    required String streamId,
  }) async {
    await _analytics.logSpendVirtualCurrency(
      itemName: giftName,
      virtualCurrencyName: currency,
      value: value,
    );
    await logEvent('gift_sent', parameters: {
      'gift_id': giftId,
      'gift_name': giftName,
      'value': value,
      'stream_id': streamId,
    });
  }

  Future<void> logCoinsPurchased({
    required int coins,
    required double price,
    required String currency,
    required String paymentMethod,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemName: '$coins Coins',
          price: price,
          currency: currency,
        ),
      ],
    );
    await logEvent('coins_purchased', parameters: {
      'coins': coins,
      'price': price,
      'payment_method': paymentMethod,
    });
  }

  Future<void> logFollow(String targetUserId) async {
    await logEvent('follow_user', parameters: {'target_user_id': targetUserId});
  }

  Future<void> logShare({
    required String contentType,
    required String contentId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: contentId,
      method: method,
    );
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  Future<void> logChatMessage(String streamId) async {
    await logEvent('chat_message_sent', parameters: {'stream_id': streamId});
  }

  Future<void> logBeautyFilterApplied(String filterName) async {
    await logEvent('beauty_filter_applied', parameters: {'filter_name': filterName});
  }

  Future<void> logSubscriptionPurchased({
    required String planId,
    required String planName,
    required double price,
    required String currency,
  }) async {
    await logEvent('subscription_purchased', parameters: {
      'plan_id': planId,
      'plan_name': planName,
      'price': price,
      'currency': currency,
    });
  }
}

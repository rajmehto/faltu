import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class AppConfig {
  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static Environment get environment {
    switch (_env) {
      case 'production':
        return Environment.production;
      case 'staging':
        return Environment.staging;
      default:
        return Environment.development;
    }
  }

  static bool get isProduction => environment == Environment.production;
  static bool get isDevelopment => environment == Environment.development;
  static bool get isDebug => kDebugMode;

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.production:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.tangolive.app/api/v1',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://staging-api.tangolive.app/api/v1',
        );
      default:
        return 'http://localhost:3000/api/v1';
    }
  }

  static String get wsBaseUrl {
    switch (environment) {
      case Environment.production:
        return 'wss://ws.tangolive.app';
      case Environment.staging:
        return 'wss://staging-ws.tangolive.app';
      default:
        return 'ws://localhost:3001';
    }
  }

  static String get streamingBaseUrl {
    switch (environment) {
      case Environment.production:
        return 'https://stream.tangolive.app';
      case Environment.staging:
        return 'https://staging-stream.tangolive.app';
      default:
        return 'http://localhost:3002';
    }
  }

  static const String agoraAppId = String.fromEnvironment(
    'AGORA_APP_ID',
    defaultValue: '',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static const String mixpanelToken = String.fromEnvironment(
    'MIXPANEL_TOKEN',
    defaultValue: '',
  );

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int maxRetries = 3;
  static const int cacheMaxAge = 300;
}

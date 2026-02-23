class AppConstants {
  static const String appName = 'Tango Live';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String userBox = 'user';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String fcmTokenKey = 'fcm_token';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';

  static const int maxChatMessageLength = 200;
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;
  static const int maxStreamTitleLength = 80;
  static const int maxStreamDescLength = 500;
  static const int maxTagsPerStream = 5;

  static const double defaultAvatarRadius = 40.0;
  static const double smallAvatarRadius = 20.0;
  static const double largeAvatarRadius = 60.0;

  static const int paginationPageSize = 20;
  static const int chatPaginationSize = 50;
  static const int notificationPaginationSize = 30;

  static const double minWithdrawalAmount = 10.0;
  static const double maxWithdrawalAmount = 10000.0;
  static const double coinConversionRate = 0.01;
  static const double diamondConversionRate = 0.10;
  static const double streamerRevenueShare = 0.70;

  static const int maxCoHostsPerStream = 5;
  static const int maxModeratorsPerStream = 10;
  static const int maxViewersDisplay = 9999;

  static const int streamQualityLow = 360;
  static const int streamQualityMedium = 720;
  static const int streamQualityHigh = 1080;
  static const int streamBitrateLow = 500000;
  static const int streamBitrateMedium = 1500000;
  static const int streamBitrateHigh = 3000000;
  static const int streamFrameRate = 30;

  static const int voiceRoomMaxSpeakers = 9;
  static const int partyRoomMaxParticipants = 50;

  static const List<String> streamCategories = [
    'Gaming',
    'Music',
    'Dance',
    'Cooking',
    'Beauty',
    'Fitness',
    'Education',
    'Travel',
    'Art',
    'Comedy',
    'Talk Show',
    'Sports',
    'Tech',
    'Fashion',
    'Lifestyle',
    'News',
    'Other',
  ];

  static const List<String> reportReasons = [
    'Inappropriate Content',
    'Harassment',
    'Spam',
    'Violence',
    'Hate Speech',
    'Nudity',
    'Impersonation',
    'Copyright Infringement',
    'Dangerous Behavior',
    'Misinformation',
    'Other',
  ];

  static const List<Map<String, dynamic>> coinPackages = [
    {'coins': 100, 'price': 0.99, 'label': 'Starter', 'bonus': 0},
    {'coins': 500, 'price': 4.99, 'label': 'Popular', 'bonus': 50},
    {'coins': 1000, 'price': 9.99, 'label': 'Value', 'bonus': 150},
    {'coins': 2500, 'price': 24.99, 'label': 'Pro', 'bonus': 500},
    {'coins': 5000, 'price': 49.99, 'label': 'Elite', 'bonus': 1250},
    {'coins': 10000, 'price': 99.99, 'label': 'Ultimate', 'bonus': 3000},
  ];

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिन्दी',
    'es': 'Español',
    'pt': 'Português',
    'ar': 'العربية',
    'zh': '中文',
    'fr': 'Français',
    'de': 'Deutsch',
    'ja': '日本語',
    'ko': '한국어',
    'ru': 'Русский',
    'tr': 'Türkçe',
    'id': 'Indonesia',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
  };
}

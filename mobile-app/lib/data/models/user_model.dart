class UserModel {
  final String id;
  final String userId;
  final String username;
  final String? email;
  final String? phone;
  final UserProfile profile;
  final UserStats stats;
  final UserWallet wallet;
  final UserSubscription? subscription;
  final UserSettings settings;
  final UserModeration moderation;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.userId,
    required this.username,
    this.email,
    this.phone,
    required this.profile,
    required this.stats,
    required this.wallet,
    this.subscription,
    required this.settings,
    required this.moderation,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      profile: UserProfile.fromJson(json['profile'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      wallet: UserWallet.fromJson(json['wallet'] ?? {}),
      subscription: json['subscription'] != null
          ? UserSubscription.fromJson(json['subscription'])
          : null,
      settings: UserSettings.fromJson(json['settings'] ?? {}),
      moderation: UserModeration.fromJson(json['moderation'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'username': username,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'profile': profile.toJson(),
      'stats': stats.toJson(),
      'wallet': wallet.toJson(),
      if (subscription != null) 'subscription': subscription!.toJson(),
      'settings': settings.toJson(),
      'moderation': moderation.toJson(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? email,
    String? phone,
    UserProfile? profile,
    UserStats? stats,
    UserWallet? wallet,
    UserSubscription? subscription,
    UserSettings? settings,
    UserModeration? moderation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      wallet: wallet ?? this.wallet,
      subscription: subscription ?? this.subscription,
      settings: settings ?? this.settings,
      moderation: moderation ?? this.moderation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserProfile {
  final String? avatar;
  final String? coverImage;
  final String displayName;
  final String? bio;
  final DateTime? birthday;
  final String? gender;
  final String? country;
  final String? city;
  final bool verified;
  final int level;
  final int xp;

  UserProfile({
    this.avatar,
    this.coverImage,
    required this.displayName,
    this.bio,
    this.birthday,
    this.gender,
    this.country,
    this.city,
    this.verified = false,
    this.level = 1,
    this.xp = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      avatar: json['avatar'],
      coverImage: json['coverImage'],
      displayName: json['displayName'] ?? '',
      bio: json['bio'],
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      gender: json['gender'],
      country: json['country'],
      city: json['city'],
      verified: json['verified'] ?? false,
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (avatar != null) 'avatar': avatar,
      if (coverImage != null) 'coverImage': coverImage,
      'displayName': displayName,
      if (bio != null) 'bio': bio,
      if (birthday != null) 'birthday': birthday!.toIso8601String(),
      if (gender != null) 'gender': gender,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
      'verified': verified,
      'level': level,
      'xp': xp,
    };
  }
}

class UserStats {
  final int followers;
  final int following;
  final int totalViews;
  final int totalGiftsReceived;
  final int totalGiftsSent;
  final int totalStreams;

  UserStats({
    this.followers = 0,
    this.following = 0,
    this.totalViews = 0,
    this.totalGiftsReceived = 0,
    this.totalGiftsSent = 0,
    this.totalStreams = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      totalGiftsReceived: json['totalGiftsReceived'] ?? 0,
      totalGiftsSent: json['totalGiftsSent'] ?? 0,
      totalStreams: json['totalStreams'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followers': followers,
      'following': following,
      'totalViews': totalViews,
      'totalGiftsReceived': totalGiftsReceived,
      'totalGiftsSent': totalGiftsSent,
      'totalStreams': totalStreams,
    };
  }
}

class UserWallet {
  final double coins;
  final double diamonds;
  final double earnings;

  UserWallet({
    this.coins = 0,
    this.diamonds = 0,
    this.earnings = 0,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    return UserWallet(
      coins: (json['coins'] ?? 0).toDouble(),
      diamonds: (json['diamonds'] ?? 0).toDouble(),
      earnings: (json['earnings'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'diamonds': diamonds,
      'earnings': earnings,
    };
  }
}

class UserSubscription {
  final String plan;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  UserSubscription({
    required this.plan,
    this.startDate,
    this.endDate,
    this.isActive = false,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      plan: json['plan'] ?? 'free',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'isActive': isActive,
    };
  }

  bool get isPremium => plan == 'premium' || plan == 'vip';
  bool get isVip => plan == 'vip';
}

class UserSettings {
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final String theme;
  final String language;

  UserSettings({
    required this.notifications,
    required this.privacy,
    this.theme = 'dark',
    this.language = 'en',
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notifications: NotificationSettings.fromJson(
        json['notifications'] ?? {},
      ),
      privacy: PrivacySettings.fromJson(json['privacy'] ?? {}),
      theme: json['theme'] ?? 'dark',
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.toJson(),
      'privacy': privacy.toJson(),
      'theme': theme,
      'language': language,
    };
  }
}

class NotificationSettings {
  final bool followNotifications;
  final bool giftNotifications;
  final bool commentNotifications;
  final bool streamStartNotifications;
  final bool systemNotifications;
  final bool promotionNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationSettings({
    this.followNotifications = true,
    this.giftNotifications = true,
    this.commentNotifications = true,
    this.streamStartNotifications = true,
    this.systemNotifications = true,
    this.promotionNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      followNotifications: json['followNotifications'] ?? true,
      giftNotifications: json['giftNotifications'] ?? true,
      commentNotifications: json['commentNotifications'] ?? true,
      streamStartNotifications: json['streamStartNotifications'] ?? true,
      systemNotifications: json['systemNotifications'] ?? true,
      promotionNotifications: json['promotionNotifications'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followNotifications': followNotifications,
      'giftNotifications': giftNotifications,
      'commentNotifications': commentNotifications,
      'streamStartNotifications': streamStartNotifications,
      'systemNotifications': systemNotifications,
      'promotionNotifications': promotionNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }
}

class PrivacySettings {
  final String profileVisibility;
  final bool showFollowersCount;
  final bool showFollowingCount;
  final bool allowDirectMessages;
  final bool allowGiftsFromStranger;
  final bool showOnlineStatus;
  final bool allowSearchByPhone;
  final bool allowSearchByEmail;

  PrivacySettings({
    this.profileVisibility = 'public',
    this.showFollowersCount = true,
    this.showFollowingCount = true,
    this.allowDirectMessages = true,
    this.allowGiftsFromStranger = true,
    this.showOnlineStatus = true,
    this.allowSearchByPhone = false,
    this.allowSearchByEmail = false,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profileVisibility: json['profileVisibility'] ?? 'public',
      showFollowersCount: json['showFollowersCount'] ?? true,
      showFollowingCount: json['showFollowingCount'] ?? true,
      allowDirectMessages: json['allowDirectMessages'] ?? true,
      allowGiftsFromStranger: json['allowGiftsFromStranger'] ?? true,
      showOnlineStatus: json['showOnlineStatus'] ?? true,
      allowSearchByPhone: json['allowSearchByPhone'] ?? false,
      allowSearchByEmail: json['allowSearchByEmail'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileVisibility': profileVisibility,
      'showFollowersCount': showFollowersCount,
      'showFollowingCount': showFollowingCount,
      'allowDirectMessages': allowDirectMessages,
      'allowGiftsFromStranger': allowGiftsFromStranger,
      'showOnlineStatus': showOnlineStatus,
      'allowSearchByPhone': allowSearchByPhone,
      'allowSearchByEmail': allowSearchByEmail,
    };
  }
}

class UserModeration {
  final bool isBanned;
  final String? banReason;
  final DateTime? banUntil;
  final bool isVerified;

  UserModeration({
    this.isBanned = false,
    this.banReason,
    this.banUntil,
    this.isVerified = false,
  });

  factory UserModeration.fromJson(Map<String, dynamic> json) {
    return UserModeration(
      isBanned: json['isBanned'] ?? false,
      banReason: json['banReason'],
      banUntil: json['banUntil'] != null ? DateTime.parse(json['banUntil']) : null,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isBanned': isBanned,
      if (banReason != null) 'banReason': banReason,
      if (banUntil != null) 'banUntil': banUntil!.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}

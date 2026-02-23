class StreamModel {
  final String id;
  final String streamId;
  final String streamerId;
  final StreamerInfo? streamer;
  final String title;
  final String? description;
  final String? thumbnail;
  final String category;
  final List<String> tags;
  final StreamSettings settings;
  final AgoraConfig? agora;
  final StreamStats stats;
  final StreamMonetization monetization;
  final String status;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final List<String> coHosts;
  final List<StreamRecording> recordings;
  final StreamLocation? location;
  final DateTime createdAt;

  StreamModel({
    required this.id,
    required this.streamId,
    required this.streamerId,
    this.streamer,
    required this.title,
    this.description,
    this.thumbnail,
    required this.category,
    this.tags = const [],
    required this.settings,
    this.agora,
    required this.stats,
    required this.monetization,
    required this.status,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.coHosts = const [],
    this.recordings = const [],
    this.location,
    required this.createdAt,
  });

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      id: json['_id'] ?? json['id'] ?? '',
      streamId: json['streamId'] ?? '',
      streamerId: json['streamerId'] ?? '',
      streamer: json['streamer'] != null ? StreamerInfo.fromJson(json['streamer']) : null,
      title: json['title'] ?? '',
      description: json['description'],
      thumbnail: json['thumbnail'],
      category: json['category'] ?? 'Other',
      tags: List<String>.from(json['tags'] ?? []),
      settings: StreamSettings.fromJson(json['settings'] ?? {}),
      agora: json['agora'] != null ? AgoraConfig.fromJson(json['agora']) : null,
      stats: StreamStats.fromJson(json['stats'] ?? {}),
      monetization: StreamMonetization.fromJson(json['monetization'] ?? {}),
      status: json['status'] ?? 'ended',
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      coHosts: List<String>.from(json['coHosts'] ?? []),
      recordings: (json['recordings'] as List? ?? [])
          .map((r) => StreamRecording.fromJson(r))
          .toList(),
      location: json['location'] != null ? StreamLocation.fromJson(json['location']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'streamId': streamId,
      'streamerId': streamerId,
      if (streamer != null) 'streamer': streamer!.toJson(),
      'title': title,
      if (description != null) 'description': description,
      if (thumbnail != null) 'thumbnail': thumbnail,
      'category': category,
      'tags': tags,
      'settings': settings.toJson(),
      if (agora != null) 'agora': agora!.toJson(),
      'stats': stats.toJson(),
      'monetization': monetization.toJson(),
      'status': status,
      if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
      if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
      if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
      'coHosts': coHosts,
      'recordings': recordings.map((r) => r.toJson()).toList(),
      if (location != null) 'location': location!.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isLive => status == 'live';
  bool get isScheduled => status == 'scheduled';
  bool get hasEnded => status == 'ended';
  bool get hasRecording => recordings.isNotEmpty;
}

class StreamerInfo {
  final String userId;
  final String username;
  final String displayName;
  final String? avatar;
  final bool verified;
  final int level;

  StreamerInfo({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatar,
    this.verified = false,
    this.level = 1,
  });

  factory StreamerInfo.fromJson(Map<String, dynamic> json) {
    return StreamerInfo(
      userId: json['userId'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['profile']?['displayName'] ?? '',
      avatar: json['avatar'] ?? json['profile']?['avatar'],
      verified: json['verified'] ?? json['profile']?['verified'] ?? false,
      level: json['level'] ?? json['profile']?['level'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      if (avatar != null) 'avatar': avatar,
      'verified': verified,
      'level': level,
    };
  }
}

class StreamSettings {
  final String privacy;
  final String? password;
  final bool allowGuests;
  final int? maxViewers;
  final bool coHostEnabled;
  final bool recordingEnabled;
  final bool multiStreamEnabled;
  final bool chatEnabled;
  final bool giftsEnabled;
  final bool backgroundMusicEnabled;

  StreamSettings({
    this.privacy = 'public',
    this.password,
    this.allowGuests = true,
    this.maxViewers,
    this.coHostEnabled = true,
    this.recordingEnabled = false,
    this.multiStreamEnabled = false,
    this.chatEnabled = true,
    this.giftsEnabled = true,
    this.backgroundMusicEnabled = false,
  });

  factory StreamSettings.fromJson(Map<String, dynamic> json) {
    return StreamSettings(
      privacy: json['privacy'] ?? 'public',
      password: json['password'],
      allowGuests: json['allowGuests'] ?? true,
      maxViewers: json['maxViewers'],
      coHostEnabled: json['coHostEnabled'] ?? true,
      recordingEnabled: json['recordingEnabled'] ?? false,
      multiStreamEnabled: json['multiStreamEnabled'] ?? false,
      chatEnabled: json['chatEnabled'] ?? true,
      giftsEnabled: json['giftsEnabled'] ?? true,
      backgroundMusicEnabled: json['backgroundMusicEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'privacy': privacy,
      if (password != null) 'password': password,
      'allowGuests': allowGuests,
      if (maxViewers != null) 'maxViewers': maxViewers,
      'coHostEnabled': coHostEnabled,
      'recordingEnabled': recordingEnabled,
      'multiStreamEnabled': multiStreamEnabled,
      'chatEnabled': chatEnabled,
      'giftsEnabled': giftsEnabled,
      'backgroundMusicEnabled': backgroundMusicEnabled,
    };
  }
}

class AgoraConfig {
  final String channelName;
  final String token;
  final int uid;
  final int appId;

  AgoraConfig({
    required this.channelName,
    required this.token,
    required this.uid,
    required this.appId,
  });

  factory AgoraConfig.fromJson(Map<String, dynamic> json) {
    return AgoraConfig(
      channelName: json['channelName'] ?? '',
      token: json['token'] ?? '',
      uid: json['uid'] ?? 0,
      appId: json['appId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channelName': channelName,
      'token': token,
      'uid': uid,
      'appId': appId,
    };
  }
}

class StreamStats {
  final int currentViewers;
  final int peakViewers;
  final int totalViews;
  final int duration;
  final int likes;
  final int shares;

  StreamStats({
    this.currentViewers = 0,
    this.peakViewers = 0,
    this.totalViews = 0,
    this.duration = 0,
    this.likes = 0,
    this.shares = 0,
  });

  factory StreamStats.fromJson(Map<String, dynamic> json) {
    return StreamStats(
      currentViewers: json['currentViewers'] ?? 0,
      peakViewers: json['peakViewers'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      duration: json['duration'] ?? 0,
      likes: json['likes'] ?? 0,
      shares: json['shares'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentViewers': currentViewers,
      'peakViewers': peakViewers,
      'totalViews': totalViews,
      'duration': duration,
      'likes': likes,
      'shares': shares,
    };
  }
}

class StreamMonetization {
  final int giftsReceived;
  final double totalValue;
  final double diamondsEarned;

  StreamMonetization({
    this.giftsReceived = 0,
    this.totalValue = 0,
    this.diamondsEarned = 0,
  });

  factory StreamMonetization.fromJson(Map<String, dynamic> json) {
    return StreamMonetization(
      giftsReceived: json['giftsReceived'] ?? 0,
      totalValue: (json['totalValue'] ?? 0).toDouble(),
      diamondsEarned: (json['diamondsEarned'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'giftsReceived': giftsReceived,
      'totalValue': totalValue,
      'diamondsEarned': diamondsEarned,
    };
  }
}

class StreamRecording {
  final String url;
  final int duration;
  final String? thumbnail;
  final DateTime createdAt;

  StreamRecording({
    required this.url,
    required this.duration,
    this.thumbnail,
    required this.createdAt,
  });

  factory StreamRecording.fromJson(Map<String, dynamic> json) {
    return StreamRecording(
      url: json['url'] ?? '',
      duration: json['duration'] ?? 0,
      thumbnail: json['thumbnail'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'duration': duration,
      if (thumbnail != null) 'thumbnail': thumbnail,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class StreamLocation {
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;

  StreamLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
  });

  factory StreamLocation.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as List?;
    return StreamLocation(
      latitude: coordinates != null ? coordinates[1].toDouble() : 0,
      longitude: coordinates != null ? coordinates[0].toDouble() : 0,
      city: json['city'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'Point',
      'coordinates': [longitude, latitude],
      if (city != null) 'city': city,
      if (country != null) 'country': country,
    };
  }
}

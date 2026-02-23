class ChatMessageModel {
  final String id;
  final String messageId;
  final String streamId;
  final String userId;
  final SenderInfo? sender;
  final String type;
  final String content;
  final MessageMetadata? metadata;
  final String? replyToId;
  final ChatMessageModel? replyTo;
  final List<MessageReaction> reactions;
  final bool isDeleted;
  final bool isPinned;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.messageId,
    required this.streamId,
    required this.userId,
    this.sender,
    required this.type,
    required this.content,
    this.metadata,
    this.replyToId,
    this.replyTo,
    this.reactions = const [],
    this.isDeleted = false,
    this.isPinned = false,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      messageId: json['messageId'] ?? '',
      streamId: json['streamId'] ?? '',
      userId: json['userId'] ?? '',
      sender: json['sender'] != null ? SenderInfo.fromJson(json['sender']) : null,
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      metadata: json['metadata'] != null
          ? MessageMetadata.fromJson(json['metadata'])
          : null,
      replyToId: json['replyToId'],
      replyTo: json['replyTo'] != null ? ChatMessageModel.fromJson(json['replyTo']) : null,
      reactions: (json['reactions'] as List? ?? [])
          .map((r) => MessageReaction.fromJson(r))
          .toList(),
      isDeleted: json['isDeleted'] ?? false,
      isPinned: json['isPinned'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'messageId': messageId,
      'streamId': streamId,
      'userId': userId,
      if (sender != null) 'sender': sender!.toJson(),
      'type': type,
      'content': content,
      if (metadata != null) 'metadata': metadata!.toJson(),
      if (replyToId != null) 'replyToId': replyToId,
      if (replyTo != null) 'replyTo': replyTo!.toJson(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isText => type == 'text';
  bool get isEmoji => type == 'emoji';
  bool get isSticker => type == 'sticker';
  bool get isGift => type == 'gift';
  bool get isSuperChat => type == 'super_chat';
  bool get isSystem => type == 'system';
  bool get isImage => type == 'image';
}

class SenderInfo {
  final String userId;
  final String username;
  final String displayName;
  final String? avatar;
  final bool verified;
  final int level;
  final String? badge;

  SenderInfo({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatar,
    this.verified = false,
    this.level = 1,
    this.badge,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      userId: json['userId'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      avatar: json['avatar'],
      verified: json['verified'] ?? false,
      level: json['level'] ?? 1,
      badge: json['badge'],
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
      if (badge != null) 'badge': badge,
    };
  }
}

class MessageMetadata {
  final String? stickerId;
  final String? giftId;
  final String? giftName;
  final String? giftImage;
  final double? giftValue;
  final double? superChatAmount;
  final List<String>? mentionedUsers;
  final String? imageUrl;

  MessageMetadata({
    this.stickerId,
    this.giftId,
    this.giftName,
    this.giftImage,
    this.giftValue,
    this.superChatAmount,
    this.mentionedUsers,
    this.imageUrl,
  });

  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      stickerId: json['stickerId'],
      giftId: json['giftId'],
      giftName: json['giftName'],
      giftImage: json['giftImage'],
      giftValue: json['giftValue']?.toDouble(),
      superChatAmount: json['superChatAmount']?.toDouble(),
      mentionedUsers: json['mentionedUsers'] != null
          ? List<String>.from(json['mentionedUsers'])
          : null,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (stickerId != null) 'stickerId': stickerId,
      if (giftId != null) 'giftId': giftId,
      if (giftName != null) 'giftName': giftName,
      if (giftImage != null) 'giftImage': giftImage,
      if (giftValue != null) 'giftValue': giftValue,
      if (superChatAmount != null) 'superChatAmount': superChatAmount,
      if (mentionedUsers != null) 'mentionedUsers': mentionedUsers,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

class MessageReaction {
  final String emoji;
  final List<String> userIds;
  final int count;

  MessageReaction({
    required this.emoji,
    required this.userIds,
    required this.count,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'] ?? '',
      userIds: List<String>.from(json['userIds'] ?? []),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userIds': userIds,
      'count': count,
    };
  }
}

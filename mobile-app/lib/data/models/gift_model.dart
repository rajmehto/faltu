class GiftModel {
  final String id;
  final String giftId;
  final String name;
  final String? description;
  final String category;
  final String image;
  final String? animation;
  final String? sound;
  final GiftPrice price;
  final String rarity;
  final bool isLimited;
  final int? limitedQuantity;
  final DateTime? availableFrom;
  final DateTime? availableUntil;
  final bool isActive;
  final DateTime createdAt;

  GiftModel({
    required this.id,
    required this.giftId,
    required this.name,
    this.description,
    required this.category,
    required this.image,
    this.animation,
    this.sound,
    required this.price,
    this.rarity = 'common',
    this.isLimited = false,
    this.limitedQuantity,
    this.availableFrom,
    this.availableUntil,
    this.isActive = true,
    required this.createdAt,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['_id'] ?? json['id'] ?? '',
      giftId: json['giftId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'common',
      image: json['image'] ?? '',
      animation: json['animation'],
      sound: json['sound'],
      price: GiftPrice.fromJson(json['price'] ?? {}),
      rarity: json['rarity'] ?? 'common',
      isLimited: json['isLimited'] ?? false,
      limitedQuantity: json['limitedQuantity'],
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'])
          : null,
      availableUntil: json['availableUntil'] != null
          ? DateTime.parse(json['availableUntil'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'giftId': giftId,
      'name': name,
      if (description != null) 'description': description,
      'category': category,
      'image': image,
      if (animation != null) 'animation': animation,
      if (sound != null) 'sound': sound,
      'price': price.toJson(),
      'rarity': rarity,
      'isLimited': isLimited,
      if (limitedQuantity != null) 'limitedQuantity': limitedQuantity,
      if (availableFrom != null) 'availableFrom': availableFrom!.toIso8601String(),
      if (availableUntil != null) 'availableUntil': availableUntil!.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isLegendary => rarity == 'legendary';
  bool get isEpic => rarity == 'epic';
  bool get isRare => rarity == 'rare';
  bool get hasAnimation => animation != null;
  bool get hasSound => sound != null;
}

class GiftPrice {
  final int coins;
  final double diamonds;

  GiftPrice({required this.coins, required this.diamonds});

  factory GiftPrice.fromJson(Map<String, dynamic> json) {
    return GiftPrice(
      coins: json['coins'] ?? 0,
      diamonds: (json['diamonds'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'diamonds': diamonds,
    };
  }
}

class GiftTransaction {
  final String id;
  final String transactionId;
  final String fromUserId;
  final String toUserId;
  final String? streamId;
  final GiftModel gift;
  final int quantity;
  final double value;
  final String currency;
  final DateTime timestamp;

  GiftTransaction({
    required this.id,
    required this.transactionId,
    required this.fromUserId,
    required this.toUserId,
    this.streamId,
    required this.gift,
    required this.quantity,
    required this.value,
    required this.currency,
    required this.timestamp,
  });

  factory GiftTransaction.fromJson(Map<String, dynamic> json) {
    return GiftTransaction(
      id: json['_id'] ?? json['id'] ?? '',
      transactionId: json['transactionId'] ?? '',
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      streamId: json['streamId'],
      gift: GiftModel.fromJson(json['gift'] ?? {}),
      quantity: json['quantity'] ?? 1,
      value: (json['value'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'coins',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

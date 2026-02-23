class WalletModel {
  final String walletId;
  final String userId;
  final double coinsBalance;
  final double diamondsBalance;
  final double earningsBalance;
  final double frozenBalance;
  final String currency;
  final DateTime updatedAt;

  WalletModel({
    required this.walletId,
    required this.userId,
    required this.coinsBalance,
    required this.diamondsBalance,
    required this.earningsBalance,
    required this.frozenBalance,
    required this.currency,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletId: json['walletId'] ?? '',
      userId: json['userId'] ?? '',
      coinsBalance: (json['coinsBalance'] ?? 0).toDouble(),
      diamondsBalance: (json['diamondsBalance'] ?? 0).toDouble(),
      earningsBalance: (json['earningsBalance'] ?? 0).toDouble(),
      frozenBalance: (json['frozenBalance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'userId': userId,
      'coinsBalance': coinsBalance,
      'diamondsBalance': diamondsBalance,
      'earningsBalance': earningsBalance,
      'frozenBalance': frozenBalance,
      'currency': currency,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TransactionModel {
  final String transactionId;
  final String userId;
  final String type;
  final double amount;
  final String currency;
  final String? paymentMethod;
  final String? paymentIntentId;
  final String status;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    this.paymentIntentId,
    required this.status,
    this.description,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      paymentMethod: json['paymentMethod'],
      paymentIntentId: json['paymentIntentId'],
      status: json['status'] ?? '',
      description: json['description'],
      metadata: json['metadata'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';
  bool get isCredit => type == 'purchase' || type == 'gift_received' || type == 'bonus' || type == 'refund';
  bool get isDebit => type == 'gift_sent' || type == 'withdrawal';
}

class CoinPackage {
  final int coins;
  final double price;
  final String label;
  final int bonus;
  final String? badge;
  final bool isPopular;

  CoinPackage({
    required this.coins,
    required this.price,
    required this.label,
    required this.bonus,
    this.badge,
    this.isPopular = false,
  });

  int get totalCoins => coins + bonus;

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      coins: json['coins'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      label: json['label'] ?? '',
      bonus: json['bonus'] ?? 0,
      badge: json['badge'],
      isPopular: json['isPopular'] ?? false,
    );
  }
}

class WithdrawalRequest {
  final String withdrawalId;
  final String userId;
  final double amount;
  final String currency;
  final String method;
  final Map<String, dynamic> methodDetails;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? processedAt;

  WithdrawalRequest({
    required this.withdrawalId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.methodDetails,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.processedAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      withdrawalId: json['withdrawalId'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      method: json['method'] ?? '',
      methodDetails: json['methodDetails'] ?? {},
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejectionReason'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';
}

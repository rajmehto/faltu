import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/wallet_model.dart';

class WalletRemoteDataSource {
  final ApiClient _client;

  WalletRemoteDataSource(this._client);

  Future<WalletModel> getWallet() async {
    final response = await _client.get<WalletModel>(
      '/wallet',
      fromJson: (data) => WalletModel.fromJson(data),
    );
    return response.data!;
  }

  Future<Map<String, double>> getBalance() async {
    final response = await _client.get<Map<String, double>>(
      '/wallet/balance',
    );
    return response.data ?? {};
  }

  Future<PaginatedResponse<TransactionModel>> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _client.get<PaginatedResponse<TransactionModel>>(
      '/wallet/transactions',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (type != null) 'type': type,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => TransactionModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> createPurchaseIntent({
    required int coins,
    required double price,
    required String currency,
    required String paymentMethod,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/wallet/purchase-coins',
      data: {
        'coins': coins,
        'price': price,
        'currency': currency,
        'paymentMethod': paymentMethod,
      },
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> createWithdrawalRequest({
    required double amount,
    required String currency,
    required String method,
    required Map<String, dynamic> methodDetails,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/wallet/withdraw',
      data: {
        'amount': amount,
        'currency': currency,
        'method': method,
        'methodDetails': methodDetails,
      },
    );
    return response.data!;
  }

  Future<PaginatedResponse<WithdrawalRequest>> getWithdrawalHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<WithdrawalRequest>>(
      '/wallet/withdrawals',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => WithdrawalRequest.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<void> transferCoins({
    required String toUserId,
    required int coins,
    String? message,
  }) async {
    await _client.post('/wallet/transfer', data: {
      'toUserId': toUserId,
      'coins': coins,
      if (message != null) 'message': message,
    });
  }

  Future<Map<String, dynamic>> getEarningsBreakdown({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/wallet/earnings',
      queryParameters: {
        'period': period,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
    );
    return response.data ?? {};
  }
}

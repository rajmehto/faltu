import '../../core/network/api_response.dart';
import '../datasources/wallet_remote_datasource.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl {
  final WalletRemoteDataSource _dataSource;

  WalletRepositoryImpl(this._dataSource);

  Future<WalletModel> getWallet() => _dataSource.getWallet();

  Future<Map<String, double>> getBalance() => _dataSource.getBalance();

  Future<PaginatedResponse<TransactionModel>> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _dataSource.getTransactions(
      page: page,
      pageSize: pageSize,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<String, dynamic>> createPurchaseIntent({
    required int coins,
    required double price,
    required String currency,
    required String paymentMethod,
  }) async {
    return _dataSource.createPurchaseIntent(
      coins: coins,
      price: price,
      currency: currency,
      paymentMethod: paymentMethod,
    );
  }

  Future<Map<String, dynamic>> createWithdrawalRequest({
    required double amount,
    required String currency,
    required String method,
    required Map<String, dynamic> methodDetails,
  }) async {
    return _dataSource.createWithdrawalRequest(
      amount: amount,
      currency: currency,
      method: method,
      methodDetails: methodDetails,
    );
  }

  Future<PaginatedResponse<WithdrawalRequest>> getWithdrawalHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getWithdrawalHistory(page: page, pageSize: pageSize);
  }

  Future<void> transferCoins({
    required String toUserId,
    required int coins,
    String? message,
  }) async {
    await _dataSource.transferCoins(
      toUserId: toUserId,
      coins: coins,
      message: message,
    );
  }

  Future<Map<String, dynamic>> getEarningsBreakdown({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _dataSource.getEarningsBreakdown(
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

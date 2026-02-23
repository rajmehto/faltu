import '../../core/network/api_response.dart';
import '../datasources/gift_remote_datasource.dart';
import '../models/gift_model.dart';

class GiftRepositoryImpl {
  final GiftRemoteDataSource _dataSource;

  GiftRepositoryImpl(this._dataSource);

  Future<List<GiftModel>> getAllGifts() => _dataSource.getAllGifts();

  Future<List<Map<String, dynamic>>> getGiftCategories() =>
      _dataSource.getGiftCategories();

  Future<void> sendGift({
    required String giftId,
    required String toUserId,
    required int quantity,
    String? streamId,
  }) async {
    await _dataSource.sendGift(
      giftId: giftId,
      toUserId: toUserId,
      quantity: quantity,
      streamId: streamId,
    );
  }

  Future<PaginatedResponse<GiftTransaction>> getGiftHistory({
    int page = 1,
    int pageSize = 20,
    String? type,
  }) async {
    return _dataSource.getGiftHistory(page: page, pageSize: pageSize, type: type);
  }

  Future<List<Map<String, dynamic>>> getGiftLeaderboard({
    required String period,
    String? streamId,
    int limit = 10,
  }) async {
    return _dataSource.getGiftLeaderboard(
      period: period,
      streamId: streamId,
      limit: limit,
    );
  }

  Future<GiftModel> getGiftById(String giftId) =>
      _dataSource.getGiftById(giftId);

  Future<PaginatedResponse<GiftTransaction>> getSentGifts({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getSentGifts(page: page, pageSize: pageSize);
  }

  Future<PaginatedResponse<GiftTransaction>> getReceivedGifts({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getReceivedGifts(page: page, pageSize: pageSize);
  }
}

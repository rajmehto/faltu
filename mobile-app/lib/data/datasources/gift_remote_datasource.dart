import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/gift_model.dart';

class GiftRemoteDataSource {
  final ApiClient _client;

  GiftRemoteDataSource(this._client);

  Future<List<GiftModel>> getAllGifts() async {
    final response = await _client.get<List<GiftModel>>(
      '/gifts',
      fromJson: (data) => (data as List).map((g) => GiftModel.fromJson(g)).toList(),
    );
    return response.data ?? [];
  }

  Future<List<Map<String, dynamic>>> getGiftCategories() async {
    final response = await _client.get<List<Map<String, dynamic>>>('/gifts/categories');
    return response.data ?? [];
  }

  Future<void> sendGift({
    required String giftId,
    required String toUserId,
    required int quantity,
    String? streamId,
  }) async {
    await _client.post('/gifts/send', data: {
      'giftId': giftId,
      'toUserId': toUserId,
      'quantity': quantity,
      if (streamId != null) 'streamId': streamId,
    });
  }

  Future<PaginatedResponse<GiftTransaction>> getGiftHistory({
    int page = 1,
    int pageSize = 20,
    String? type,
  }) async {
    final response = await _client.get<PaginatedResponse<GiftTransaction>>(
      '/gifts/history',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (type != null) 'type': type,
      },
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => GiftTransaction.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> getGiftLeaderboard({
    required String period,
    String? streamId,
    int limit = 10,
  }) async {
    final response = await _client.get<List<Map<String, dynamic>>>(
      '/gifts/leaderboard',
      queryParameters: {
        'period': period,
        if (streamId != null) 'streamId': streamId,
        'limit': limit,
      },
    );
    return response.data ?? [];
  }

  Future<GiftModel> getGiftById(String giftId) async {
    final response = await _client.get<GiftModel>(
      '/gifts/$giftId',
      fromJson: (data) => GiftModel.fromJson(data),
    );
    return response.data!;
  }

  Future<PaginatedResponse<GiftTransaction>> getSentGifts({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<GiftTransaction>>(
      '/gifts/sent',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => GiftTransaction.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<PaginatedResponse<GiftTransaction>> getReceivedGifts({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<GiftTransaction>>(
      '/gifts/received',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => GiftTransaction.fromJson(item),
      ),
    );
    return response.data!;
  }
}

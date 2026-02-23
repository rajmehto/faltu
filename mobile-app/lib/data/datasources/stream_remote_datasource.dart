import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/stream_model.dart';

class StreamRemoteDataSource {
  final ApiClient _client;

  StreamRemoteDataSource(this._client);

  Future<Map<String, dynamic>> startStream({
    required String title,
    String? description,
    required String category,
    List<String>? tags,
    required String privacy,
    bool recordingEnabled = false,
    String? thumbnail,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/streams/start',
      data: {
        'title': title,
        if (description != null) 'description': description,
        'category': category,
        if (tags != null) 'tags': tags,
        'privacy': privacy,
        'recordingEnabled': recordingEnabled,
        if (thumbnail != null) 'thumbnail': thumbnail,
      },
    );
    return response.data!;
  }

  Future<void> endStream(String streamId) async {
    await _client.post('/streams/end', data: {'streamId': streamId});
  }

  Future<StreamModel> getStream(String streamId) async {
    final response = await _client.get<StreamModel>(
      '/streams/$streamId',
      fromJson: (data) => StreamModel.fromJson(data),
    );
    return response.data!;
  }

  Future<PaginatedResponse<StreamModel>> getLiveStreams({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? sortBy,
  }) async {
    final response = await _client.get<PaginatedResponse<StreamModel>>(
      '/streams/live',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (category != null) 'category': category,
        if (sortBy != null) 'sortBy': sortBy,
      },
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => StreamModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<PaginatedResponse<StreamModel>> getTrendingStreams({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<StreamModel>>(
      '/streams/trending',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => StreamModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<PaginatedResponse<StreamModel>> getNearbyStreams({
    required double latitude,
    required double longitude,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<StreamModel>>(
      '/streams/nearby',
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => StreamModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<PaginatedResponse<StreamModel>> getRecommendedStreams({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<StreamModel>>(
      '/streams/recommended',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => StreamModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<PaginatedResponse<StreamModel>> searchStreams({
    required String query,
    int page = 1,
    int pageSize = 20,
    String? category,
  }) async {
    final response = await _client.get<PaginatedResponse<StreamModel>>(
      '/streams/search',
      queryParameters: {
        'q': query,
        'page': page,
        'pageSize': pageSize,
        if (category != null) 'category': category,
      },
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => StreamModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> joinStream(String streamId, {String? password}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/streams/$streamId/join',
      data: {if (password != null) 'password': password},
    );
    return response.data!;
  }

  Future<void> leaveStream(String streamId) async {
    await _client.post('/streams/$streamId/leave');
  }

  Future<void> likeStream(String streamId) async {
    await _client.post('/streams/$streamId/like');
  }

  Future<void> reportStream(String streamId, {
    required String reason,
    String? description,
  }) async {
    await _client.post('/streams/$streamId/report', data: {
      'reason': reason,
      if (description != null) 'description': description,
    });
  }

  Future<void> addCoHost(String streamId, String userId) async {
    await _client.post('/streams/$streamId/cohost', data: {'userId': userId});
  }

  Future<void> removeCoHost(String streamId, String userId) async {
    await _client.delete('/streams/$streamId/cohost', data: {'userId': userId});
  }

  Future<StreamModel> scheduleStream({
    required String title,
    required String category,
    required DateTime scheduledAt,
    String? description,
    String? thumbnail,
  }) async {
    final response = await _client.post<StreamModel>(
      '/streams/schedule',
      data: {
        'title': title,
        'category': category,
        'scheduledAt': scheduledAt.toIso8601String(),
        if (description != null) 'description': description,
        if (thumbnail != null) 'thumbnail': thumbnail,
      },
      fromJson: (data) => StreamModel.fromJson(data),
    );
    return response.data!;
  }

  Future<void> startRecording(String streamId) async {
    await _client.post('/streams/$streamId/record');
  }

  Future<void> stopRecording(String streamId) async {
    await _client.post('/streams/$streamId/stop-record');
  }

  Future<PaginatedResponse<StreamModel>> getUserStreams(String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<StreamModel>>(
      '/users/$userId/streams',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => StreamModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<void> banUserFromStream(String streamId, String userId, {String? reason}) async {
    await _client.post('/streams/$streamId/moderate', data: {
      'userId': userId,
      'action': 'ban',
      if (reason != null) 'reason': reason,
    });
  }

  Future<void> muteUserInStream(String streamId, String userId) async {
    await _client.post('/streams/$streamId/moderate', data: {
      'userId': userId,
      'action': 'mute',
    });
  }
}

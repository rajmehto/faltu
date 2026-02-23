import '../../core/network/api_response.dart';
import '../datasources/stream_remote_datasource.dart';
import '../models/stream_model.dart';

class StreamRepositoryImpl {
  final StreamRemoteDataSource _dataSource;

  StreamRepositoryImpl(this._dataSource);

  Future<({StreamModel stream, AgoraConfig agoraConfig})> startStream({
    required String title,
    String? description,
    required String category,
    List<String>? tags,
    required String privacy,
    bool recordingEnabled = false,
    String? thumbnail,
  }) async {
    final data = await _dataSource.startStream(
      title: title,
      description: description,
      category: category,
      tags: tags,
      privacy: privacy,
      recordingEnabled: recordingEnabled,
      thumbnail: thumbnail,
    );

    return (
      stream: StreamModel.fromJson(data['stream']),
      agoraConfig: AgoraConfig.fromJson(data['agoraConfig']),
    );
  }

  Future<void> endStream(String streamId) async {
    await _dataSource.endStream(streamId);
  }

  Future<StreamModel> getStream(String streamId) async {
    return _dataSource.getStream(streamId);
  }

  Future<PaginatedResponse<StreamModel>> getLiveStreams({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? sortBy,
  }) async {
    return _dataSource.getLiveStreams(
      page: page,
      pageSize: pageSize,
      category: category,
      sortBy: sortBy,
    );
  }

  Future<PaginatedResponse<StreamModel>> getTrendingStreams({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getTrendingStreams(page: page, pageSize: pageSize);
  }

  Future<PaginatedResponse<StreamModel>> getNearbyStreams({
    required double latitude,
    required double longitude,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getNearbyStreams(
      latitude: latitude,
      longitude: longitude,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<PaginatedResponse<StreamModel>> getRecommendedStreams({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getRecommendedStreams(page: page, pageSize: pageSize);
  }

  Future<PaginatedResponse<StreamModel>> searchStreams({
    required String query,
    int page = 1,
    int pageSize = 20,
    String? category,
  }) async {
    return _dataSource.searchStreams(
      query: query,
      page: page,
      pageSize: pageSize,
      category: category,
    );
  }

  Future<({AgoraConfig agoraConfig, bool isHost})> joinStream(
    String streamId, {
    String? password,
  }) async {
    final data = await _dataSource.joinStream(streamId, password: password);
    return (
      agoraConfig: AgoraConfig.fromJson(data['agoraConfig']),
      isHost: data['isHost'] ?? false,
    );
  }

  Future<void> leaveStream(String streamId) async {
    await _dataSource.leaveStream(streamId);
  }

  Future<void> likeStream(String streamId) async {
    await _dataSource.likeStream(streamId);
  }

  Future<PaginatedResponse<StreamModel>> getUserStreams(String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getUserStreams(userId, page: page, pageSize: pageSize);
  }

  Future<StreamModel> scheduleStream({
    required String title,
    required String category,
    required DateTime scheduledAt,
    String? description,
    String? thumbnail,
  }) async {
    return _dataSource.scheduleStream(
      title: title,
      category: category,
      scheduledAt: scheduledAt,
      description: description,
      thumbnail: thumbnail,
    );
  }

  Future<void> addCoHost(String streamId, String userId) async {
    await _dataSource.addCoHost(streamId, userId);
  }

  Future<void> removeCoHost(String streamId, String userId) async {
    await _dataSource.removeCoHost(streamId, userId);
  }

  Future<void> startRecording(String streamId) async {
    await _dataSource.startRecording(streamId);
  }

  Future<void> stopRecording(String streamId) async {
    await _dataSource.stopRecording(streamId);
  }

  Future<void> banUser(String streamId, String userId, {String? reason}) async {
    await _dataSource.banUserFromStream(streamId, userId, reason: reason);
  }

  Future<void> muteUser(String streamId, String userId) async {
    await _dataSource.muteUserInStream(streamId, userId);
  }
}

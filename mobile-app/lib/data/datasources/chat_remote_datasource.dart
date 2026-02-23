import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final ApiClient _client;

  ChatRemoteDataSource(this._client);

  Future<PaginatedResponse<ChatMessageModel>> getStreamMessages(
    String streamId, {
    int page = 1,
    int pageSize = 50,
    String? beforeMessageId,
  }) async {
    final response = await _client.get<PaginatedResponse<ChatMessageModel>>(
      '/chat/streams/$streamId/messages',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (beforeMessageId != null) 'before': beforeMessageId,
      },
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => ChatMessageModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<ChatMessageModel> sendMessage({
    required String streamId,
    required String content,
    required String type,
    Map<String, dynamic>? metadata,
    String? replyToId,
  }) async {
    final response = await _client.post<ChatMessageModel>(
      '/chat/streams/$streamId/messages',
      data: {
        'content': content,
        'type': type,
        if (metadata != null) 'metadata': metadata,
        if (replyToId != null) 'replyToId': replyToId,
      },
      fromJson: (data) => ChatMessageModel.fromJson(data),
    );
    return response.data!;
  }

  Future<void> deleteMessage(String messageId) async {
    await _client.delete('/chat/messages/$messageId');
  }

  Future<void> pinMessage(String messageId) async {
    await _client.post('/chat/messages/$messageId/pin');
  }

  Future<void> unpinMessage(String messageId) async {
    await _client.delete('/chat/messages/$messageId/pin');
  }

  Future<void> reactToMessage(String messageId, String emoji) async {
    await _client.post('/chat/messages/$messageId/react', data: {'emoji': emoji});
  }

  Future<PaginatedResponse<ChatMessageModel>> getDirectMessages(
    String userId, {
    int page = 1,
    int pageSize = 30,
    String? beforeMessageId,
  }) async {
    final response = await _client.get<PaginatedResponse<ChatMessageModel>>(
      '/chat/dms/$userId',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (beforeMessageId != null) 'before': beforeMessageId,
      },
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => ChatMessageModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<ChatMessageModel> sendDirectMessage({
    required String userId,
    required String content,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _client.post<ChatMessageModel>(
      '/chat/dms/$userId',
      data: {
        'content': content,
        'type': type,
        if (metadata != null) 'metadata': metadata,
      },
      fromJson: (data) => ChatMessageModel.fromJson(data),
    );
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<List<Map<String, dynamic>>>(
      '/chat/threads',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return response.data ?? [];
  }
}

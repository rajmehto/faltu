import '../../core/network/api_response.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl {
  final ChatRemoteDataSource _dataSource;

  ChatRepositoryImpl(this._dataSource);

  Future<PaginatedResponse<ChatMessageModel>> getStreamMessages(
    String streamId, {
    int page = 1,
    int pageSize = 50,
    String? beforeMessageId,
  }) async {
    return _dataSource.getStreamMessages(
      streamId,
      page: page,
      pageSize: pageSize,
      beforeMessageId: beforeMessageId,
    );
  }

  Future<ChatMessageModel> sendMessage({
    required String streamId,
    required String content,
    required String type,
    Map<String, dynamic>? metadata,
    String? replyToId,
  }) async {
    return _dataSource.sendMessage(
      streamId: streamId,
      content: content,
      type: type,
      metadata: metadata,
      replyToId: replyToId,
    );
  }

  Future<void> deleteMessage(String messageId) async =>
      _dataSource.deleteMessage(messageId);

  Future<void> pinMessage(String messageId) async =>
      _dataSource.pinMessage(messageId);

  Future<void> unpinMessage(String messageId) async =>
      _dataSource.unpinMessage(messageId);

  Future<void> reactToMessage(String messageId, String emoji) async =>
      _dataSource.reactToMessage(messageId, emoji);

  Future<PaginatedResponse<ChatMessageModel>> getDirectMessages(
    String userId, {
    int page = 1,
    int pageSize = 30,
    String? beforeMessageId,
  }) async {
    return _dataSource.getDirectMessages(
      userId,
      page: page,
      pageSize: pageSize,
      beforeMessageId: beforeMessageId,
    );
  }

  Future<ChatMessageModel> sendDirectMessage({
    required String userId,
    required String content,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    return _dataSource.sendDirectMessage(
      userId: userId,
      content: content,
      type: type,
      metadata: metadata,
    );
  }

  Future<List<Map<String, dynamic>>> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getConversations(page: page, pageSize: pageSize);
  }
}

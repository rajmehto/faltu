import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/config/app_config.dart';
import '../data/models/chat_message_model.dart';
import '../data/models/gift_model.dart';
import 'auth_service.dart';

typedef MessageCallback = void Function(ChatMessageModel message);
typedef GiftCallback = void Function(GiftAnimationEvent event);
typedef ReactionCallback = void Function(ReactionEvent event);
typedef ViewerCallback = void Function(int count);
typedef UserEventCallback = void Function(String userId);

class SocketService extends GetxService {
  io.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  final Map<String, List<Function>> _listeners = {};

  void connect() {
    if (isConnected) return;

    final authService = Get.find<AuthService>();
    final token = authService.accessToken;

    _socket = io.io(
      AppConfig.wsBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _emit('ping', null);
    });

    _socket!.onDisconnect((_) {});

    _socket!.onConnectError((error) {
      Get.snackbar('Connection Error', 'Failed to connect to real-time service');
    });

    _socket!.onReconnect((_) {});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _listeners.clear();
  }

  void joinStream(String streamId) {
    _emit('stream:join', {'streamId': streamId});
  }

  void leaveStream(String streamId) {
    _emit('stream:leave', {'streamId': streamId});
  }

  void sendChatMessage({
    required String streamId,
    required String content,
    required String type,
    Map<String, dynamic>? metadata,
    String? replyToId,
  }) {
    _emit('chat:send', {
      'streamId': streamId,
      'content': content,
      'type': type,
      if (metadata != null) 'metadata': metadata,
      if (replyToId != null) 'replyToId': replyToId,
    });
  }

  void sendGift({
    required String streamId,
    required String giftId,
    int quantity = 1,
  }) {
    _emit('gift:send', {
      'streamId': streamId,
      'giftId': giftId,
      'quantity': quantity,
    });
  }

  void sendReaction({
    required String streamId,
    required String emoji,
  }) {
    _emit('reaction:send', {
      'streamId': streamId,
      'emoji': emoji,
    });
  }

  void sendLike(String streamId) {
    _emit('stream:like', {'streamId': streamId});
  }

  void startTyping(String streamId) {
    _emit('typing:start', {'streamId': streamId});
  }

  void stopTyping(String streamId) {
    _emit('typing:stop', {'streamId': streamId});
  }

  void joinRoom(String roomId) {
    _emit('room:join', {'roomId': roomId});
  }

  void leaveRoom(String roomId) {
    _emit('room:leave', {'roomId': roomId});
  }

  void onChatMessage(String streamId, MessageCallback callback) {
    _on('chat:message:$streamId', (data) {
      callback(ChatMessageModel.fromJson(data));
    });
  }

  void onGiftReceived(String streamId, GiftCallback callback) {
    _on('gift:received:$streamId', (data) {
      callback(GiftAnimationEvent.fromJson(data));
    });
  }

  void onReaction(String streamId, ReactionCallback callback) {
    _on('reaction:received:$streamId', (data) {
      callback(ReactionEvent.fromJson(data));
    });
  }

  void onViewerCountChanged(String streamId, ViewerCallback callback) {
    _on('stream:viewers:$streamId', (data) {
      callback(data['count'] ?? 0);
    });
  }

  void onUserJoined(String streamId, UserEventCallback callback) {
    _on('user:joined:$streamId', (data) {
      callback(data['userId']);
    });
  }

  void onUserLeft(String streamId, UserEventCallback callback) {
    _on('user:left:$streamId', (data) {
      callback(data['userId']);
    });
  }

  void onStreamEnded(String streamId, void Function() callback) {
    _on('stream:ended:$streamId', (_) => callback());
  }

  void onNotification(void Function(Map<String, dynamic>) callback) {
    _on('notification', (data) => callback(data));
  }

  void offStream(String streamId) {
    _off('chat:message:$streamId');
    _off('gift:received:$streamId');
    _off('reaction:received:$streamId');
    _off('stream:viewers:$streamId');
    _off('user:joined:$streamId');
    _off('user:left:$streamId');
    _off('stream:ended:$streamId');
  }

  void _emit(String event, dynamic data) {
    if (!isConnected) {
      connect();
    }
    _socket?.emit(event, data);
  }

  void _on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
    _listeners[event] = [...(_listeners[event] ?? []), callback];
  }

  void _off(String event) {
    _socket?.off(event);
    _listeners.remove(event);
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}

class GiftAnimationEvent {
  final String giftId;
  final String giftName;
  final String giftImage;
  final String? giftAnimation;
  final String? giftSound;
  final int quantity;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final double value;

  GiftAnimationEvent({
    required this.giftId,
    required this.giftName,
    required this.giftImage,
    this.giftAnimation,
    this.giftSound,
    required this.quantity,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.value,
  });

  factory GiftAnimationEvent.fromJson(Map<String, dynamic> json) {
    return GiftAnimationEvent(
      giftId: json['giftId'] ?? '',
      giftName: json['giftName'] ?? '',
      giftImage: json['giftImage'] ?? '',
      giftAnimation: json['giftAnimation'],
      giftSound: json['giftSound'],
      quantity: json['quantity'] ?? 1,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'],
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}

class ReactionEvent {
  final String emoji;
  final String userId;
  final String userName;

  ReactionEvent({
    required this.emoji,
    required this.userId,
    required this.userName,
  });

  factory ReactionEvent.fromJson(Map<String, dynamic> json) {
    return ReactionEvent(
      emoji: json['emoji'] ?? '❤️',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
    );
  }
}

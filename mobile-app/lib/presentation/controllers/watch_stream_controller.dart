import 'dart:async';
import 'package:get/get.dart';

import '../../data/models/stream_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/stream_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../services/agora_service.dart';
import '../../services/socket_service.dart';
import '../../services/analytics_service.dart';

class WatchStreamController extends GetxController {
  final String streamId;
  WatchStreamController(this.streamId);

  final StreamRepositoryImpl _streamRepo = Get.find<StreamRepositoryImpl>();
  final ChatRepositoryImpl _chatRepo = Get.find<ChatRepositoryImpl>();
  final AgoraService _agoraService = Get.find<AgoraService>();
  final SocketService _socketService = Get.find<SocketService>();
  final AnalyticsService _analytics = Get.find<AnalyticsService>();

  final Rx<StreamModel?> stream = Rx<StreamModel?>(null);
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxInt viewerCount = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isChatVisible = true.obs;
  final RxBool isGiftPanelOpen = false.obs;
  final RxBool isLiked = false.obs;
  final TextEditingController? chatController = null;

  DateTime? _joinTime;

  @override
  void onInit() {
    super.onInit();
    _loadStream();
  }

  Future<void> _loadStream() async {
    isLoading.value = true;
    try {
      stream.value = await _streamRepo.getStream(streamId);
      await _joinStream();
      await _loadChatHistory();
      _setupSocketListeners();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load stream');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _joinStream() async {
    try {
      final result = await _streamRepo.joinStream(streamId);
      _joinTime = DateTime.now();

      await _agoraService.joinAsAudience(
        channelName: result.agoraConfig.channelName,
        token: result.agoraConfig.token,
        uid: result.agoraConfig.uid,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to join stream');
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final result = await _chatRepo.getStreamMessages(streamId, pageSize: 50);
      messages.addAll(result.items);
    } catch (_) {}
  }

  void _setupSocketListeners() {
    _socketService.connect();
    _socketService.joinStream(streamId);

    _socketService.onChatMessage(streamId, (message) {
      messages.add(message);
      if (messages.length > 200) messages.removeAt(0);
    });

    _socketService.onViewerCountChanged(streamId, (count) {
      viewerCount.value = count;
    });

    _socketService.onStreamEnded(streamId, () {
      Get.snackbar('Stream Ended', 'The streamer has ended this stream');
      Future.delayed(const Duration(seconds: 2), () => Get.back());
    });
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      await _chatRepo.sendMessage(
        streamId: streamId,
        content: content.trim(),
        type: 'text',
      );
      await _analytics.logChatMessage(streamId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  void toggleLike() {
    isLiked.value = !isLiked.value;
    _streamRepo.likeStream(streamId);
  }

  void toggleChat() {
    isChatVisible.value = !isChatVisible.value;
  }

  void toggleGiftPanel() {
    isGiftPanelOpen.value = !isGiftPanelOpen.value;
  }

  Future<void> leaveStream() async {
    final watchDuration = _joinTime != null
        ? DateTime.now().difference(_joinTime!).inSeconds
        : 0;

    await _analytics.logStreamWatched(
      streamId: streamId,
      watchDurationSeconds: watchDuration,
      streamerId: stream.value?.streamerId ?? '',
    );

    await _agoraService.leaveChannel();
    await _streamRepo.leaveStream(streamId);
    _socketService.offStream(streamId);
    _socketService.leaveStream(streamId);
  }

  @override
  void onClose() {
    leaveStream();
    super.onClose();
  }
}

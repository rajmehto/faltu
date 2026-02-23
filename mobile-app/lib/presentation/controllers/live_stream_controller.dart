import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../data/models/stream_model.dart';
import '../../data/repositories/stream_repository_impl.dart';
import '../../services/agora_service.dart';
import '../../services/socket_service.dart';
import '../../services/analytics_service.dart';
import '../../core/constants/app_constants.dart';

class LiveStreamController extends GetxController {
  final StreamRepositoryImpl _streamRepo = Get.find<StreamRepositoryImpl>();
  final AgoraService agoraService = Get.find<AgoraService>();
  final SocketService _socketService = Get.find<SocketService>();
  final AnalyticsService _analytics = Get.find<AnalyticsService>();

  StreamModel? currentStream;
  AgoraConfig? agoraConfig;

  final RxBool isStreaming = false.obs;
  final RxBool isMicEnabled = true.obs;
  final RxBool isCameraEnabled = true.obs;
  final RxBool isFrontCamera = true.obs;
  final RxBool isRecording = false.obs;
  final RxBool showBeautyPanel = false.obs;
  final RxBool showSettingsPanel = false.obs;
  final RxBool showCoHostPanel = false.obs;
  final RxBool showGiftsPanel = false.obs;
  final RxInt viewerCount = 0.obs;
  final Rx<Duration> streamDuration = Duration.zero.obs;
  final RxDouble beautyLevel = 0.5.obs;
  final RxInt videoQuality = AppConstants.streamQualityMedium.obs;
  final RxString selectedFilter = 'none'.obs;

  Timer? _durationTimer;
  DateTime? _streamStartTime;

  @override
  void onInit() {
    super.onInit();
    ever(agoraService.viewerCount, (count) => viewerCount.value = count);
    ever(agoraService.isMicEnabled, (enabled) => isMicEnabled.value = enabled);
    ever(agoraService.isCameraEnabled, (enabled) => isCameraEnabled.value = enabled);
    ever(agoraService.isFrontCamera, (front) => isFrontCamera.value = front);
  }

  Future<bool> startStream({
    required String title,
    String? description,
    required String category,
    List<String>? tags,
    required String privacy,
    bool recordingEnabled = false,
    String? thumbnail,
  }) async {
    try {
      final hasPermission = await agoraService.requestPermissions();
      if (!hasPermission) {
        Get.snackbar('Permission Required', 'Camera and microphone access is required');
        return false;
      }

      final result = await _streamRepo.startStream(
        title: title,
        description: description,
        category: category,
        tags: tags,
        privacy: privacy,
        recordingEnabled: recordingEnabled,
        thumbnail: thumbnail,
      );

      currentStream = result.stream;
      agoraConfig = result.agoraConfig;

      await agoraService.startBroadcast(
        channelName: agoraConfig!.channelName,
        token: agoraConfig!.token,
        uid: agoraConfig!.uid,
        videoQuality: videoQuality.value,
      );

      _socketService.connect();
      _socketService.joinStream(currentStream!.streamId);

      _socketService.onViewerCountChanged(
        currentStream!.streamId,
        (count) => viewerCount.value = count,
      );

      _streamStartTime = DateTime.now();
      _startDurationTimer();
      isStreaming.value = true;

      await _analytics.logStreamStarted(currentStream!.streamId, category);

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to start stream: ${e.toString()}');
      return false;
    }
  }

  Future<void> endStream() async {
    if (currentStream == null) return;

    _durationTimer?.cancel();

    try {
      await _streamRepo.endStream(currentStream!.streamId);
    } catch (_) {}

    await agoraService.leaveChannel();
    _socketService.leaveStream(currentStream!.streamId);

    final watchDuration = _streamStartTime != null
        ? DateTime.now().difference(_streamStartTime!).inSeconds
        : 0;

    await _analytics.logStreamWatched(
      streamId: currentStream!.streamId,
      watchDurationSeconds: watchDuration,
      streamerId: currentStream!.streamerId,
    );

    isStreaming.value = false;
    Get.back();
  }

  void toggleMic() {
    agoraService.toggleMic();
  }

  void toggleCamera() {
    agoraService.toggleCamera();
  }

  void flipCamera() {
    agoraService.switchCamera();
  }

  void toggleBeautyPanel() {
    showBeautyPanel.value = !showBeautyPanel.value;
    showSettingsPanel.value = false;
    showCoHostPanel.value = false;
  }

  void toggleSettingsPanel() {
    showSettingsPanel.value = !showSettingsPanel.value;
    showBeautyPanel.value = false;
    showCoHostPanel.value = false;
  }

  void toggleCoHostPanel() {
    showCoHostPanel.value = !showCoHostPanel.value;
    showBeautyPanel.value = false;
    showSettingsPanel.value = false;
  }

  Future<void> applyBeautyFilter({
    double? smoothness,
    double? lightening,
    double? sharpness,
  }) async {
    await agoraService.enableBeautyEffect(
      smoothnessLevel: smoothness ?? beautyLevel.value,
      lighteningLevel: lightening ?? 0.3,
      sharpnessLevel: sharpness ?? 0.1,
    );
  }

  Future<void> removeBeautyFilter() async {
    await agoraService.disableBeautyEffect();
  }

  Future<void> setVideoQuality(int quality) async {
    videoQuality.value = quality;
    await agoraService.setVideoQuality(quality);
  }

  Future<void> startRecording() async {
    if (currentStream == null) return;
    await _streamRepo.startRecording(currentStream!.streamId);
    isRecording.value = true;
  }

  Future<void> stopRecording() async {
    if (currentStream == null) return;
    await _streamRepo.stopRecording(currentStream!.streamId);
    isRecording.value = false;
  }

  Future<void> addCoHost(String userId) async {
    if (currentStream == null) return;
    await _streamRepo.addCoHost(currentStream!.streamId, userId);
  }

  Future<void> removeCoHost(String userId) async {
    if (currentStream == null) return;
    await _streamRepo.removeCoHost(currentStream!.streamId, userId);
  }

  Future<void> banUser(String userId) async {
    if (currentStream == null) return;
    await _streamRepo.banUser(currentStream!.streamId, userId);
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_streamStartTime != null) {
        streamDuration.value = DateTime.now().difference(_streamStartTime!);
      }
    });
  }

  @override
  void onClose() {
    _durationTimer?.cancel();
    super.onClose();
  }
}

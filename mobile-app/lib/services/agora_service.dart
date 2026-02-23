import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';

enum StreamRole { broadcaster, audience }

class AgoraService extends GetxService {
  late RtcEngine _engine;
  bool _isInitialized = false;

  final RxBool isMicEnabled = true.obs;
  final RxBool isCameraEnabled = true.obs;
  final RxBool isFrontCamera = true.obs;
  final RxBool isSpeakerEnabled = true.obs;
  final RxInt viewerCount = 0.obs;
  final RxList<int> remoteUserIds = <int>[].obs;

  int _localUid = 0;
  String _currentChannel = '';

  Future<void> initialize() async {
    if (_isInitialized) return;

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: AppConfig.agoraAppId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        _localUid = connection.localUid ?? 0;
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        remoteUserIds.add(remoteUid);
        viewerCount.value = remoteUserIds.length;
      },
      onUserOffline: (connection, remoteUid, reason) {
        remoteUserIds.remove(remoteUid);
        viewerCount.value = remoteUserIds.length;
      },
      onError: (err, msg) {
        Get.snackbar('Stream Error', msg ?? err.toString());
      },
      onNetworkQuality: (connection, remoteUid, txQuality, rxQuality) {},
      onRtcStats: (connection, stats) {},
    ));

    await _engine.enableVideo();
    await _engine.enableAudio();

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    return camera.isGranted && microphone.isGranted;
  }

  Future<void> startBroadcast({
    required String channelName,
    required String token,
    required int uid,
    int videoQuality = AppConstants.streamQualityMedium,
  }) async {
    await initialize();

    _currentChannel = channelName;

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    await _engine.setVideoEncoderConfiguration(
      VideoEncoderConfiguration(
        dimensions: VideoDimensions(
          width: videoQuality == AppConstants.streamQualityHigh ? 1920 : 
                 videoQuality == AppConstants.streamQualityMedium ? 1280 : 640,
          height: videoQuality == AppConstants.streamQualityHigh ? 1080 : 
                  videoQuality == AppConstants.streamQualityMedium ? 720 : 360,
        ),
        frameRate: AppConstants.streamFrameRate,
        bitrate: videoQuality == AppConstants.streamQualityHigh
            ? AppConstants.streamBitrateHigh
            : videoQuality == AppConstants.streamQualityMedium
                ? AppConstants.streamBitrateMedium
                : AppConstants.streamBitrateLow,
      ),
    );

    await _engine.startPreview();
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  Future<void> joinAsAudience({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    await initialize();

    _currentChannel = channelName;

    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  Future<void> leaveChannel() async {
    if (!_isInitialized) return;
    await _engine.leaveChannel();
    remoteUserIds.clear();
    viewerCount.value = 0;
    _currentChannel = '';
  }

  Future<void> toggleMic() async {
    isMicEnabled.value = !isMicEnabled.value;
    await _engine.muteLocalAudioStream(!isMicEnabled.value);
  }

  Future<void> toggleCamera() async {
    isCameraEnabled.value = !isCameraEnabled.value;
    await _engine.muteLocalVideoStream(!isCameraEnabled.value);
  }

  Future<void> switchCamera() async {
    isFrontCamera.value = !isFrontCamera.value;
    await _engine.switchCamera();
  }

  Future<void> toggleSpeaker() async {
    isSpeakerEnabled.value = !isSpeakerEnabled.value;
    await _engine.setEnableSpeakerphone(isSpeakerEnabled.value);
  }

  Future<void> setVideoQuality(int quality) async {
    await _engine.setVideoEncoderConfiguration(
      VideoEncoderConfiguration(
        dimensions: VideoDimensions(
          width: quality == AppConstants.streamQualityHigh ? 1920 : 
                 quality == AppConstants.streamQualityMedium ? 1280 : 640,
          height: quality == AppConstants.streamQualityHigh ? 1080 : 
                  quality == AppConstants.streamQualityMedium ? 720 : 360,
        ),
        frameRate: AppConstants.streamFrameRate,
        bitrate: quality == AppConstants.streamQualityHigh
            ? AppConstants.streamBitrateHigh
            : quality == AppConstants.streamQualityMedium
                ? AppConstants.streamBitrateMedium
                : AppConstants.streamBitrateLow,
      ),
    );
  }

  Future<void> enableBeautyEffect({
    double smoothnessLevel = 0.5,
    double lighteningLevel = 0.3,
    double sharpnessLevel = 0.1,
  }) async {
    await _engine.setBeautyEffectOptions(
      enabled: true,
      options: BeautyOptions(
        smoothnessLevel: smoothnessLevel,
        lighteningLevel: lighteningLevel,
        sharpnessLevel: sharpnessLevel,
        lighteningContrastLevel: LighteningContrastLevel.lighteningContrastNormal,
      ),
    );
  }

  Future<void> disableBeautyEffect() async {
    await _engine.setBeautyEffectOptions(
      enabled: false,
      options: const BeautyOptions(),
    );
  }

  Future<void> enableVirtualBackground(String imagePath) async {
    await _engine.enableVirtualBackground(
      enabled: true,
      backgroundSource: VirtualBackgroundSource(
        backgroundSourceType: BackgroundSourceType.backgroundImg,
        source: imagePath,
      ),
      segproperty: const SegmentationProperty(),
    );
  }

  Future<void> disableVirtualBackground() async {
    await _engine.enableVirtualBackground(
      enabled: false,
      backgroundSource: const VirtualBackgroundSource(),
      segproperty: const SegmentationProperty(),
    );
  }

  Future<void> startScreenShare() async {
    await _engine.startScreenCaptureMobile(
      captureParams: const ScreenCaptureParameters2(
        captureAudio: true,
        captureVideo: true,
      ),
    );
  }

  Future<void> stopScreenShare() async {
    await _engine.stopScreenCapture();
  }

  Widget createLocalVideoView() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget createRemoteVideoView(int remoteUid) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: remoteUid),
        connection: RtcConnection(channelId: _currentChannel),
      ),
    );
  }

  @override
  void onClose() {
    if (_isInitialized) {
      _engine.release();
    }
    super.onClose();
  }
}

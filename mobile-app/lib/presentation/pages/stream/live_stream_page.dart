import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/live_stream_controller.dart';
import '../../widgets/stream/beauty_filter_panel.dart';
import '../../widgets/stream/stream_chat_overlay.dart';
import '../../widgets/stream/gift_animation_widget.dart';
import '../../widgets/stream/stream_controls.dart';
import '../../widgets/stream/stream_settings_panel.dart';
import '../../widgets/stream/co_host_panel.dart';
import '../../dialogs/go_live_dialog.dart';

class LiveStreamPage extends StatefulWidget {
  const LiveStreamPage({super.key});

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  final LiveStreamController _controller = Get.put(LiveStreamController());

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _showGoLiveDialog();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showGoLiveDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const GoLiveDialog(),
      );
      if (result != true && mounted) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!_controller.isStreaming.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        return Stack(
          children: [
            _buildCameraPreview(),
            _buildOverlay(),
          ],
        );
      }),
    );
  }

  Widget _buildCameraPreview() {
    return Positioned.fill(
      child: _controller.agoraService.createLocalVideoView(),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Stack(
        children: [
          _buildGradients(),
          _buildTopBar(),
          _buildViewerCount(),
          Obx(() => _controller.showBeautyPanel.value
              ? const BeautyFilterPanel()
              : const SizedBox.shrink()),
          Obx(() => _controller.showCoHostPanel.value
              ? const CoHostPanel()
              : const SizedBox.shrink()),
          const StreamChatOverlay(),
          const GiftAnimationWidget(),
          StreamControls(onEndStream: _confirmEndStream),
          Obx(() => _controller.showSettingsPanel.value
              ? const StreamSettingsPanel()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildGradients() {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => _buildStreamDuration()),
              const Spacer(),
              IconButton(
                onPressed: () => _controller.toggleSettingsPanel(),
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
              IconButton(
                onPressed: _confirmEndStream,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamDuration() {
    final duration = _controller.streamDuration.value;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final formatted = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        formatted,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildViewerCount() {
    return Positioned(
      top: 80,
      right: 16,
      child: Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _controller.viewerCount.value.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          )),
    );
  }

  Future<void> _confirmEndStream() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('End Stream?'),
        content: const Text('Are you sure you want to end your live stream?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Stream'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.endStream();
    }
  }
}

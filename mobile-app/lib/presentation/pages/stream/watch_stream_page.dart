import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/watch_stream_controller.dart';

class WatchStreamPage extends StatefulWidget {
  final String streamId;
  const WatchStreamPage({super.key, required this.streamId});

  @override
  State<WatchStreamPage> createState() => _WatchStreamPageState();
}

class _WatchStreamPageState extends State<WatchStreamPage> {
  late WatchStreamController _controller;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = Get.put(WatchStreamController(widget.streamId));
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.black),
            ),
            _buildTopBar(),
            _buildChatSection(),
            _buildBottomControls(),
          ],
        );
      }),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Obx(() => _controller.stream.value != null
                  ? CircleAvatar(
                      backgroundImage: _controller.stream.value?.streamer?.avatar != null
                          ? NetworkImage(_controller.stream.value!.streamer!.avatar!)
                          : null,
                      radius: 20,
                      child: _controller.stream.value?.streamer?.avatar == null
                          ? const Icon(Icons.person) : null,
                    )
                  : const CircleAvatar(radius: 20, child: Icon(Icons.person))),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _controller.stream.value?.streamer?.displayName ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _controller.stream.value?.title ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                )),
              ),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text('${_controller.viewerCount.value}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              )),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatSection() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 80,
      height: 250,
      child: Obx(() => ListView.builder(
        itemCount: _controller.messages.length,
        itemBuilder: (_, i) {
          final msg = _controller.messages[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${msg.sender?.displayName ?? msg.userId}: ',
                  style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ],
            ),
          );
        },
      )),
    );
  }

  Widget _buildBottomControls() {
    final chatTextController = TextEditingController();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: chatTextController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Say something...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (v) {
                      _controller.sendMessage(v);
                      chatTextController.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => GestureDetector(
                onTap: _controller.toggleLike,
                child: Icon(
                  _controller.isLiked.value ? Icons.favorite : Icons.favorite_border,
                  color: _controller.isLiked.value ? Colors.red : Colors.white,
                  size: 28,
                ),
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _controller.toggleGiftPanel,
                child: const Icon(Icons.card_giftcard, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

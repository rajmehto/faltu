import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class StreamReplayPage extends StatelessWidget {
  final String streamId;
  const StreamReplayPage({super.key, required this.streamId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back, color: Colors.white)),
        title: const Text('Replay', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_fill, size: 72, color: AppTheme.primaryColor),
                    SizedBox(height: 16),
                    Text('Stream Replay', style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Replay playback is being prepared...', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceDark,
            child: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(activeTrackColor: AppTheme.primaryColor, thumbColor: AppTheme.primaryColor),
                    child: Slider(value: 0, onChanged: (_) {}),
                  ),
                ),
                const Text('00:00', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

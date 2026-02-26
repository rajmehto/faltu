import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class VoiceRoomPage extends StatelessWidget {
  final String roomId;
  const VoiceRoomPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Voice Room'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text('Room: $roomId', style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Leave Room'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, minimumSize: const Size(200, 48)),
            ),
          ],
        ),
      ),
    );
  }
}

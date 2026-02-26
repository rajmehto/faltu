import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class RoomListPage extends StatelessWidget {
  const RoomListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Voice Rooms'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_none, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('No active voice rooms', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Messages'),
        actions: [
          IconButton(
            onPressed: () => context.push('/discover/search'),
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('No messages yet', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
            SizedBox(height: 8),
            Text('Follow users to start chatting', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

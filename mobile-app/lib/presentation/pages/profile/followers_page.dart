import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class FollowersPage extends StatelessWidget {
  const FollowersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Followers'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 0,
        itemBuilder: (_, i) => const SizedBox.shrink(),
      ),
    );
  }
}

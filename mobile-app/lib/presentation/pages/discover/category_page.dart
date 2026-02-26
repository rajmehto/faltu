import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class CategoryPage extends StatelessWidget {
  final String categoryId;
  const CategoryPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: Text(categoryId),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.live_tv, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              'No live streams in $categoryId',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

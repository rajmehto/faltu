import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final RxString _selectedCategory = 'All'.obs;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view},
    {'name': 'Gaming', 'icon': Icons.sports_esports},
    {'name': 'Music', 'icon': Icons.music_note},
    {'name': 'Dance', 'icon': Icons.celebration},
    {'name': 'Talk', 'icon': Icons.chat_bubble},
    {'name': 'Sports', 'icon': Icons.sports},
    {'name': 'Cooking', 'icon': Icons.restaurant},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Travel', 'icon': Icons.flight},
    {'name': 'Fashion', 'icon': Icons.checkroom},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: GestureDetector(
          onTap: () => context.push('/discover/search'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.dividerDark),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                SizedBox(width: 8),
                Text('Search streams, users...', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryChips(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 56,
      child: Obx(() => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory.value == cat['name'];
          return GestureDetector(
            onTap: () => _selectedCategory.value = cat['name'] as String,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.dividerDark),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    cat['name'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('🔥 Trending Now', _buildTrendingList()),
        const SizedBox(height: 24),
        _buildSection('🌍 Browse by Category', _buildCategoryGrid()),
        const SizedBox(height: 24),
        _buildSection('⭐ Featured Events', _buildEventsList()),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildTrendingList() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _TrendingCard(rank: i + 1),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _categories.length - 1,
      itemBuilder: (_, i) {
        final cat = _categories[i + 1];
        return GestureDetector(
          onTap: () => context.push('/discover/category/${cat['name']}'),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerDark),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'] as IconData, color: AppTheme.primaryColor, size: 28),
                const SizedBox(height: 6),
                Text(cat['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => Container(
          width: 200,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Event ${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Upcoming event', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final int rank;
  const _TrendingCard({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppTheme.surfaceDark, child: const Center(child: Icon(Icons.live_tv, color: AppTheme.textMuted, size: 32))),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: AppTheme.goldenGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('#$rank', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

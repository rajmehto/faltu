import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final RxString _query = ''.obs;
  final RxString _activeTab = 'streams'.obs;

  static const _recentSearches = ['Gaming', 'K-pop', 'Cooking stream', 'Fitness'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search streams, users...',
            hintStyle: TextStyle(color: AppTheme.textMuted),
            border: InputBorder.none,
          ),
          onChanged: (v) => _query.value = v,
        ),
        actions: [
          Obx(() => _query.value.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _query.value = '';
                  },
                  icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                )
              : const SizedBox.shrink()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBar(),
        ),
      ),
      body: Obx(() => _query.value.isEmpty ? _buildRecentSearches() : _buildResults()),
    );
  }

  Widget _buildTabBar() {
    return Obx(() => Row(
      children: ['streams', 'users', 'events'].map((tab) {
        final isSelected = _activeTab.value == tab;
        return Expanded(
          child: GestureDetector(
            onTap: () => _activeTab.value = tab,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab[0].toUpperCase() + tab.substring(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium),
        ),
        ..._recentSearches.map((s) => ListTile(
          leading: const Icon(Icons.history, color: AppTheme.textMuted),
          title: Text(s, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.north_west, color: AppTheme.textMuted, size: 16),
          onTap: () {
            _searchController.text = s;
            _query.value = s;
          },
        )),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Trending Topics', style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['#Gaming', '#Music', '#Dance', '#K-pop', '#Fitness', '#Cooking', '#ASMR']
                .map((tag) => GestureDetector(
                  onTap: () {
                    _searchController.text = tag;
                    _query.value = tag;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Text(tag, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
                  ),
                ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 56, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'Searching for "${_query.value}"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text('Results will appear here', style: TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

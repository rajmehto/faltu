import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class GiftStorePage extends StatefulWidget {
  const GiftStorePage({super.key});

  @override
  State<GiftStorePage> createState() => _GiftStorePageState();
}

class _GiftStorePageState extends State<GiftStorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _categories = ['Popular', 'Luxury', 'Cute', 'Funny', 'Love', 'Special'];

  static const List<Map<String, dynamic>> _sampleGifts = [
    {'name': 'Rose', 'price': 10, 'emoji': '🌹'},
    {'name': 'Heart', 'price': 50, 'emoji': '❤️'},
    {'name': 'Crown', 'price': 500, 'emoji': '👑'},
    {'name': 'Diamond', 'price': 1000, 'emoji': '💎'},
    {'name': 'Castle', 'price': 5000, 'emoji': '🏰'},
    {'name': 'Rocket', 'price': 200, 'emoji': '🚀'},
    {'name': 'Fire', 'price': 100, 'emoji': '🔥'},
    {'name': 'Star', 'price': 30, 'emoji': '⭐'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Gift Store'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/gifts/history'),
            icon: const Icon(Icons.history, size: 18),
            label: const Text('History'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Column(
        children: [
          _buildCoinBalance(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((_) => _buildGiftGrid()).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinBalance() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(bottom: BorderSide(color: AppTheme.dividerDark)),
      ),
      child: Row(
        children: [
          const Icon(Icons.toll, color: AppTheme.goldColor, size: 20),
          const SizedBox(width: 6),
          const Text('0 Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/wallet/purchase'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16)),
              child: const Text('Buy Coins', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _sampleGifts.length,
      itemBuilder: (_, i) => _GiftTile(gift: _sampleGifts[i]),
    );
  }
}

class _GiftTile extends StatelessWidget {
  final Map<String, dynamic> gift;
  const _GiftTile({required this.gift});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('Gift Selected', '${gift['name']} - ${gift['price']} coins', backgroundColor: AppTheme.primaryColor.withOpacity(0.9));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text(gift['emoji'] as String, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(height: 4),
          Text(gift['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 11), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.toll, color: AppTheme.goldColor, size: 10),
              const SizedBox(width: 2),
              Text('${gift['price']}', style: const TextStyle(color: AppTheme.goldColor, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

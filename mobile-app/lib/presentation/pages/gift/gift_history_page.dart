import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class GiftHistoryPage extends StatefulWidget {
  const GiftHistoryPage({super.key});

  @override
  State<GiftHistoryPage> createState() => _GiftHistoryPageState();
}

class _GiftHistoryPageState extends State<GiftHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Gift History'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [Tab(text: 'Sent'), Tab(text: 'Received')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _EmptyHistory(message: 'No gifts sent yet'),
          _EmptyHistory(message: 'No gifts received yet'),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final String message;
  const _EmptyHistory({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.card_giftcard, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppTheme.textMuted, fontSize: 16)),
        ],
      ),
    );
  }
}

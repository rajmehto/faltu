import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Transaction History'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        actions: [
          PopupMenuButton<String>(
            color: AppTheme.cardDark,
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('All', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'purchase', child: Text('Purchases', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'gift', child: Text('Gifts', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'withdrawal', child: Text('Withdrawals', style: TextStyle(color: Colors.white))),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.filter_list, color: Colors.white),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 64, color: AppTheme.textMuted),
            SizedBox(height: 16),
            Text('No transactions yet', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('My Wallet'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBalanceCard(context, user?.wallet),
          const SizedBox(height: 20),
          _buildActionsRow(context),
          const SizedBox(height: 24),
          _buildSection('Quick Actions', [
            _buildActionTile(context, Icons.add_circle_outline, 'Buy Coins', 'Top up your coin balance', AppTheme.primaryColor, () => context.push('/wallet/purchase')),
            _buildActionTile(context, Icons.money_off, 'Withdraw Diamonds', 'Convert diamonds to cash', AppTheme.goldColor, () => context.push('/wallet/withdraw')),
            _buildActionTile(context, Icons.history, 'Transaction History', 'View all transactions', AppTheme.infoColor, () => context.push('/wallet/transactions')),
            _buildActionTile(context, Icons.card_giftcard, 'Gift Store', 'Browse gifts to send', AppTheme.accentColor, () => context.push('/gifts')),
          ]),
          const SizedBox(height: 24),
          _buildSection('Diamond Exchange Rate', [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('1 Diamond', style: TextStyle(color: AppTheme.textSecondary)),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: AppTheme.goldColor, size: 16),
                          const Text('0.005 USD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: AppTheme.dividerDark),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('1 Coin', style: TextStyle(color: AppTheme.textSecondary)),
                      const Text('~\$0.01 USD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Revenue share: 70% to creators', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, dynamic wallet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.toll, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                '${wallet?.coins ?? 0}',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Text('Coins', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _balanceChip(Icons.diamond, '${wallet?.diamonds ?? 0}', 'Diamonds', AppTheme.accentLight),
              const SizedBox(width: 12),
              _balanceChip(Icons.star, '${wallet?.earnings ?? 0}', 'Earned', AppTheme.goldColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/wallet/purchase'),
            icon: const Icon(Icons.add),
            label: const Text('Buy Coins'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/wallet/withdraw'),
            icon: const Icon(Icons.money_off),
            label: const Text('Withdraw'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}

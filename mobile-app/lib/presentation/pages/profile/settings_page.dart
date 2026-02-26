import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Settings'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        children: [
          _buildSection('Account', [
            _buildTile(context, Icons.person_outline, 'Edit Profile', onTap: () => context.push('/profile/edit')),
            _buildTile(context, Icons.lock_outline, 'Privacy Settings', onTap: () => context.push('/profile/settings/privacy')),
            _buildTile(context, Icons.notifications_outlined, 'Notification Settings', onTap: () => context.push('/profile/settings/notifications')),
          ]),
          _buildSection('Wallet', [
            _buildTile(context, Icons.account_balance_wallet_outlined, 'My Wallet', onTap: () => context.push('/wallet')),
            _buildTile(context, Icons.history, 'Transaction History', onTap: () => context.push('/wallet/transactions')),
            _buildTile(context, Icons.money_off, 'Withdraw', onTap: () => context.push('/wallet/withdraw')),
          ]),
          _buildSection('Streaming', [
            _buildTile(context, Icons.analytics_outlined, 'Analytics', onTap: () => context.push('/analytics')),
            _buildTile(context, Icons.schedule, 'Schedule Stream', onTap: () => context.push('/schedule-stream')),
          ]),
          _buildSection('Support', [
            _buildTile(context, Icons.help_outline, 'Help & FAQ', onTap: () {}),
            _buildTile(context, Icons.feedback_outlined, 'Send Feedback', onTap: () {}),
            _buildTile(context, Icons.info_outline, 'About', onTap: () {}),
          ]),
          _buildSection('', [
            _buildTile(
              context,
              Icons.logout,
              'Sign Out',
              color: AppTheme.errorColor,
              onTap: () => _confirmSignOut(context),
            ),
          ]),
          const SizedBox(height: 32),
          const Center(
            child: Text('Tango Live v1.0.0', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          ),
        Container(
          color: AppTheme.surfaceDark,
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white, size: 22),
      title: Text(title, style: TextStyle(color: color ?? Colors.white, fontSize: 15)),
      trailing: color == null ? const Icon(Icons.chevron_right, color: AppTheme.textMuted) : null,
      onTap: onTap,
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Get.find<AuthService>().logout();
              context.go('/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}

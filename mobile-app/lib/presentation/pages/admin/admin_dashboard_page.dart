import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Admin Dashboard'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatGrid(),
          const SizedBox(height: 24),
          _buildSection(context, 'User Management', Icons.people, () {}),
          _buildSection(context, 'Live Streams', Icons.live_tv, () {}),
          _buildSection(context, 'Reports', Icons.report, () {}),
          _buildSection(context, 'Revenue', Icons.attach_money, () {}),
          _buildSection(context, 'Content Moderation', Icons.shield, () {}),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard('Total Users', '0', AppTheme.primaryColor),
        _buildStatCard('Live Now', '0', AppTheme.errorColor),
        _buildStatCard('Pending Reports', '0', AppTheme.warningColor),
        _buildStatCard('Revenue Today', '\$0', AppTheme.successColor),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}

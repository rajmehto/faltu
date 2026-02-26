import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class StreamerAnalyticsPage extends StatelessWidget {
  const StreamerAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Analytics'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildSection('Recent Streams', const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No streams yet', style: TextStyle(color: AppTheme.textMuted))))),
          const SizedBox(height: 24),
          _buildSection('Earnings', const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No earnings yet', style: TextStyle(color: AppTheme.textMuted))))),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard('Total Views', '0', Icons.remove_red_eye, AppTheme.primaryColor),
        _buildStatCard('Total Streams', '0', Icons.live_tv, AppTheme.accentColor),
        _buildStatCard('Diamonds Earned', '0', Icons.diamond, AppTheme.goldColor),
        _buildStatCard('New Followers', '0', Icons.person_add, AppTheme.successColor),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(16)),
          child: content,
        ),
      ],
    );
  }
}

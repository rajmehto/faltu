import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _followNotifications = true;
  bool _giftNotifications = true;
  bool _commentNotifications = true;
  bool _streamStartNotifications = true;
  bool _systemNotifications = true;
  bool _promotionNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Notification Settings'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        children: [
          _buildSection('Activity', [
            _buildSwitch('New Follower', _followNotifications, (v) => setState(() => _followNotifications = v)),
            _buildSwitch('Gift Received', _giftNotifications, (v) => setState(() => _giftNotifications = v)),
            _buildSwitch('Comments & Mentions', _commentNotifications, (v) => setState(() => _commentNotifications = v)),
            _buildSwitch('Stream Started', _streamStartNotifications, (v) => setState(() => _streamStartNotifications = v)),
          ]),
          _buildSection('System', [
            _buildSwitch('System Notifications', _systemNotifications, (v) => setState(() => _systemNotifications = v)),
            _buildSwitch('Promotions & Offers', _promotionNotifications, (v) => setState(() => _promotionNotifications = v)),
          ]),
          _buildSection('Sound & Vibration', [
            _buildSwitch('Sound', _soundEnabled, (v) => setState(() => _soundEnabled = v)),
            _buildSwitch('Vibration', _vibrationEnabled, (v) => setState(() => _vibrationEnabled = v)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Container(color: AppTheme.surfaceDark, child: Column(children: tiles)),
      ],
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }
}

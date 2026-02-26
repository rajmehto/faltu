import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _showFollowers = true;
  bool _showFollowing = true;
  bool _allowGifts = true;
  bool _showOnlineStatus = true;
  String _dmPermission = 'everyone';
  String _profileVisibility = 'public';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Privacy Settings'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        children: [
          _buildSection('Profile', [
            _buildDropdownTile('Profile Visibility', _profileVisibility, ['public', 'followers', 'private'], (v) => setState(() => _profileVisibility = v!)),
            _buildSwitchTile('Show Followers Count', _showFollowers, (v) => setState(() => _showFollowers = v)),
            _buildSwitchTile('Show Following Count', _showFollowing, (v) => setState(() => _showFollowing = v)),
            _buildSwitchTile('Show Online Status', _showOnlineStatus, (v) => setState(() => _showOnlineStatus = v)),
          ]),
          _buildSection('Messages & Gifts', [
            _buildDropdownTile('Who can DM me', _dmPermission, ['everyone', 'followers', 'none'], (v) => setState(() => _dmPermission = v!)),
            _buildSwitchTile('Allow Gifts from Strangers', _allowGifts, (v) => setState(() => _allowGifts = v)),
          ]),
          const SizedBox(height: 32),
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

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primaryColor),
    );
  }

  Widget _buildDropdownTile(String title, String value, List<String> options, ValueChanged<String?> onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: AppTheme.cardDark,
        style: const TextStyle(color: Colors.white),
        underline: const SizedBox.shrink(),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

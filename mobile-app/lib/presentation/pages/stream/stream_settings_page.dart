import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class StreamSettingsPage extends StatefulWidget {
  const StreamSettingsPage({super.key});

  @override
  State<StreamSettingsPage> createState() => _StreamSettingsPageState();
}

class _StreamSettingsPageState extends State<StreamSettingsPage> {
  bool _chatEnabled = true;
  bool _giftsEnabled = true;
  bool _recordingEnabled = false;
  bool _subscriptionOnly = false;
  String _privacy = 'public';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Stream Settings'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Save', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection('Visibility', [
            _buildDropdownTile('Privacy', _privacy, ['public', 'followers_only', 'private'], (v) => setState(() => _privacy = v!)),
          ]),
          _buildSection('Interaction', [
            _buildSwitch('Chat Enabled', _chatEnabled, (v) => setState(() => _chatEnabled = v)),
            _buildSwitch('Gifts Enabled', _giftsEnabled, (v) => setState(() => _giftsEnabled = v)),
            _buildSwitch('Subscription Only', _subscriptionOnly, (v) => setState(() => _subscriptionOnly = v)),
          ]),
          _buildSection('Recording', [
            _buildSwitch('Record Stream', _recordingEnabled, (v) => setState(() => _recordingEnabled = v)),
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
    return SwitchListTile(title: Text(title, style: const TextStyle(color: Colors.white)), value: value, onChanged: onChanged, activeColor: AppTheme.primaryColor);
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

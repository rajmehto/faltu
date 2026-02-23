import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StreamSettingsPage extends StatelessWidget {
  const StreamSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stream Settings')),
      body: const Center(child: Text('Stream Settings')),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TwoFactorPage extends StatelessWidget {
  const TwoFactorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Two Factor Authentication')),
      body: const Center(child: Text('Two Factor Authentication')),
    );
  }
}

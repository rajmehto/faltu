import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ScheduleStreamPage extends StatelessWidget {
  const ScheduleStreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Stream')),
      body: const Center(child: Text('Schedule Stream')),
    );
  }
}

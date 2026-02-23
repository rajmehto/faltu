import 'package:flutter/material.dart';

class DirectMessagePage extends StatelessWidget {
  final String userId;
  const DirectMessagePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(child: Text('Direct Messages')),
    );
  }
}

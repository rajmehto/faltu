import 'package:flutter/material.dart';

class VoiceRoomPage extends StatelessWidget {
  final String roomId;
  const VoiceRoomPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Room')),
      body: const Center(child: Text('Voice Room')),
    );
  }
}

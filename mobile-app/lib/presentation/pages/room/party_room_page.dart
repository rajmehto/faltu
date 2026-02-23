import 'package:flutter/material.dart';

class PartyRoomPage extends StatelessWidget {
  final String roomId;
  const PartyRoomPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Party Room')),
      body: const Center(child: Text('Party Room')),
    );
  }
}

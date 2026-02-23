import 'package:flutter/material.dart';

class StreamReplayPage extends StatelessWidget {
  final String streamId;
  const StreamReplayPage({super.key, required this.streamId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Replay')),
      body: Center(child: Text('Stream replay: $streamId')),
    );
  }
}

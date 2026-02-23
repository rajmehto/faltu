import 'package:flutter/material.dart';

class VerifyPhonePage extends StatelessWidget {
  final String phone;
  const VerifyPhonePage({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: Center(child: Text('Verify phone: $phone')),
    );
  }
}

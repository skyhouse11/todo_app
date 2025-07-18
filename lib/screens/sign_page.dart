import 'package:flutter/material.dart';

class SignPage extends StatelessWidget {
  const SignPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign In')),
    body: const Center(
      child: Text(
        'Authentication will be implemented here.',
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}

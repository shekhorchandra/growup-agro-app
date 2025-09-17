import 'package:flutter/material.dart';

class EcoCityPage extends StatelessWidget {
  const EcoCityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco City'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(''), // Empty body
      ),
    );
  }
}
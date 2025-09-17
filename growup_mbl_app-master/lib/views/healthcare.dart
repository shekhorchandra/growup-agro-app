import 'package:flutter/material.dart';

class HealthcarePage extends StatelessWidget {
  const HealthcarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Care'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(''), // Empty body
      ),
    );
  }
}

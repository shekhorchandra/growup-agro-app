// notification_page.dart
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          centerTitle: true,
          foregroundColor: Colors.white,
          title: const Text("Notifications", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
      body: const Center(
        child: Text("No new notifications."),
      ),
    );
  }
}

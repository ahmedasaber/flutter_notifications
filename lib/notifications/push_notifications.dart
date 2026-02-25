import 'package:flutter/material.dart';

 class PushNotifications extends StatelessWidget {
  const PushNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications'),
      ),
      body: const Center(
        child: Text('Push Notifications Setup Screen'),
      ),
    );
  }
}

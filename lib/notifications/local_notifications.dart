import 'package:flutter/material.dart';
import 'package:push_notifications/services/local_notifications_service.dart';

class LocalNotifications extends StatelessWidget {
  const LocalNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Notifications'),
        titleSpacing: 0.0,
        leading: const Icon(Icons.notifications),
        backgroundColor: Colors.amberAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NotificationSection(
              title: 'basic notification',
              onTap: () =>LocalNotificationsService.showNotification(),
              onCancel: () => LocalNotificationsService.cancelNotification(0),
            ),
            NotificationSection(
              title: 'Repeated notification',
              onTap: () => LocalNotificationsService.showRepeatedNotification(),
              onCancel: () => LocalNotificationsService.cancelNotification(1),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSection extends StatelessWidget {
  const NotificationSection({
    super.key, required this.title, required this.onTap, required this.onCancel,
  });

  final String title;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.notifications),
      title: Text(title),
      trailing: IconButton(
        onPressed: onCancel,
        icon: Icon(Icons.close),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:push_notifications/notifications/notification_details.dart';
import 'package:push_notifications/services/local_notifications_service.dart';

class LocalNotifications extends StatefulWidget {
  const LocalNotifications({super.key});

  @override
  State<LocalNotifications> createState() => _LocalNotificationsState();
}

class _LocalNotificationsState extends State<LocalNotifications> {

  void listenToLocalNotificationStream(){
    LocalNotificationsService.streamController.stream.listen(
      (notificationResponse){
        log('onTap');
        log('GG');
        log(notificationResponse.id!.toString());
        log(notificationResponse.payload!.toString());
        log(notificationResponse.data.toString());
        Navigator.push(
          context,
          NotificationDetailsScreen.route(
            NotificationDetails(
              id: notificationResponse.id!,
              title: 'notificationResponse.data[]',
              body:' notificationResponse.data[body]',
              type: NotificationType.basic,
              payload: notificationResponse.payload!.toString(),
              channelId: 'id 1',
              channelName: 'channel name',
              receivedAt: DateTime.now(),
              priority: 'High',
              importance: 'Max',
            ),
          ),
        );
      }
    );
  }
  @override
  void initState() {
    listenToLocalNotificationStream();
    super.initState();
  }
  @override
  void dispose() {
    LocalNotificationsService.streamController.close();
    super.dispose();
  }
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
            NotificationSection(
              title: 'Schedule notification',
              onTap: () => LocalNotificationsService.showScheduleNotification(),
              onCancel: () => LocalNotificationsService.cancelNotification(2),
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

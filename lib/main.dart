import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:push_notifications/firebase_options.dart';
import 'package:push_notifications/notifications/local_notifications.dart';
import 'package:push_notifications/notifications/push_notifications.dart';
import 'package:push_notifications/services/local_notifications_service.dart';
import 'package:push_notifications/services/push_notifications_services.dart';

// ─── Global Key ─── use it to navigate in local notification service
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  PushNotificationsServices.init();

  LocalNotificationsService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const LocalNotifications(),
    );
  }
}

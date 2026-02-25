import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsServices {

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> init() async{
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print("Firebase Messaging Token: $token");
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  }

}

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.notification?.title}');
}
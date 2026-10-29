import 'dart:async';
import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {

  /// *** [1] *** This object provides all notification-related functions, such as:
  ///   - [initialize] to set up the package.
  ///   - [show] to display a notification.
  ///   - [zonedSchedule] to schedule a notification.
  ///   - [cancel] to cancel a specific notification.
  ///   - [cancelAll] to cancel all notifications.
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // create an instance of the plugin

  static final StreamController<NotificationResponse> streamController = StreamController<NotificationResponse>();

  /// *** [2] *** init method to initialize the plugin and Time Zone
  static Future<void> init() async{
    tz.initializeTimeZones(); // It loads time zone data, but it does not automatically determine the user's current time zone.

    // create an instance of the initialization settings for both Android and iOS
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"), // Defines the initialization settings for Android,
      iOS: DarwinInitializationSettings(),
    );

    // initialize the plugin with the settings
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:  onTap, // callback function to handle the notification response when the user taps on the notification
      onDidReceiveBackgroundNotificationResponse:  onTapBack, // callback function to handle the notification response when the app is in the background
    );

    await createNotificationChannels();
  }

  static void onTap(NotificationResponse notificationResponse){
    // log('onTap');
    // log(notificationResponse.id!.toString());
    // log(notificationResponse.payload!.toString());

    // 1. Navigate to a new screen using navigatorKey (method 1)
    // navigatorKey.currentState!.push(MaterialPageRoute(builder: (_)=> TestScreen()));
    // 2. Navigate to a new screen using Stream (method 2)
    streamController.add(notificationResponse);
  }

  static void onTapBack(NotificationResponse notificationResponse){
    log('onTapBack');
    log(notificationResponse.id!.toString());
    log(notificationResponse.payload!.toString());
  }

  /// *** [3] *** display the Notification one Time
  static Future<void> showNotification() async{
    // Starting with Android 8.0, notifications are organized into channels (notification channels),
    // each with its own independent settings that the user can control.
    // - create an instance of the notification details with the settings for Android
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'id 1', // Channel ID defines a group of notifications and their settings on Android
        'channel name',
        importance: Importance.max, /// - [importance] controls the channel behavior on modern Android versions (Android 8.0+).
        priority: Priority.high, /// - [priority] determines the notification priority on older Android versions.
        sound: RawResourceAndroidNotificationSound('new_notification'),
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0, // Notification ID is a number used to identify a specific notification, allowing it to be updated or canceled.
      title: 'basic title',
      body: 'basic body',
      notificationDetails: notificationDetails,
      payload: 'payload  basic data', // Data that had been passed to the callback function when the user taps on the notification
    );
  }

  /// displaying the Repeated Notification [periodically]
  static Future<void> showRepeatedNotification() async{
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'id 2',
        'channel repeated name',
        importance: Importance.max,
        priority: Priority.high
      ),
    ); //

    await flutterLocalNotificationsPlugin.periodicallyShow(
      id: 1,
      title: 'repeated title',
      body: 'repeated body',
      notificationDetails: notificationDetails,
      payload: 'payload repeated data',
      repeatInterval: RepeatInterval.everyMinute,
      androidScheduleMode: AndroidScheduleMode.alarmClock
    );
  }

  /// displaying the Schedule Notification [zonedSchedule]
  static Future<void> showScheduleNotification() async{
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'id 3',
        'channel repeated name',
        importance: Importance.max,
        priority: Priority.high
      ),
    ); //


    final TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone(); // get the current timezone
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier)); // set local timezone to the current timezone

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 2,
      title: 'Schedule title',
      body: 'Schedule body',
      scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
      notificationDetails: notificationDetails,
      payload: 'payload Schedule data',
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  /// Cancel the old notification using its ID, and then schedule the new notification.
  Future<void> rescheduleSessionReminder({required int notificationId, required tz.TZDateTime newScheduledDate}) async {
    // Cancel the old notification
    await cancelNotification(notificationId);

    // Schedule the notification with the new time
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      title:'Live Session Reminder',
      body:'Your live session starts soon!',
      scheduledDate: newScheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'live_session_reminder',
          'Live Session Reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Starting from Android 13 (API level 33), the app requires user permission to send notifications.
  /// In flutter_local_notifications, you can request permission via the Android implementation:
  static Future<void> requestPermission() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  /// Cancel a notification using its ID.
  static Future<void> cancelNotification(int notificationId) async{
    await flutterLocalNotificationsPlugin.cancel(id: notificationId);
  }

  /// Cancel all notifications scheduled or displayed
  static Future<void> cancelAllNotifications() async{
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// [AndroidNotificationDetails]
  // use it to define notification settings and the channel on which the notification will appear.
  // specify the details for how the notification is displayed and reference the channel using its ID.
  // use it whenever a notification is displayed.

  /// create channel [AndroidNotificationChannel]
  //  use it to create and register the channel on Android.
  //  define the basic channel settings.
  //  interact with it while configuring the service.
  static Future<void> createNotificationChannels() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    const courseChannel = AndroidNotificationChannel(
      'id 1',
      'channel name',
      description: 'Notifications about courses and lessons',
      importance: Importance.high,
    );

    await androidImplementation?.createNotificationChannel(
      courseChannel,
    );
  }
}
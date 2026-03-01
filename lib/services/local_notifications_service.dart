import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:push_notifications/main.dart';
import 'package:push_notifications/notifications/push_notifications.dart';
import 'package:push_notifications/notifications/test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // create an instance of the plugin

  static final StreamController<NotificationResponse> streamController = StreamController<NotificationResponse>();

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

  // init method to initialize the plugin
  static Future<void> init() async{
    tz.initializeTimeZones(); //
    // create an instance of the initialization settings for both Android and iOS
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    );

    // initialize the plugin with the settings
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:  onTap, // callback function to handle the notification response when the user taps on the notification
      onDidReceiveBackgroundNotificationResponse:  onTapBack, // callback function to handle the notification response when the app is in the background
    );
  }

  static Future<void> showNotification() async{
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'id 1',
        'channel name',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('new_notification'),
      ),
    ); // create an instance of the notification details with the settings for Android

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: 'basic title',
      body: 'basic body',
      notificationDetails: notificationDetails,
      payload: 'payload  basic data', // data to be passed to the callback function when the user taps on the notification
    );
  }

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

  static Future<void> cancelNotification(int id) async{
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
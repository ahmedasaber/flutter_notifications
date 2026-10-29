import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Centralized service for local notifications.
///
/// Call [initialize] once during app startup, before scheduling or showing
/// notifications. Connect [notificationResponses] to your app's navigation
/// layer; avoid navigating directly from this service.
class LocalNotificationsService {
  LocalNotificationsService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<NotificationResponse> _responseController =
      StreamController<NotificationResponse>.broadcast();

  static Stream<NotificationResponse> get notificationResponses =>
      _responseController.stream;

  static bool _initialized = false;

  // Keep channel IDs stable after release: Android persists channel settings.
  static const String courseChannelId = 'course_updates';
  static const String sessionChannelId = 'live_session_reminders';
  static const String assignmentChannelId = 'assignment_deadlines';
  static const String messageChannelId = 'messages';
  static const String promotionChannelId = 'promotional_offers';

  /// Initialize plugin, local timezone, callbacks, and Android channels.
  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    // flutter_timezone provides the device's current timezone identifier.
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // Request permission deliberately, at a suitable point in the UX.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackground,
    );

    await _createAndroidChannels();
    _initialized = true;
  }

  /// Called for a notification response while the app is running.
  static void _onNotificationResponse(NotificationResponse response) {
    _responseController.add(response);
  }

  /// Background action callback must be a top-level or static entry point.
  /// Do not navigate or use UI state from this callback.
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    developer.log(
      'Background notification response: '
      'id=${response.id}, payload=${response.payload}',
      name: 'LocalNotificationsService',
    );
  }

  /// Ask for notification permission when appropriate for your app's UX.
  /// Returns Android's permission result when available.
  static Future<bool?> requestAndroidPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return android?.requestNotificationsPermission();
  }

  /// Request iOS notification permissions. Returns null if the iOS
  /// implementation is unavailable.
  static Future<bool?> requestIOSPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _createAndroidChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    const channels = <AndroidNotificationChannel>[
      AndroidNotificationChannel(
        courseChannelId,
        'Course updates',
        description: 'New courses and lessons',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        sessionChannelId,
        'Live session reminders',
        description: 'Reminders for upcoming live sessions',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        assignmentChannelId,
        'Assignment deadlines',
        description: 'Assignment and deadline reminders',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        messageChannelId,
        'Messages',
        description: 'New messages',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        promotionChannelId,
        'Promotional offers',
        description: 'Promotions and optional announcements',
        importance: Importance.low,
      ),
    ];

    for (final channel in channels) {
      await android.createNotificationChannel(channel);
    }
  }

  /// Show a notification immediately.
  ///
  /// [channelId] must match a channel created for Android. Supply a stable,
  /// unique [notificationId] when you need to update or cancel this notice.
  static Future<void> showNotification({
    required int notificationId,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    _ensureInitialized();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority: priority,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Schedule one notification for a specific local date/time.
  static Future<void> scheduleNotification({
    required int notificationId,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    required String channelName,
    String? payload,
    AndroidScheduleMode androidScheduleMode =
        AndroidScheduleMode.inexactAllowWhileIdle,
  }) async {
    _ensureInitialized();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      payload: payload,
      androidScheduleMode: androidScheduleMode,
    );
  }

  /// Cancel an existing notification and schedule it again with new details.
  static Future<void> rescheduleNotification({
    required int notificationId,
    required String title,
    required String body,
    required tz.TZDateTime newScheduledDate,
    required String channelId,
    required String channelName,
    String? payload,
  }) async {
    await cancelNotification(notificationId);
    await scheduleNotification(
      notificationId: notificationId,
      title: title,
      body: body,
      scheduledDate: newScheduledDate,
      channelId: channelId,
      channelName: channelName,
      payload: payload,
    );
  }

  /// Repeat at a fixed interval (for example, every hour).
  ///
  /// This is interval-based repetition, not a guarantee of the same wall-clock
  /// time every day. Check platform/version behavior for your chosen interval.
  static Future<void> showRepeatedNotification({
    required int notificationId,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    _ensureInitialized();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.periodicallyShow(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      repeatInterval: repeatInterval,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(id: notificationId);
  }

  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Use during app startup to detect a launch caused by tapping a notification
  /// when the app was terminated. Perform navigation after the app's navigator
  /// is ready.
  static Future<NotificationResponse?> getLaunchNotificationResponse() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details?.notificationResponse;
    }
    return null;
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'Call LocalNotificationsService.initialize() before using notifications.',
      );
    }
  }
}

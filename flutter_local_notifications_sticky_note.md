# Flutter Local Notifications --- Sticky Note

Quick reference for the `flutter_local_notifications` service. This is a
refresher, not a replacement for checking the package docs when
upgrading versions.

## 1. Install packages

``` bash
flutter pub add flutter_local_notifications
flutter pub add timezone
flutter pub add flutter_timezone
```

Then run:

``` bash
flutter pub get
```

-   `flutter_local_notifications`: displays, schedules, repeats, and
    cancels notifications.
-   `timezone`: provides `TZDateTime` and timezone database support for
    scheduled times.
-   `flutter_timezone`: reads the device's timezone identifier.

## 2. Android setup

-   Use a valid app icon, for example `@mipmap/ic_launcher`.
-   Android 13+ (API 33+) requires the `POST_NOTIFICATIONS` runtime
    permission. Ask at an appropriate moment and handle denial.
-   Create notification channels on Android 8.0+ and use the same
    channel ID when displaying notifications.
-   Exact alarms can require additional setup/permission depending on
    Android version and plugin configuration. Prefer
    `AndroidScheduleMode.inexactAllowWhileIdle` unless exact timing is
    genuinely needed.
-   If using a custom sound, add the sound file under
    `android/app/src/main/res/raw/` (for example `new_notification.mp3`)
    and reference the resource name without its extension. Verify the
    file and setup for your package version.

## 3. Initialize once at app startup

``` dart
await LocalNotificationsService.initialize();
```

Initialization should: 1. Load timezone data. 2. Set the device's local
timezone. 3. Initialize Android/iOS plugin settings and tap callbacks.
4. Register Android notification channels.

Call it before using the service. iOS permissions are separate; request
them deliberately when appropriate.

## 4. Channel vs. details

-   `AndroidNotificationChannel`: creates/registers a channel and its
    user-controlled settings on Android.
-   `AndroidNotificationDetails`: describes how an individual
    notification should be displayed and references the channel ID.
-   On Android 8+, the registered channel's settings govern behavior.
    Changing `importance` in code does not reliably change an
    already-created channel; users can also change channel settings in
    Android Settings.
-   Keep channel IDs stable after release. Use different channels only
    when notifications need separate user-facing settings.

Example channel IDs: - `course_updates` - `live_session_reminders` -
`assignment_deadlines` - `messages` - `promotional_offers`

## 5. Show immediately

``` dart
await LocalNotificationsService.showNotification(
  notificationId: 101,
  title: 'New Course',
  body: 'A new course is available!',
  channelId: LocalNotificationsService.courseChannelId,
  channelName: 'Course updates',
  payload: 'course_123',
);
```

`notificationId` is an integer used to identify/update/cancel a
notification. Use stable IDs and avoid accidental collisions across
features.

## 6. Schedule once at a date/time

``` dart
final scheduledDate = tz.TZDateTime.now(tz.local)
    .add(const Duration(minutes: 30));

await LocalNotificationsService.scheduleNotification(
  notificationId: 202,
  title: 'Live Session Reminder',
  body: 'Your session starts in 30 minutes.',
  scheduledDate: scheduledDate,
  channelId: LocalNotificationsService.sessionChannelId,
  channelName: 'Live session reminders',
  payload: 'session_456',
);
```

-   `zonedSchedule()` schedules one notification for a specific
    `TZDateTime`.
-   The service must set the correct timezone before constructing the
    date.
-   If a session time changes: cancel the old notification ID, then
    schedule the new time using that ID.

## 7. Repeating notifications

``` dart
await LocalNotificationsService.showRepeatedNotification(
  notificationId: 303,
  title: 'Study Reminder',
  body: 'Time to study!',
  channelId: LocalNotificationsService.courseChannelId,
  channelName: 'Course updates',
  repeatInterval: RepeatInterval.daily,
);
```

Use this for supported fixed intervals. Interval-based repetition is not
necessarily the same as "every day at exactly 8:00 AM." For a specific
local wall-clock time, use a suitable date/time scheduling strategy and
verify platform behavior.

## 8. Cancel

``` dart
await LocalNotificationsService.cancelNotification(202);
await LocalNotificationsService.cancelAllNotifications();
```

-   `cancelNotification(id)`: cancel the notification associated with
    that ID.
-   `cancelAllNotifications()`: cancel all notifications managed by the
    plugin.
-   Keep the same ID when replacing/rescheduling a notification.

## 9. Payload and tap handling

A `payload` is extra data attached to the notification, often a content
ID or compact route hint:

-   Course: `course_123`
-   Assignment: `assignment_456`
-   Session: `session_789`

When the user taps a notification while the app is running, the callback
receives a `NotificationResponse`; read `response.payload`,
parse/validate it, then let the navigation layer open the appropriate
screen.

Important lifecycle distinction: - `onDidReceiveNotificationResponse`:
handles a response while the app is running. -
`getNotificationAppLaunchDetails()`: check whether a notification tap
launched the app from a terminated state; navigate only after the
navigator is ready. - `onDidReceiveBackgroundNotificationResponse`:
background action callback, subject to plugin/platform requirements. It
is not a general replacement for handling a terminated-app launch.

Do not blindly trust payload contents; validate IDs and fetch current
details from your backend as needed.

## 10. Permission reminder

-   `initialize()` does not mean the user granted permission.
-   Android 13+ has a runtime notification permission.
-   iOS has its own authorization flow.
-   If permission is denied, `show()` may complete without displaying a
    visible notification; do not rely on an exception to detect denial.
-   The user may later change notification permission in system
    settings.

## 11. Common mistakes checklist

-   [ ] Forgot to call `initialize()` before scheduling/showing.
-   [ ] Used a channel ID in `AndroidNotificationDetails` that doesn't
    match the intended registered channel.
-   [ ] Expected changing channel importance in code to override an
    existing Android channel.
-   [ ] Didn't set the device timezone before creating `TZDateTime`.
-   [ ] Used a duplicate notification ID unintentionally.
-   [ ] Used exact/alarm-clock scheduling when inexact scheduling was
    enough.
-   [ ] Assumed the tap callback alone handles app launch from a
    terminated state.
-   [ ] Used null assertions (`!`) on optional payload or notification
    ID.
-   [ ] Expected a local notification to arrive from the server; local
    notifications are scheduled/displayed on-device.

## 12. Local vs Push

-   **Local notification:** app schedules or asks the device to show it.
    It does not need internet at display time.
-   **Push notification (FCM):** a server/service sends a message to the
    device through Firebase Cloud Messaging. It needs push setup and
    network/service delivery.
-   A common app flow is to receive an FCM message and use a
    local-notification plugin to display a customized notification when
    appropriate.

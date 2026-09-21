import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/review_reminder.dart';
import '../../domain/repositories/reminder_gateway.dart';

class LocalReminderGateway implements ReminderGateway {
  static const payload = 'studyflow.review_reminder';
  final FlutterLocalNotificationsPlugin plugin;
  final Future<String> Function() timezoneName;
  bool _initialized = false;

  LocalReminderGateway({
    FlutterLocalNotificationsPlugin? plugin,
    Future<String> Function()? timezoneName,
  }) : plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       timezoneName = timezoneName ?? _localTimezone;

  static Future<String> _localTimezone() async =>
      (await FlutterTimezone.getLocalTimezone()).identifier;

  @override
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _initialize() async {
    if (_initialized) return;
    final result = await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_review_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    if (result != true) throw StateError('Notification initialization failed');
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  @override
  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    await _initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()!
              .areNotificationsEnabled() ??
          false;
    }
    return (await plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()!
                .checkPermissions())
            ?.isEnabled ??
        false;
  }

  @override
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await _initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()!
              .requestNotificationsPermission() ??
          false;
    }
    return await plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()!
            .requestPermissions(alert: true, sound: true, badge: false) ??
        false;
  }

  @override
  Future<void> replaceReminders(List<ReviewReminder> reminders) async {
    if (!isSupported) return;
    await _initialize();
    // Clear only this feature's notifications, including already delivered ones.
    for (final request in await plugin.pendingNotificationRequests()) {
      if (request.payload == payload) await plugin.cancel(id: request.id);
    }
    for (final notification in await plugin.getActiveNotifications()) {
      if ((notification.payload == payload ||
              notification.channelId == 'review_reminders') &&
          notification.id != null) {
        await plugin.cancel(id: notification.id!);
      }
    }
    if (reminders.isEmpty) return;
    final location = tz.getLocation(await timezoneName());
    for (final reminder in reminders) {
      final date = reminder.date;
      final scheduled = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
        date.hour,
      );
      if (!scheduled.isAfter(tz.TZDateTime.now(location))) continue;
      await plugin.zonedSchedule(
        id: reminder.id,
        title: 'Hora de revisar',
        body:
            '${reminder.pendingCount} revisões pendentes para hoje ou atrasadas.',
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'review_reminders',
            'Revisões',
            channelDescription: 'Lembretes diários de revisões pendentes',
            icon: 'ic_review_notification',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reminders/data/gateways/local_reminder_gateway.dart';
import 'package:gestao_estudos_flutter/features/reminders/domain/entities/review_reminder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  late LocalReminderGateway gateway;
  var permission = true;
  var initialize = true;
  setUp(() {
    calls.clear();
    permission = true;
    initialize = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    FlutterLocalNotificationsPlatform.instance =
        AndroidFlutterLocalNotificationsPlugin();
    gateway = LocalReminderGateway(
      timezoneName: () async => 'America/New_York',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'initialize' => initialize,
            'areNotificationsEnabled' ||
            'requestNotificationsPermission' ||
            'requestPermissions' => permission,
            'checkPermissions' => {'isEnabled': permission},
            'pendingNotificationRequests' => [
              {'id': 1, 'payload': LocalReminderGateway.payload},
              {'id': 2, 'payload': 'another_feature'},
            ],
            'getActiveNotifications' => [
              {'id': 3, 'channelId': 'review_reminders'},
              {'id': 4, 'channelId': 'another_feature'},
            ],
            _ => null,
          };
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'limpa apenas notificações próprias e agenda no fuso IANA sem alarme exato',
    () async {
      await gateway.replaceReminders([
        ReviewReminder(date: DateTime(2030, 3, 9, 19), pendingCount: 2),
        ReviewReminder(date: DateTime(2030, 3, 10, 19), pendingCount: 3),
      ]);
      expect(
        calls.where((c) => c.method == 'cancel').map((c) => c.arguments['id']),
        [1, 3],
      );
      final scheduled = calls
          .where((c) => c.method == 'zonedSchedule')
          .toList();
      expect(scheduled.length, 2);
      for (final call in scheduled) {
        expect(call.arguments['timeZoneName'], 'America/New_York');
        expect(call.arguments['scheduledDateTime'], contains('T19:00:00'));
        expect(
          call.arguments['platformSpecifics']['scheduleMode'],
          'inexactAllowWhileIdle',
        );
        expect(call.arguments['payload'], LocalReminderGateway.payload);
      }
      expect(scheduled.first.arguments['id'], 20300309);
      expect(scheduled.last.arguments['id'], 20300310);
    },
  );
  test('desativar limpa sem consultar fuso ou reagendar', () async {
    gateway = LocalReminderGateway(
      timezoneName: () async => throw StateError('must not resolve'),
    );
    await gateway.replaceReminders([]);
    expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
    expect(calls.where((c) => c.method == 'cancel').length, 2);
  });
  test('Android consulta e pede permissão separadamente', () async {
    permission = false;
    expect(await gateway.hasPermission(), isFalse);
    expect(
      calls.where((c) => c.method == 'requestNotificationsPermission'),
      isEmpty,
    );
    expect(await gateway.requestPermission(), isFalse);
    permission = true;
    expect(await gateway.requestPermission(), isTrue);
    expect(calls.where((c) => c.method == 'initialize').length, 1);
  });
  test('iOS inicializa sem solicitar permissão automaticamente', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    FlutterLocalNotificationsPlatform.instance =
        IOSFlutterLocalNotificationsPlugin();
    expect(await gateway.hasPermission(), isTrue);
    final args = calls.first.arguments;
    expect(args['requestAlertPermission'], isFalse);
    expect(args['requestSoundPermission'], isFalse);
    expect(args['requestBadgePermission'], isFalse);
    permission = false;
    expect(await gateway.requestPermission(), isFalse);
  });
  test('não inicializa plugin em plataforma sem suporte', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(gateway.isSupported, isFalse);
    expect(await gateway.hasPermission(), isFalse);
    await gateway.replaceReminders([]);
    expect(calls, isEmpty);
  });
  test('inicialização malsucedida pode ser repetida', () async {
    initialize = false;
    await expectLater(gateway.hasPermission(), throwsStateError);
    initialize = true;
    expect(await gateway.hasPermission(), isTrue);
    expect(calls.where((c) => c.method == 'initialize').length, 2);
  });
}

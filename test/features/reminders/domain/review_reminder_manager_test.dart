import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reminders/domain/entities/reminder_status.dart';
import 'package:gestao_estudos_flutter/features/reminders/domain/services/review_reminder_manager.dart';

import '../reminder_fakes.dart';

void main() {
  late FakeReminderGateway gateway;
  late FakeReminderPreferences preferences;
  late FakeReminderReviews reviews;
  late ReviewReminderManager manager;
  final now = DateTime(2026, 9, 21, 10);
  setUp(() {
    gateway = FakeReminderGateway();
    preferences = FakeReminderPreferences();
    reviews = FakeReminderReviews()..reviews.add(pendingReview(now));
    manager = ReviewReminderManager(
      reviews: reviews,
      preferences: preferences,
      gateway: gateway,
      now: () => now,
    );
  });
  tearDown(() => manager.close());

  test(
    'inicia desativado sem pedir permissão e limpa agendamentos antigos',
    () async {
      await manager.synchronize();
      expect(gateway.requests, 0);
      expect(gateway.scheduled, isEmpty);
      expect(manager.status.outcome, ReminderOutcome.disabled);
    },
  );
  test('habilitar solicita permissão e persiste antes de agendar', () async {
    await manager.setEnabled(true);
    expect(gateway.requests, 1);
    expect(preferences.enabled, isTrue);
    expect(gateway.scheduled.length, 30);
    expect(manager.status.outcome, ReminderOutcome.active);
  });
  test('permissão negada não ativa preferência', () async {
    gateway.permitted = false;
    await manager.setEnabled(true);
    expect(preferences.enabled, isFalse);
    expect(gateway.scheduled, isEmpty);
    expect(manager.status.outcome, ReminderOutcome.denied);
  });
  test(
    'revogação externa preserva intenção e limpa lembretes sem solicitar permissão',
    () async {
      await manager.setEnabled(true);
      gateway.permitted = false;
      await manager.synchronize();
      expect(manager.status.enabled, isTrue);
      expect(manager.status.outcome, ReminderOutcome.denied);
      expect(gateway.requests, 1);
      expect(gateway.scheduled, isEmpty);
    },
  );
  test('desativar funciona mesmo sem permissão', () async {
    await manager.setEnabled(true);
    gateway.permitted = false;
    await manager.setEnabled(false);
    expect(preferences.enabled, isFalse);
    expect(gateway.scheduled, isEmpty);
    expect(manager.status.outcome, ReminderOutcome.disabled);
  });
  test(
    'plataforma não suportada não solicita permissão nem altera preferência',
    () async {
      gateway.isSupported = false;
      await manager.setEnabled(true);
      expect(gateway.requests, 0);
      expect(gateway.replacements, 0);
      expect(preferences.enabled, isFalse);
      expect(manager.status.outcome, ReminderOutcome.unsupported);
    },
  );
  test(
    'falha do plugin é reportada e permite reconciliação posterior',
    () async {
      gateway.fail = true;
      await manager.setEnabled(true);
      expect(manager.status.outcome, ReminderOutcome.failure);
      expect(manager.status.enabled, isTrue);
      gateway.fail = false;
      await manager.synchronize();
      expect(manager.status.outcome, ReminderOutcome.active);
      expect(gateway.scheduled.length, 30);
    },
  );
  test(
    'falha ao salvar preferência não mostra habilitação inexistente',
    () async {
      preferences.fail = true;
      await manager.setEnabled(true);
      expect(manager.status.enabled, isFalse);
      expect(manager.status.outcome, ReminderOutcome.failure);
      expect(gateway.scheduled, isEmpty);
    },
  );
  test(
    'fila serializada impede sincronização antiga de reativar lembretes',
    () async {
      gateway.gate = Completer<void>();
      final enabled = manager.setEnabled(true);
      await Future<void>.delayed(Duration.zero);
      final disabled = manager.setEnabled(false);
      gateway.gate!.complete();
      await Future.wait([enabled, disabled]);
      expect(gateway.scheduled, isEmpty);
      expect(manager.status.outcome, ReminderOutcome.disabled);
      expect(preferences.enabled, isFalse);
    },
  );
}

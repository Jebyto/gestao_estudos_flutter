import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reminders/domain/services/review_reminder_planner.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';

import '../reminder_fakes.dart';

void main() {
  const planner = ReviewReminderPlanner();
  final now = DateTime(2026, 12, 31, 10);

  test('sem dados ou apenas concluídas não gera lembretes', () {
    expect(planner([], now), isEmpty);
    expect(
      planner([
        Review(
          id: 'done',
          topicId: 'topic',
          scheduledFor: now,
          createdAt: now,
          reviewedAt: now,
          quality: ReviewQuality.good,
        ),
      ], now),
      isEmpty,
    );
  });

  test(
    'agrupa atrasadas e do dia e inclui futuras apenas a partir do dia agendado',
    () {
      final reminders = planner([
        pendingReview(DateTime(2026, 12, 20)),
        pendingReview(DateTime(2026, 12, 31, 23), id: 'today'),
        pendingReview(DateTime(2027, 1, 2), id: 'future'),
      ], now);
      expect(reminders.length, 30);
      expect(reminders.first.pendingCount, 2);
      expect(reminders.first.date, DateTime(2026, 12, 31, 19));
      expect(reminders[1].pendingCount, 2);
      expect(reminders[2].pendingCount, 3);
      expect(reminders.last.date, DateTime(2027, 1, 29, 19));
      expect(reminders.map((r) => r.id).toSet().length, 30);
    },
  );

  test('às 19h ou depois não agenda no passado', () {
    for (final hour in [19, 23]) {
      final reminders = planner([
        pendingReview(now),
      ], DateTime(2026, 12, 31, hour));
      expect(reminders.length, 29);
      expect(reminders.first.date, DateTime(2027, 1, 1, 19));
    }
  });

  test('revisão fora do horizonte não gera notificação antecipada', () {
    expect(planner([pendingReview(DateTime(2027, 3, 1))], now), isEmpty);
  });

  test('datas UTC são classificadas pelo dia local', () {
    final utc = DateTime.utc(2027, 1, 2, 1);
    final local = utc.toLocal();
    final reminders = planner([
      pendingReview(utc),
    ], DateTime(local.year, local.month, local.day, 9));
    expect(
      reminders.first.date,
      DateTime(local.year, local.month, local.day, 19),
    );
  });
}

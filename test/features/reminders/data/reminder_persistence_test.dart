import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/core/di/app_dependencies.dart';
import 'package:gestao_estudos_flutter/features/reminders/data/datasources/reminder_preferences_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/reminders/data/repositories/reminder_preferences_repository_impl.dart';
import 'package:gestao_estudos_flutter/features/reminders/domain/entities/reminder_status.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/entities/theme_preference.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../reminder_fakes.dart';

void main() {
  sqfliteFfiInit();
  final now = DateTime(2026, 9, 21, 10);
  late AppDependencies dependencies;
  late FakeReminderGateway gateway;

  setUp(() {
    gateway = FakeReminderGateway();
    dependencies = AppDependencies(
      appDatabase: AppDatabase(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
        singleInstance: false,
      ),
      reminderGateway: gateway,
      now: () => now,
      generateReviewId: () => 'next',
    );
  });
  tearDown(() => dependencies.close());

  Future<void> seed() async {
    await dependencies.createSubject(
      Subject(id: 'subject', name: 'Math', createdAt: now),
    );
    await dependencies.createTopic(
      Topic(
        id: 'topic',
        subjectId: 'subject',
        title: 'Algebra',
        status: TopicStatus.review,
        priority: TopicPriority.medium,
        createdAt: now,
      ),
    );
    await dependencies.reviewReminders.setEnabled(true);
    await dependencies.createReview(pendingReview(now));
  }

  test('SQLite persiste preferência sem alterar tema', () async {
    await dependencies.updateThemePreference(ThemePreference.dark);
    final repository = ReminderPreferencesRepositoryImpl(
      ReminderPreferencesLocalDataSourceImpl(dependencies.appDatabase),
    );
    expect(await repository.getEnabled(), isFalse);
    await repository.setEnabled(true);
    expect(await repository.getEnabled(), isTrue);
    await repository.setEnabled(false);
    expect(await repository.getEnabled(), isFalse);
    expect(await dependencies.getThemePreference(), ThemePreference.dark);
  });

  test('preferência sobrevive ao fechamento e reabertura do banco', () async {
    final directory = await Directory.systemTemp.createTemp(
      'studyflow-reminders-',
    );
    final path = '${directory.path}/test.db';
    final database = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: path,
    );
    final reopened = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      databasePath: path,
    );
    try {
      await ReminderPreferencesLocalDataSourceImpl(database).setEnabled(true);
      await database.close();
      expect(
        await ReminderPreferencesLocalDataSourceImpl(reopened).getEnabled(),
        isTrue,
      );
    } finally {
      await database.close();
      await reopened.close();
      await directory.delete(recursive: true);
    }
  });

  test(
    'CRUD real reconcilia criação, reagendamento, conclusão e cancelamento',
    () async {
      await seed();
      expect(gateway.scheduled.first.date, DateTime(2026, 9, 21, 19));
      await dependencies.rescheduleReview(
        reviewId: 'review',
        scheduledFor: DateTime(2026, 9, 23),
      );
      expect(gateway.scheduled.first.date, DateTime(2026, 9, 23, 19));
      await dependencies.completeReview(
        reviewId: 'review',
        quality: ReviewQuality.easy,
        reviewedAt: now,
      );
      expect(gateway.scheduled.first.date, DateTime(2026, 9, 28, 19));
      await dependencies.cancelReview('next');
      expect(gateway.scheduled, isEmpty);
      expect(
        (await dependencies.getReviewsByTopic('topic')).single.isCompleted,
        isTrue,
      );
    },
  );

  for (final parent in ['topic', 'subject']) {
    test(
      'exclusão de $parent remove lembretes das revisões em cascata',
      () async {
        await seed();
        expect(gateway.scheduled, isNotEmpty);
        if (parent == 'topic') {
          await dependencies.deleteTopic('topic');
        } else {
          await dependencies.deleteSubject('subject');
        }
        expect(gateway.scheduled, isEmpty);
        expect(await dependencies.reviewRepository.getReviews(), isEmpty);
      },
    );
  }

  test('falha nativa não desfaz revisão salva e é recuperável', () async {
    await seed();
    gateway.fail = true;
    await dependencies.cancelReview('review');
    expect(await dependencies.reviewRepository.getReviews(), isEmpty);
    expect(
      dependencies.reviewReminders.status.outcome,
      ReminderOutcome.failure,
    );
    gateway.fail = false;
    await dependencies.reviewReminders.synchronize();
    expect(gateway.scheduled, isEmpty);
    expect(dependencies.reviewReminders.status.outcome, ReminderOutcome.active);
  });
}

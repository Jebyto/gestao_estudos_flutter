import 'dart:async';

import 'package:gestao_estudos_flutter/features/reminders/domain/entities/review_reminder.dart';
import 'package:gestao_estudos_flutter/features/reminders/domain/repositories/reminder_gateway.dart';
import 'package:gestao_estudos_flutter/features/reminders/domain/repositories/reminder_preferences_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';

class FakeReminderGateway implements ReminderGateway {
  @override
  bool isSupported = true;
  bool permitted = true;
  bool fail = false;
  int requests = 0;
  int replacements = 0;
  List<ReviewReminder> scheduled = [];
  Completer<void>? gate;

  @override
  Future<bool> hasPermission() async => permitted;
  @override
  Future<bool> requestPermission() async {
    requests++;
    return permitted;
  }

  @override
  Future<void> replaceReminders(List<ReviewReminder> reminders) async {
    await gate?.future;
    if (fail) throw StateError('unavailable');
    scheduled = reminders;
    replacements++;
  }
}

class FakeReminderPreferences implements ReminderPreferencesRepository {
  bool enabled = false;
  bool fail = false;
  @override
  Future<bool> getEnabled() async => enabled;
  @override
  Future<void> setEnabled(bool value) async {
    if (fail) throw StateError('disk full');
    enabled = value;
  }
}

class FakeReminderReviews implements ReviewRepository {
  final List<Review> reviews = [];
  @override
  Future<List<Review>> getReviews() async => List.of(reviews);
  @override
  Future<void> createReview(Review review) async => reviews.add(review);
  @override
  Future<void> deleteReview(String id) async =>
      reviews.removeWhere((r) => r.id == id);
  @override
  Future<Review?> getReviewById(String id) async =>
      reviews.where((r) => r.id == id).firstOrNull;
  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async =>
      reviews.where((r) => r.topicId == topicId).toList();
  @override
  Future<void> updateReview(Review review) async {
    reviews[reviews.indexWhere((r) => r.id == review.id)] = review;
  }
}

Review pendingReview(DateTime date, {String id = 'review'}) =>
    Review(id: id, topicId: 'topic', scheduledFor: date, createdAt: date);

import 'dart:async';

import '../../../reviews/domain/repositories/review_repository.dart';
import '../entities/reminder_status.dart';
import '../repositories/reminder_gateway.dart';
import '../repositories/reminder_preferences_repository.dart';
import 'review_reminder_planner.dart';

class ReviewReminderManager {
  final ReviewRepository reviews;
  final ReminderPreferencesRepository preferences;
  final ReminderGateway gateway;
  final DateTime Function() now;
  final _changes = StreamController<ReminderStatus>.broadcast();
  Future<void>? _pending;
  ReminderStatus _status = const ReminderStatus();

  ReviewReminderManager({
    required this.reviews,
    required this.preferences,
    required this.gateway,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  ReminderStatus get status => _status;
  Stream<ReminderStatus> get changes => _changes.stream;
  bool get isSupported => gateway.isSupported;

  Future<void> synchronize() => _enqueue();
  Future<void> setEnabled(bool enabled) => _enqueue(enabled: enabled);

  // Serialize settings changes and CRUD callbacks so an old snapshot cannot win.
  Future<void> _enqueue({bool? enabled}) {
    final operation = (_pending ?? Future<void>.value()).then((_) async {
      _publish(ReminderOutcome.syncing);
      try {
        var saved = await preferences.getEnabled();
        _status = ReminderStatus(
          enabled: saved,
          outcome: ReminderOutcome.syncing,
        );
        if (!gateway.isSupported) {
          _publish(ReminderOutcome.unsupported);
          return;
        }
        if (enabled == true && !await gateway.requestPermission()) {
          await gateway.replaceReminders([]);
          _publish(ReminderOutcome.denied);
          return;
        }
        if (enabled != null) {
          await preferences.setEnabled(enabled);
          saved = enabled;
          _status = ReminderStatus(
            enabled: saved,
            outcome: ReminderOutcome.syncing,
          );
        }
        if (!saved) {
          await gateway.replaceReminders([]);
          _publish(ReminderOutcome.disabled);
          return;
        }
        if (!await gateway.hasPermission()) {
          await gateway.replaceReminders([]);
          _publish(ReminderOutcome.denied);
          return;
        }
        final reminders = const ReviewReminderPlanner()(
          await reviews.getReviews(),
          now(),
        );
        await gateway.replaceReminders(reminders);
        _publish(ReminderOutcome.active);
      } catch (_) {
        // A notification failure must not turn a committed database write into a failure.
        _publish(ReminderOutcome.failure);
      }
    });
    _pending = operation;
    return operation.whenComplete(() {
      if (identical(_pending, operation)) _pending = null;
    });
  }

  void _publish(ReminderOutcome outcome) {
    _status = ReminderStatus(enabled: _status.enabled, outcome: outcome);
    _changes.add(_status);
  }

  Future<void> close() async {
    if (_pending != null) await _pending;
    await _changes.close();
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/reminder_status.dart';
import '../../domain/services/review_reminder_manager.dart';

class RemindersCubit extends Cubit<ReminderStatus> {
  final ReviewReminderManager manager;
  late final StreamSubscription<ReminderStatus> _subscription;

  RemindersCubit(this.manager) : super(manager.status) {
    _subscription = manager.changes.listen(emit);
  }

  bool get isSupported => manager.isSupported;
  Future<void> refresh() => manager.synchronize();
  Future<void> setEnabled(bool enabled) => manager.setEnabled(enabled);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

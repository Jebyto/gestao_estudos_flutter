enum ReminderOutcome { disabled, active, denied, unsupported, failure, syncing }

class ReminderStatus {
  final bool enabled;
  final ReminderOutcome outcome;

  const ReminderStatus({
    this.enabled = false,
    this.outcome = ReminderOutcome.disabled,
  });
}

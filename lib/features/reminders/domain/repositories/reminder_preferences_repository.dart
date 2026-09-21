abstract class ReminderPreferencesRepository {
  Future<bool> getEnabled();
  Future<void> setEnabled(bool enabled);
}

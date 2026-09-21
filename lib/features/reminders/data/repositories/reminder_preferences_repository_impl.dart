import '../../domain/repositories/reminder_preferences_repository.dart';
import '../datasources/reminder_preferences_local_datasource.dart';

class ReminderPreferencesRepositoryImpl
    implements ReminderPreferencesRepository {
  final ReminderPreferencesLocalDataSource localDataSource;
  const ReminderPreferencesRepositoryImpl(this.localDataSource);

  @override
  Future<bool> getEnabled() => localDataSource.getEnabled();

  @override
  Future<void> setEnabled(bool enabled) => localDataSource.setEnabled(enabled);
}

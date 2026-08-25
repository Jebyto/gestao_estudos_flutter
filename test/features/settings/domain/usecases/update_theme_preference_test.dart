import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/entities/theme_preference.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/repositories/settings_repository.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/usecases/update_theme_preference.dart';

void main() {
  test('deve salvar a preferência de tema no repository', () async {
    final repository = FakeSettingsRepository();
    final useCase = UpdateThemePreference(repository);

    await useCase(ThemePreference.light);

    expect(repository.savedPreference, ThemePreference.light);
  });
}

class FakeSettingsRepository implements SettingsRepository {
  ThemePreference? savedPreference;

  @override
  Future<ThemePreference> getThemePreference() async {
    return ThemePreference.system;
  }

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    savedPreference = preference;
  }
}

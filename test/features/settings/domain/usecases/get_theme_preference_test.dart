import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/entities/theme_preference.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/repositories/settings_repository.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/usecases/get_theme_preference.dart';

void main() {
  test('deve retornar a preferência de tema do repository', () async {
    final repository = FakeSettingsRepository(preference: ThemePreference.dark);
    final useCase = GetThemePreference(repository);

    final result = await useCase();

    expect(result, ThemePreference.dark);
  });
}

class FakeSettingsRepository implements SettingsRepository {
  ThemePreference preference;

  FakeSettingsRepository({required this.preference});

  @override
  Future<ThemePreference> getThemePreference() async => preference;

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    this.preference = preference;
  }
}

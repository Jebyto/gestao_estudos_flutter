import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/entities/theme_preference.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/repositories/settings_repository.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/usecases/get_theme_preference.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/usecases/update_theme_preference.dart';
import 'package:gestao_estudos_flutter/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:gestao_estudos_flutter/features/settings/presentation/cubit/settings_state.dart';

void main() {
  late FakeSettingsRepository repository;
  late SettingsCubit cubit;

  setUp(() {
    repository = FakeSettingsRepository();
    cubit = SettingsCubit(
      getThemePreference: GetThemePreference(repository),
      updateThemePreferenceUseCase: UpdateThemePreference(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('deve iniciar usando o tema do sistema', () {
    expect(cubit.state.status, SettingsStatus.initial);
    expect(cubit.state.themePreference, ThemePreference.system);
  });

  test('deve carregar a preferência salva', () async {
    repository.preference = ThemePreference.dark;

    await cubit.loadSettings();

    expect(cubit.state.status, SettingsStatus.success);
    expect(cubit.state.themePreference, ThemePreference.dark);
  });

  test('deve salvar e atualizar a preferência', () async {
    await cubit.updateThemePreference(ThemePreference.light);

    expect(repository.preference, ThemePreference.light);
    expect(cubit.state.status, SettingsStatus.success);
    expect(cubit.state.themePreference, ThemePreference.light);
  });

  test('não deve salvar novamente a preferência atual', () async {
    await cubit.updateThemePreference(ThemePreference.system);

    expect(repository.saveCalls, 0);
  });
}

class FakeSettingsRepository implements SettingsRepository {
  ThemePreference preference = ThemePreference.system;
  int saveCalls = 0;

  @override
  Future<ThemePreference> getThemePreference() async => preference;

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    saveCalls++;
    this.preference = preference;
  }
}

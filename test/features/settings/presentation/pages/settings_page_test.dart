import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/entities/theme_preference.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/repositories/settings_repository.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/usecases/get_theme_preference.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/usecases/update_theme_preference.dart';
import 'package:gestao_estudos_flutter/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:gestao_estudos_flutter/features/settings/presentation/pages/settings_page.dart';

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

  testWidgets('deve exibir as opções de tema', (tester) async {
    await cubit.loadSettings();
    await tester.pumpSettingsPage(cubit);

    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Escuro'), findsOneWidget);
  });

  testWidgets('deve atualizar a preferência de tema', (tester) async {
    await cubit.loadSettings();
    await tester.pumpSettingsPage(cubit);

    await tester.tap(find.text('Escuro'));
    await tester.pump();

    expect(repository.preference, ThemePreference.dark);
    expect(cubit.state.themePreference, ThemePreference.dark);
  });
}

extension on WidgetTester {
  Future<void> pumpSettingsPage(SettingsCubit cubit) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const SettingsPage()),
      ),
    );
  }
}

class FakeSettingsRepository implements SettingsRepository {
  ThemePreference preference = ThemePreference.system;

  @override
  Future<ThemePreference> getThemePreference() async => preference;

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    this.preference = preference;
  }
}

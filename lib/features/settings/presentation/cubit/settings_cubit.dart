import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/theme_preference.dart';
import '../../domain/usecases/get_theme_preference.dart';
import '../../domain/usecases/update_theme_preference.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetThemePreference getThemePreference;
  final UpdateThemePreference updateThemePreferenceUseCase;

  SettingsCubit({
    required this.getThemePreference,
    required this.updateThemePreferenceUseCase,
  }) : super(const SettingsState());

  Future<void> loadSettings() async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));

    try {
      final preference = await getThemePreference();

      emit(
        state.copyWith(
          status: SettingsStatus.success,
          themePreference: preference,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: 'Não foi possível carregar as configurações.',
        ),
      );
    }
  }

  Future<void> updateThemePreference(ThemePreference preference) async {
    if (preference == state.themePreference) return;

    emit(state.copyWith(status: SettingsStatus.saving, errorMessage: null));

    try {
      await updateThemePreferenceUseCase(preference);

      emit(
        state.copyWith(
          status: SettingsStatus.success,
          themePreference: preference,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: 'Não foi possível salvar o tema.',
        ),
      );
    }
  }
}

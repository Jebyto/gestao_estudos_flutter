import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/settings/data/models/settings_model.dart';
import 'package:gestao_estudos_flutter/features/settings/domain/entities/theme_preference.dart';

void main() {
  test('deve converter preferência para map', () {
    const model = SettingsModel(themePreference: ThemePreference.dark);

    final map = model.toMap();

    expect(map, {'key': SettingsModel.themePreferenceKey, 'value': 'dark'});
  });

  test('deve converter map para preferência', () {
    final model = SettingsModel.fromMap({
      'key': SettingsModel.themePreferenceKey,
      'value': 'light',
    });

    expect(model.toPreference(), ThemePreference.light);
  });
}

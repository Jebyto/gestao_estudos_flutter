import '../../domain/entities/theme_preference.dart';

class SettingsModel {
  static const String themePreferenceKey = 'theme_preference';

  final ThemePreference themePreference;

  const SettingsModel({required this.themePreference});

  factory SettingsModel.fromPreference(ThemePreference preference) {
    return SettingsModel(themePreference: preference);
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      themePreference: ThemePreference.values.byName(map['value'] as String),
    );
  }

  ThemePreference toPreference() => themePreference;

  Map<String, dynamic> toMap() {
    return {'key': themePreferenceKey, 'value': themePreference.name};
  }
}

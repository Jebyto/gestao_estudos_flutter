import 'package:equatable/equatable.dart';

import '../../domain/entities/theme_preference.dart';

enum SettingsStatus { initial, loading, success, failure, saving }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final ThemePreference themePreference;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.themePreference = ThemePreference.system,
    this.errorMessage,
  });

  bool get isLoading => status == SettingsStatus.loading;

  bool get isSaving => status == SettingsStatus.saving;

  SettingsState copyWith({
    SettingsStatus? status,
    ThemePreference? themePreference,
    Object? errorMessage = _errorMessageNotProvided,
  }) {
    return SettingsState(
      status: status ?? this.status,
      themePreference: themePreference ?? this.themePreference,
      errorMessage: errorMessage == _errorMessageNotProvided
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, themePreference, errorMessage];
}

const Object _errorMessageNotProvided = Object();

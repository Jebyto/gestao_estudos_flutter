import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/theme_preference.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  final Widget? reminders;
  const SettingsPage({super.key, this.reminders});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Configurações')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text(
                  'Aparência',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text('Tema', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                SegmentedButton<ThemePreference>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ThemePreference.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('Sistema'),
                    ),
                    ButtonSegment(
                      value: ThemePreference.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Claro'),
                    ),
                    ButtonSegment(
                      value: ThemePreference.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Escuro'),
                    ),
                  ],
                  selected: {state.themePreference},
                  onSelectionChanged: state.isLoading || state.isSaving
                      ? null
                      : (selection) {
                          context.read<SettingsCubit>().updateThemePreference(
                            selection.single,
                          );
                        },
                ),
                if (state.isLoading || state.isSaving) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
                ?reminders,
              ],
            ),
          ),
        );
      },
    );
  }
}

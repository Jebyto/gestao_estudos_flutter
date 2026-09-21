import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/reminder_status.dart';
import '../cubit/reminders_cubit.dart';

class ReminderSettings extends StatelessWidget {
  const ReminderSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemindersCubit, ReminderStatus>(
      builder: (context, state) {
        final cubit = context.read<RemindersCubit>();
        final busy = state.outcome == ReminderOutcome.syncing;
        final message = !cubit.isSupported
            ? 'Disponível no Android e iOS'
            : switch (state.outcome) {
                ReminderOutcome.denied =>
                  'Permissão de notificações negada. Verifique os ajustes do sistema.',
                ReminderOutcome.failure =>
                  'Não foi possível sincronizar os lembretes.',
                ReminderOutcome.syncing => 'Sincronizando lembretes...',
                _ => '19h · horário local',
              };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Lembretes de revisão'),
              subtitle: Text(message),
              value: state.enabled,
              onChanged: busy || !cubit.isSupported ? null : cubit.setEnabled,
            ),
            if (busy) const LinearProgressIndicator(),
            if (cubit.isSupported &&
                (state.outcome == ReminderOutcome.failure ||
                    state.outcome == ReminderOutcome.denied))
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Tentar novamente',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => state.outcome == ReminderOutcome.denied
                      ? cubit.setEnabled(true)
                      : cubit.refresh(),
                ),
              ),
          ],
        );
      },
    );
  }
}

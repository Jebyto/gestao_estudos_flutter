import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/reminders_cubit.dart';

class ReminderLifecycle extends StatefulWidget {
  final Widget child;
  const ReminderLifecycle({super.key, required this.child});

  @override
  State<ReminderLifecycle> createState() => _ReminderLifecycleState();
}

class _ReminderLifecycleState extends State<ReminderLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<RemindersCubit>().refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<RemindersCubit>().refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reminders/domain/entities/reminder_status.dart';
import 'package:gestao_estudos_flutter/features/reminders/domain/services/review_reminder_manager.dart';
import 'package:gestao_estudos_flutter/features/reminders/presentation/cubit/reminders_cubit.dart';
import 'package:gestao_estudos_flutter/features/reminders/presentation/widgets/reminder_lifecycle.dart';
import 'package:gestao_estudos_flutter/features/reminders/presentation/widgets/reminder_settings.dart';

import '../reminder_fakes.dart';

void main() {
  late ReviewReminderManager manager;
  late RemindersCubit cubit;
  late FakeReminderGateway gateway;
  late FakeReminderPreferences preferences;
  Future<void> initialize() async {
    gateway = FakeReminderGateway();
    preferences = FakeReminderPreferences();
    manager = ReviewReminderManager(
      reviews: FakeReminderReviews(),
      preferences: preferences,
      gateway: gateway,
    );
    await manager.synchronize();
    cubit = RemindersCubit(manager);
  }

  void testReminderWidgets(
    String name,
    Future<void> Function(WidgetTester) body,
  ) {
    testWidgets(name, (tester) async {
      await initialize();
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(() async {
          await cubit.close();
          await manager.close();
        });
      }
    });
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          home: Scaffold(
            body: ReminderLifecycle(
              child: SingleChildScrollView(child: ReminderSettings()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test(
    'Cubit recebe sincronização externa e libera inscrição ao fechar',
    () async {
      await initialize();
      addTearDown(() async {
        await cubit.close();
        await manager.close();
      });
      await manager.setEnabled(true);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.enabled, isTrue);
      expect(cubit.state.outcome, ReminderOutcome.active);
    },
  );

  testReminderWidgets('ativa e desativa lembretes pelo controle', (
    tester,
  ) async {
    await pump(tester);
    expect(gateway.requests, 0);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(preferences.enabled, isTrue);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(preferences.enabled, isFalse);
  });

  testReminderWidgets(
    'permissão negada mostra erro e permite tentar novamente',
    (tester) async {
      await pump(tester);
      gateway.permitted = false;
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Permissão de notificações negada'),
        findsOneWidget,
      );
      expect(preferences.enabled, isFalse);
      gateway.permitted = true;
      await tester.tap(find.byTooltip('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(preferences.enabled, isTrue);
      expect(
        find.textContaining('Permissão de notificações negada'),
        findsNothing,
      );
    },
  );

  testReminderWidgets(
    'falha nativa mantém preferência e oferece nova sincronização',
    (tester) async {
      await pump(tester);
      gateway.fail = true;
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(
        find.text('Não foi possível sincronizar os lembretes.'),
        findsOneWidget,
      );
      expect(preferences.enabled, isTrue);
      gateway.fail = false;
      await tester.tap(find.byTooltip('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(cubit.state.outcome, ReminderOutcome.active);
    },
  );

  testReminderWidgets('desabilita controle em plataforma não suportada', (
    tester,
  ) async {
    await pump(tester);
    gateway.isSupported = false;
    await cubit.refresh();
    await tester.pumpAndSettle();
    expect(find.text('Disponível no Android e iOS'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
      isNull,
    );
    expect(gateway.requests, 0);
  });

  testReminderWidgets('bloqueia o controle enquanto sincroniza', (
    tester,
  ) async {
    await pump(tester);
    gateway.gate = Completer<void>();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
      isNull,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    gateway.gate!.complete();
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
      isNotNull,
    );
  });

  testReminderWidgets('retomar app revalida permissão sem nova solicitação', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    gateway.permitted = false;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(cubit.state.outcome, ReminderOutcome.denied);
    expect(gateway.requests, 1);
  });

  testReminderWidgets(
    'controle permanece legível em tela estreita com texto ampliado',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(tester);
      gateway.permitted = false;
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

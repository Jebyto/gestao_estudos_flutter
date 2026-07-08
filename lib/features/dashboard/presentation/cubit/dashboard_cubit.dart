import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dashboard_summary.dart';
import 'dashboard_state.dart';

typedef DashboardSummaryLoader = Future<DashboardSummary> Function();

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardSummaryLoader getDashboardSummary;

  DashboardCubit({required this.getDashboardSummary})
    : super(const DashboardState());

  Future<void> loadSummary() async {
    emit(state.copyWith(status: DashboardStatus.loading, errorMessage: null));

    try {
      final summary = await getDashboardSummary();

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          summary: summary,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Não foi possível carregar o dashboard.',
        ),
      );
    }
  }
}

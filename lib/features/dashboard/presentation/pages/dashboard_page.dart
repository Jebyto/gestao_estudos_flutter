import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/dashboard_formatters.dart';
import '../widgets/dashboard_metric_card.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback onOpenSubjects;

  const DashboardPage({super.key, required this.onOpenSubjects});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
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
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                tooltip: 'Matérias',
                onPressed: onOpenSubjects,
                icon: const Icon(Icons.menu_book_outlined),
              ),
              IconButton(
                tooltip: 'Atualizar dashboard',
                onPressed: state.isLoading
                    ? null
                    : () => context.read<DashboardCubit>().loadSummary(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(child: _DashboardBody(state: state)),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardState state;

  const _DashboardBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;

    if (state.isLoading && summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (summary == null) {
      return const _EmptyDashboardView();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().loadSummary(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _ProgressSection(summary: summary),
          const SizedBox(height: 16),
          _MetricsGrid(summary: summary),
          const SizedBox(height: 16),
          _StudySection(summary: summary),
          const SizedBox(height: 16),
          _ReviewsSection(summary: summary),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final DashboardSummary summary;

  const _ProgressSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso geral',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: summary.totalTopics == 0
                  ? 0
                  : summary.progressPercentage / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(
              formatDashboardPercentage(summary.progressPercentage),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final DashboardSummary summary;

  const _MetricsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      DashboardMetricCard(
        icon: Icons.menu_book_outlined,
        label: 'Matérias',
        value: summary.totalSubjects.toString(),
      ),
      DashboardMetricCard(
        icon: Icons.topic_outlined,
        label: 'Tópicos',
        value: summary.totalTopics.toString(),
      ),
      DashboardMetricCard(
        icon: Icons.check_circle_outline,
        label: 'Concluídos',
        value: summary.completedTopics.toString(),
      ),
      DashboardMetricCard(
        icon: Icons.hourglass_bottom_outlined,
        label: 'Em andamento',
        value: summary.studyingTopics.toString(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.05,
          children: metrics,
        );
      },
    );
  }
}

class _StudySection extends StatelessWidget {
  final DashboardSummary summary;

  const _StudySection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estudo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DashboardMetricCard(
          icon: Icons.today_outlined,
          label: 'Hoje',
          value: formatDashboardMinutes(summary.totalStudyMinutesToday),
        ),
        const SizedBox(height: 8),
        DashboardMetricCard(
          icon: Icons.calendar_view_week_outlined,
          label: 'Nesta semana',
          value: formatDashboardMinutes(summary.totalStudyMinutesThisWeek),
        ),
        const SizedBox(height: 8),
        DashboardMetricCard(
          icon: Icons.trending_up_outlined,
          label: summary.mostStudiedSubjectName ?? 'Mais estudada',
          value: formatDashboardMinutes(summary.mostStudiedSubjectMinutes),
        ),
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final DashboardSummary summary;

  const _ReviewsSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final nextReviewTitle = summary.nextReviewTopicTitle;
    final nextReviewSubject = summary.nextReviewSubjectName;
    final nextReviewDate = summary.nextReviewScheduledFor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Revisões', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DashboardMetricCard(
          icon: Icons.fact_check_outlined,
          label: 'Para hoje',
          value: summary.reviewsDueToday.toString(),
        ),
        const SizedBox(height: 8),
        DashboardMetricCard(
          icon: Icons.warning_amber_outlined,
          label: 'Atrasadas',
          value: summary.overdueReviews.toString(),
        ),
        const SizedBox(height: 8),
        DashboardMetricCard(
          icon: Icons.done_all_outlined,
          label: 'Concluídas na semana',
          value: summary.completedReviewsThisWeek.toString(),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próxima revisão',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  nextReviewTitle ?? 'Nenhuma revisão pendente',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (nextReviewSubject != null) ...[
                  const SizedBox(height: 4),
                  Text(nextReviewSubject),
                ],
                if (nextReviewDate != null) ...[
                  const SizedBox(height: 4),
                  Text(formatDashboardDate(nextReviewDate)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyDashboardView extends StatelessWidget {
  const _EmptyDashboardView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Dashboard indisponível'),
      ),
    );
  }
}

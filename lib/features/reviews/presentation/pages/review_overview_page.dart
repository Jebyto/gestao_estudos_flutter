import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/review_overview.dart';
import '../cubit/review_overview_cubit.dart';
import '../cubit/review_overview_state.dart';
import '../widgets/review_card.dart';
import '../widgets/review_history_card.dart';

class ReviewOverviewPage extends StatelessWidget {
  const ReviewOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewOverviewCubit, ReviewOverviewState>(
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
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Revisões'),
              actions: [
                IconButton(
                  tooltip: 'Atualizar revisões',
                  onPressed: state.isLoading
                      ? null
                      : () =>
                            context.read<ReviewOverviewCubit>().loadOverview(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Pendentes'),
                  Tab(text: 'Histórico'),
                ],
              ),
            ),
            body: SafeArea(
              child: TabBarView(
                children: [
                  _PendingReviewsView(state: state),
                  _CompletedReviewsView(state: state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PendingReviewsView extends StatelessWidget {
  final ReviewOverviewState state;

  const _PendingReviewsView({required this.state});

  @override
  Widget build(BuildContext context) {
    final pendingReviews = state.overview?.pendingReviews;

    if (state.isLoading && pendingReviews == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pendingReviews == null || pendingReviews.isEmpty) {
      return const _EmptyOverviewView(
        icon: Icons.fact_check_outlined,
        title: 'Nenhuma revisão pendente',
        message: 'As próximas revisões aparecerão aqui.',
      );
    }

    return _ReviewOverviewList(
      items: pendingReviews,
      onRefresh: () => context.read<ReviewOverviewCubit>().loadOverview(),
      itemBuilder: (item) {
        return ReviewCard(
          review: item.review,
          topic: item.topic,
          subjectName: item.subject.name,
          onComplete: (quality) => context
              .read<ReviewOverviewCubit>()
              .completeReview(reviewId: item.review.id, quality: quality),
        );
      },
    );
  }
}

class _CompletedReviewsView extends StatelessWidget {
  final ReviewOverviewState state;

  const _CompletedReviewsView({required this.state});

  @override
  Widget build(BuildContext context) {
    final completedReviews = state.overview?.completedReviews;

    if (state.isLoading && completedReviews == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (completedReviews == null || completedReviews.isEmpty) {
      return const _EmptyOverviewView(
        icon: Icons.history_outlined,
        title: 'Nenhuma revisão concluída',
        message: 'O histórico geral de revisões aparecerá aqui.',
      );
    }

    return _ReviewOverviewList(
      items: completedReviews,
      onRefresh: () => context.read<ReviewOverviewCubit>().loadOverview(),
      itemBuilder: (item) {
        return ReviewHistoryCard(
          review: item.review,
          topic: item.topic,
          subjectName: item.subject.name,
        );
      },
    );
  }
}

class _ReviewOverviewList extends StatelessWidget {
  final List<ReviewOverviewItem> items;
  final RefreshCallback onRefresh;
  final Widget Function(ReviewOverviewItem item) itemBuilder;

  const _ReviewOverviewList({
    required this.items,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => itemBuilder(items[index]),
      ),
    );
  }
}

class _EmptyOverviewView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyOverviewView({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

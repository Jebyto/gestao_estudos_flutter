import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../subjects/domain/entities/subject.dart';
import '../../../topics/domain/entities/topic.dart';
import '../../domain/entities/review.dart';
import '../cubit/reviews_cubit.dart';
import '../cubit/reviews_state.dart';
import '../widgets/review_card.dart';
import 'review_form_page.dart';

class ReviewsPage extends StatelessWidget {
  final Subject subject;
  final List<Topic> topics;

  const ReviewsPage({super.key, required this.subject, required this.topics});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsCubit, ReviewsState>(
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
            title: Text('Revisões - ${subject.name}'),
            actions: [
              IconButton(
                tooltip: 'Atualizar revisões',
                onPressed: state.isLoading
                    ? null
                    : () => context.read<ReviewsCubit>().loadPendingReviews(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: _ReviewsBody(state: state, topics: topics),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Adicionar revisão',
            onPressed: topics.isEmpty ? null : () => _openForm(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context) {
    final cubit = context.read<ReviewsCubit>();

    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ReviewFormPage(topics: topics),
        ),
      ),
    );
  }
}

class _ReviewsBody extends StatelessWidget {
  final ReviewsState state;
  final List<Topic> topics;

  const _ReviewsBody({required this.state, required this.topics});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.pendingReviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.pendingReviews.isEmpty) {
      return const _EmptyReviewsView();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ReviewsCubit>().loadPendingReviews(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: state.pendingReviews.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final review = state.pendingReviews[index];

          return ReviewCard(
            review: review,
            topic: _topicForReview(review),
            onComplete: (quality) => context
                .read<ReviewsCubit>()
                .completeReview(reviewId: review.id, quality: quality),
          );
        },
      ),
    );
  }

  Topic? _topicForReview(Review review) {
    for (final topic in topics) {
      if (topic.id == review.topicId) return topic;
    }

    return null;
  }
}

class _EmptyReviewsView extends StatelessWidget {
  const _EmptyReviewsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fact_check_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma revisão pendente',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Crie revisões para manter os tópicos ativos na memória.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

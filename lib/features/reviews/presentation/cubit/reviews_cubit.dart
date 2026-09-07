import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/review.dart';
import '../../domain/errors/review_exceptions.dart';
import '../../domain/usecases/cancel_review.dart';
import '../../domain/usecases/complete_review.dart';
import '../../domain/usecases/create_review.dart';
import '../../domain/usecases/get_reviews_by_topic.dart';
import '../../domain/usecases/reschedule_review.dart';
import 'reviews_state.dart';

typedef ReviewPresentationIdGenerator = String Function();
typedef ReviewDateTimeProvider = DateTime Function();

class ReviewsCubit extends Cubit<ReviewsState> {
  final List<String> topicIds;
  final GetReviewsByTopic getReviewsByTopic;
  final CreateReview createReviewUseCase;
  final CompleteReview completeReviewUseCase;
  final CancelReview cancelReviewUseCase;
  final RescheduleReview rescheduleReviewUseCase;
  final ReviewPresentationIdGenerator generateReviewId;
  final ReviewDateTimeProvider now;

  ReviewsCubit({
    required this.topicIds,
    required this.getReviewsByTopic,
    required this.createReviewUseCase,
    required this.completeReviewUseCase,
    required this.cancelReviewUseCase,
    required this.rescheduleReviewUseCase,
    ReviewPresentationIdGenerator? generateReviewId,
    ReviewDateTimeProvider? now,
  }) : generateReviewId = generateReviewId ?? _defaultGenerateReviewId,
       now = now ?? DateTime.now,
       super(const ReviewsState());

  Future<void> cancelReview(String reviewId) async {
    if (state.isSubmitting || state.isLoading) return;
    emit(state.copyWith(status: ReviewsStatus.submitting, errorMessage: null));
    try {
      await cancelReviewUseCase(reviewId);
      await _loadReviews();
    } catch (_) {
      emit(
        state.copyWith(
          status: ReviewsStatus.failure,
          errorMessage: 'Não foi possível cancelar a revisão.',
        ),
      );
    }
  }

  Future<void> rescheduleReview(String reviewId, DateTime date) async {
    if (state.isSubmitting || state.isLoading) return;
    emit(state.copyWith(status: ReviewsStatus.submitting, errorMessage: null));
    try {
      await rescheduleReviewUseCase(reviewId: reviewId, scheduledFor: date);
      await _loadReviews();
    } catch (error) {
      emit(
        state.copyWith(
          status: ReviewsStatus.failure,
          errorMessage: error is InvalidReviewScheduleException
              ? 'Escolha hoje ou uma data futura.'
              : 'Não foi possível reagendar a revisão.',
        ),
      );
    }
  }

  Future<void> loadReviews() async {
    if (state.isSubmitting || state.isLoading) return;
    await _loadReviews();
  }

  Future<void> _loadReviews() async {
    emit(state.copyWith(status: ReviewsStatus.loading, errorMessage: null));

    try {
      final reviews = <Review>[];
      for (final topicId in topicIds.toSet()) {
        reviews.addAll(await getReviewsByTopic(topicId));
      }
      final pendingReviews =
          reviews.where((review) => review.isPending).toList()
            ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
      final completedReviews =
          reviews.where((review) => review.isCompleted).toList()
            ..sort((a, b) => b.reviewedAt!.compareTo(a.reviewedAt!));

      emit(
        state.copyWith(
          status: ReviewsStatus.success,
          pendingReviews: pendingReviews,
          completedReviews: completedReviews,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ReviewsStatus.failure,
          errorMessage: 'Não foi possível carregar as revisões.',
        ),
      );
    }
  }

  Future<bool> createReview({required String topicId}) async {
    if (state.isSubmitting || state.isLoading) return false;
    final trimmedTopicId = topicId.trim();

    if (trimmedTopicId.isEmpty) {
      emit(
        state.copyWith(
          status: ReviewsStatus.failure,
          errorMessage: 'Selecione um tópico para revisar.',
        ),
      );
      return false;
    }

    emit(state.copyWith(status: ReviewsStatus.submitting, errorMessage: null));

    try {
      final currentDate = now();

      await createReviewUseCase(
        Review(
          id: generateReviewId(),
          topicId: trimmedTopicId,
          scheduledFor: currentDate,
          createdAt: currentDate,
        ),
      );
      await _loadReviews();

      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: ReviewsStatus.failure,
          errorMessage: 'Não foi possível criar a revisão.',
        ),
      );
      return false;
    }
  }

  Future<void> completeReview({
    required String reviewId,
    required ReviewQuality quality,
  }) async {
    if (state.isSubmitting || state.isLoading) return;
    emit(state.copyWith(status: ReviewsStatus.submitting, errorMessage: null));

    try {
      await completeReviewUseCase(
        reviewId: reviewId,
        quality: quality,
        reviewedAt: now(),
      );
      await _loadReviews();
    } catch (_) {
      emit(
        state.copyWith(
          status: ReviewsStatus.failure,
          errorMessage: 'Não foi possível concluir a revisão.',
        ),
      );
    }
  }
}

String _defaultGenerateReviewId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}

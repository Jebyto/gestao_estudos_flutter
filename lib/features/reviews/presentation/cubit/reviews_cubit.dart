import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/review.dart';
import '../../domain/usecases/complete_review.dart';
import '../../domain/usecases/create_review.dart';
import '../../domain/usecases/get_pending_reviews.dart';
import 'reviews_state.dart';

typedef ReviewPresentationIdGenerator = String Function();
typedef ReviewDateTimeProvider = DateTime Function();

class ReviewsCubit extends Cubit<ReviewsState> {
  final List<String> topicIds;
  final GetPendingReviews getPendingReviews;
  final CreateReview createReviewUseCase;
  final CompleteReview completeReviewUseCase;
  final ReviewPresentationIdGenerator generateReviewId;
  final ReviewDateTimeProvider now;

  ReviewsCubit({
    required this.topicIds,
    required this.getPendingReviews,
    required this.createReviewUseCase,
    required this.completeReviewUseCase,
    ReviewPresentationIdGenerator? generateReviewId,
    ReviewDateTimeProvider? now,
  }) : generateReviewId = generateReviewId ?? _defaultGenerateReviewId,
       now = now ?? DateTime.now,
       super(const ReviewsState());

  Future<void> loadPendingReviews() async {
    emit(state.copyWith(status: ReviewsStatus.loading, errorMessage: null));

    try {
      final referenceDate = _endOfDay(now());
      final pendingReviews = await getPendingReviews(referenceDate);
      final topicIdsSet = topicIds.toSet();
      final filteredReviews =
          pendingReviews
              .where((review) => topicIdsSet.contains(review.topicId))
              .toList()
            ..sort((first, second) {
              return first.scheduledFor.compareTo(second.scheduledFor);
            });

      emit(
        state.copyWith(
          status: ReviewsStatus.success,
          pendingReviews: filteredReviews,
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
      await loadPendingReviews();

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
    emit(state.copyWith(status: ReviewsStatus.submitting, errorMessage: null));

    try {
      await completeReviewUseCase(
        reviewId: reviewId,
        quality: quality,
        reviewedAt: now(),
      );
      await loadPendingReviews();
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

DateTime _endOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}

String _defaultGenerateReviewId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}

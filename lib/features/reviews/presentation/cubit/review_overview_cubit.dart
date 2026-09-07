import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/review.dart';
import '../../domain/errors/review_exceptions.dart';
import '../../domain/usecases/cancel_review.dart';
import '../../domain/usecases/complete_review.dart';
import '../../domain/usecases/get_review_overview.dart';
import '../../domain/usecases/reschedule_review.dart';
import 'review_overview_state.dart';

typedef ReviewOverviewDateTimeProvider = DateTime Function();

class ReviewOverviewCubit extends Cubit<ReviewOverviewState> {
  final GetReviewOverview getReviewOverview;
  final CompleteReview completeReviewUseCase;
  final CancelReview cancelReviewUseCase;
  final RescheduleReview rescheduleReviewUseCase;
  final ReviewOverviewDateTimeProvider now;

  ReviewOverviewCubit({
    required this.getReviewOverview,
    required this.completeReviewUseCase,
    required this.cancelReviewUseCase,
    required this.rescheduleReviewUseCase,
    ReviewOverviewDateTimeProvider? now,
  }) : now = now ?? DateTime.now,
       super(const ReviewOverviewState());

  Future<void> cancelReview(String reviewId) async {
    if (state.isSubmitting || state.isLoading) return;
    emit(
      state.copyWith(
        status: ReviewOverviewStatus.submitting,
        errorMessage: null,
      ),
    );
    try {
      await cancelReviewUseCase(reviewId);
      await _loadOverview();
    } catch (_) {
      emit(
        state.copyWith(
          status: ReviewOverviewStatus.failure,
          errorMessage: 'Não foi possível cancelar a revisão.',
        ),
      );
    }
  }

  Future<void> rescheduleReview(String reviewId, DateTime date) async {
    if (state.isSubmitting || state.isLoading) return;
    emit(
      state.copyWith(
        status: ReviewOverviewStatus.submitting,
        errorMessage: null,
      ),
    );
    try {
      await rescheduleReviewUseCase(reviewId: reviewId, scheduledFor: date);
      await _loadOverview();
    } catch (error) {
      emit(
        state.copyWith(
          status: ReviewOverviewStatus.failure,
          errorMessage: error is InvalidReviewScheduleException
              ? 'Escolha hoje ou uma data futura.'
              : 'Não foi possível reagendar a revisão.',
        ),
      );
    }
  }

  Future<void> loadOverview() async {
    if (state.isSubmitting || state.isLoading) return;
    await _loadOverview();
  }

  Future<void> _loadOverview() async {
    emit(
      state.copyWith(status: ReviewOverviewStatus.loading, errorMessage: null),
    );

    try {
      final overview = await getReviewOverview();

      emit(
        state.copyWith(
          status: ReviewOverviewStatus.success,
          overview: overview,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ReviewOverviewStatus.failure,
          errorMessage: 'Não foi possível carregar as revisões.',
        ),
      );
    }
  }

  Future<void> completeReview({
    required String reviewId,
    required ReviewQuality quality,
  }) async {
    if (state.isSubmitting || state.isLoading) return;
    emit(
      state.copyWith(
        status: ReviewOverviewStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      await completeReviewUseCase(
        reviewId: reviewId,
        quality: quality,
        reviewedAt: now(),
      );
      await _loadOverview();
    } catch (_) {
      emit(
        state.copyWith(
          status: ReviewOverviewStatus.failure,
          errorMessage: 'Não foi possível concluir a revisão.',
        ),
      );
    }
  }
}

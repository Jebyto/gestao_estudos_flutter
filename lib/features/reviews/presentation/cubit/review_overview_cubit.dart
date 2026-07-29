import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/review.dart';
import '../../domain/usecases/complete_review.dart';
import '../../domain/usecases/get_review_overview.dart';
import 'review_overview_state.dart';

typedef ReviewOverviewDateTimeProvider = DateTime Function();

class ReviewOverviewCubit extends Cubit<ReviewOverviewState> {
  final GetReviewOverview getReviewOverview;
  final CompleteReview completeReviewUseCase;
  final ReviewOverviewDateTimeProvider now;

  ReviewOverviewCubit({
    required this.getReviewOverview,
    required this.completeReviewUseCase,
    ReviewOverviewDateTimeProvider? now,
  }) : now = now ?? DateTime.now,
       super(const ReviewOverviewState());

  Future<void> loadOverview() async {
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
      await loadOverview();
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

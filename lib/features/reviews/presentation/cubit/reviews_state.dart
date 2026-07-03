import 'package:equatable/equatable.dart';

import '../../domain/entities/review.dart';

enum ReviewsStatus { initial, loading, success, failure, submitting }

class ReviewsState extends Equatable {
  final ReviewsStatus status;
  final List<Review> pendingReviews;
  final String? errorMessage;

  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.pendingReviews = const [],
    this.errorMessage,
  });

  bool get isLoading => status == ReviewsStatus.loading;

  bool get isSubmitting => status == ReviewsStatus.submitting;

  ReviewsState copyWith({
    ReviewsStatus? status,
    List<Review>? pendingReviews,
    Object? errorMessage = _errorMessageNotProvided,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      pendingReviews: pendingReviews ?? this.pendingReviews,
      errorMessage: errorMessage == _errorMessageNotProvided
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, pendingReviews, errorMessage];
}

const Object _errorMessageNotProvided = Object();

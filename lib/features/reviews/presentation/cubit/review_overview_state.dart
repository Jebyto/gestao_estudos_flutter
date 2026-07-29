import 'package:equatable/equatable.dart';

import '../../domain/entities/review_overview.dart';

enum ReviewOverviewStatus { initial, loading, success, failure, submitting }

class ReviewOverviewState extends Equatable {
  final ReviewOverviewStatus status;
  final ReviewOverview? overview;
  final String? errorMessage;

  const ReviewOverviewState({
    this.status = ReviewOverviewStatus.initial,
    this.overview,
    this.errorMessage,
  });

  bool get isLoading => status == ReviewOverviewStatus.loading;

  bool get isSubmitting => status == ReviewOverviewStatus.submitting;

  ReviewOverviewState copyWith({
    ReviewOverviewStatus? status,
    ReviewOverview? overview,
    Object? errorMessage = _errorMessageNotProvided,
  }) {
    return ReviewOverviewState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      errorMessage: errorMessage == _errorMessageNotProvided
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, overview, errorMessage];
}

const Object _errorMessageNotProvided = Object();

import 'package:equatable/equatable.dart';

import '../../domain/entities/topic.dart';

enum TopicsStatus { initial, loading, success, failure, submitting }

class TopicsState extends Equatable {
  final TopicsStatus status;
  final List<Topic> topics;
  final String? errorMessage;

  const TopicsState({
    this.status = TopicsStatus.initial,
    this.topics = const [],
    this.errorMessage,
  });

  bool get isLoading => status == TopicsStatus.loading;

  bool get isSubmitting => status == TopicsStatus.submitting;

  TopicsState copyWith({
    TopicsStatus? status,
    List<Topic>? topics,
    Object? errorMessage = _errorMessageNotProvided,
  }) {
    return TopicsState(
      status: status ?? this.status,
      topics: topics ?? this.topics,
      errorMessage: errorMessage == _errorMessageNotProvided
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, topics, errorMessage];
}

const Object _errorMessageNotProvided = Object();

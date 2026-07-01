import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/topic.dart';
import '../../domain/usecases/create_topic.dart';
import '../../domain/usecases/delete_topic.dart';
import '../../domain/usecases/get_topics_by_subject.dart';
import '../../domain/usecases/update_topic_status.dart';
import 'topics_state.dart';

typedef TopicIdGenerator = String Function();
typedef TopicDateTimeProvider = DateTime Function();

class TopicsCubit extends Cubit<TopicsState> {
  final String subjectId;
  final GetTopicsBySubject getTopicsBySubject;
  final CreateTopic createTopicUseCase;
  final UpdateTopicStatus updateTopicStatusUseCase;
  final DeleteTopic deleteTopicUseCase;
  final TopicIdGenerator generateTopicId;
  final TopicDateTimeProvider now;

  TopicsCubit({
    required this.subjectId,
    required this.getTopicsBySubject,
    required this.createTopicUseCase,
    required this.updateTopicStatusUseCase,
    required this.deleteTopicUseCase,
    TopicIdGenerator? generateTopicId,
    TopicDateTimeProvider? now,
  }) : generateTopicId = generateTopicId ?? _defaultGenerateTopicId,
       now = now ?? DateTime.now,
       super(const TopicsState());

  Future<void> loadTopics() async {
    emit(state.copyWith(status: TopicsStatus.loading, errorMessage: null));

    try {
      final topics = await getTopicsBySubject(subjectId);

      emit(
        state.copyWith(
          status: TopicsStatus.success,
          topics: topics,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TopicsStatus.failure,
          errorMessage: 'Não foi possível carregar os tópicos.',
        ),
      );
    }
  }

  Future<bool> createTopic({
    required String title,
    String? description,
    TopicPriority priority = TopicPriority.medium,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedDescription = description?.trim();

    if (trimmedTitle.isEmpty) {
      emit(
        state.copyWith(
          status: TopicsStatus.failure,
          errorMessage: 'Informe o título do tópico.',
        ),
      );
      return false;
    }

    emit(state.copyWith(status: TopicsStatus.submitting, errorMessage: null));

    try {
      await createTopicUseCase(
        Topic(
          id: generateTopicId(),
          subjectId: subjectId,
          title: trimmedTitle,
          description: trimmedDescription == null || trimmedDescription.isEmpty
              ? null
              : trimmedDescription,
          status: TopicStatus.notStarted,
          priority: priority,
          createdAt: now(),
        ),
      );
      await loadTopics();

      return true;
    } catch (_) {
      emit(
        state.copyWith(
          status: TopicsStatus.failure,
          errorMessage: 'Não foi possível salvar o tópico.',
        ),
      );
      return false;
    }
  }

  Future<void> updateStatus({
    required String topicId,
    required TopicStatus status,
  }) async {
    emit(state.copyWith(status: TopicsStatus.submitting, errorMessage: null));

    try {
      await updateTopicStatusUseCase(topicId, status);
      await loadTopics();
    } catch (_) {
      emit(
        state.copyWith(
          status: TopicsStatus.failure,
          errorMessage: 'Não foi possível atualizar o tópico.',
        ),
      );
    }
  }

  Future<void> deleteTopic(String id) async {
    emit(state.copyWith(status: TopicsStatus.submitting, errorMessage: null));

    try {
      await deleteTopicUseCase(id);
      await loadTopics();
    } catch (_) {
      emit(
        state.copyWith(
          status: TopicsStatus.failure,
          errorMessage: 'Não foi possível excluir o tópico.',
        ),
      );
    }
  }
}

String _defaultGenerateTopicId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}

import '../../domain/entities/topic.dart';

String topicStatusLabel(TopicStatus status) {
  return switch (status) {
    TopicStatus.notStarted => 'Não iniciado',
    TopicStatus.studying => 'Estudando',
    TopicStatus.review => 'Revisão',
    TopicStatus.completed => 'Concluído',
  };
}

String topicPriorityLabel(TopicPriority priority) {
  return switch (priority) {
    TopicPriority.low => 'Baixa',
    TopicPriority.medium => 'Média',
    TopicPriority.high => 'Alta',
  };
}

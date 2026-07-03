import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../subjects/domain/entities/subject.dart';
import '../../domain/entities/topic.dart';
import '../cubit/topics_cubit.dart';
import '../cubit/topics_state.dart';
import '../widgets/topic_card.dart';
import 'topic_form_page.dart';

typedef StudySessionsSelectedCallback =
    void Function(BuildContext context, Subject subject, List<Topic> topics);

typedef ReviewsSelectedCallback =
    void Function(BuildContext context, Subject subject, List<Topic> topics);

class TopicsPage extends StatelessWidget {
  final Subject subject;
  final StudySessionsSelectedCallback? onStudySessionsSelected;
  final ReviewsSelectedCallback? onReviewsSelected;

  const TopicsPage({
    super.key,
    required this.subject,
    this.onStudySessionsSelected,
    this.onReviewsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TopicsCubit, TopicsState>(
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
            title: Text(subject.name),
            actions: [
              if (onReviewsSelected != null)
                IconButton(
                  tooltip: 'Revisões',
                  onPressed: () => onReviewsSelected!(
                    context,
                    subject,
                    context.read<TopicsCubit>().state.topics,
                  ),
                  icon: const Icon(Icons.fact_check_outlined),
                ),
              if (onStudySessionsSelected != null)
                IconButton(
                  tooltip: 'Sessões de estudo',
                  onPressed: () => onStudySessionsSelected!(
                    context,
                    subject,
                    context.read<TopicsCubit>().state.topics,
                  ),
                  icon: const Icon(Icons.timer_outlined),
                ),
              IconButton(
                tooltip: 'Atualizar tópicos',
                onPressed: state.isLoading
                    ? null
                    : () => context.read<TopicsCubit>().loadTopics(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(child: _TopicsBody(state: state)),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Adicionar tópico',
            onPressed: () => _openForm(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context) {
    final cubit = context.read<TopicsCubit>();

    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const TopicFormPage()),
      ),
    );
  }
}

class _TopicsBody extends StatelessWidget {
  final TopicsState state;

  const _TopicsBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.topics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.topics.isEmpty) {
      return const _EmptyTopicsView();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TopicsCubit>().loadTopics(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: state.topics.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final topic = state.topics[index];

          return TopicCard(
            topic: topic,
            onStatusChanged: (status) => context
                .read<TopicsCubit>()
                .updateStatus(topicId: topic.id, status: status),
            onDelete: () => _confirmDelete(context, topic),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Topic topic) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir tópico?'),
          content: Text('O tópico "${topic.title}" será removido.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    await context.read<TopicsCubit>().deleteTopic(topic.id);
  }
}

class _EmptyTopicsView extends StatelessWidget {
  const _EmptyTopicsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.topic_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum tópico cadastrado',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Adicione conteúdos para acompanhar o progresso desta matéria.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

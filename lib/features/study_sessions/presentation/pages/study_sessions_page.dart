import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../subjects/domain/entities/subject.dart';
import '../../../topics/domain/entities/topic.dart';
import '../../domain/entities/study_session.dart';
import '../cubit/study_sessions_cubit.dart';
import '../cubit/study_sessions_state.dart';
import '../widgets/study_session_card.dart';
import 'study_session_form_page.dart';

class StudySessionsPage extends StatelessWidget {
  final Subject subject;
  final List<Topic> topics;

  const StudySessionsPage({
    super.key,
    required this.subject,
    required this.topics,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudySessionsCubit, StudySessionsState>(
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
            title: Text('Sessões - ${subject.name}'),
            actions: [
              IconButton(
                tooltip: 'Atualizar sessões',
                onPressed: state.isLoading
                    ? null
                    : () => context
                          .read<StudySessionsCubit>()
                          .loadStudySessions(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: _StudySessionsBody(state: state, topics: topics),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Adicionar sessão',
            onPressed: () => _openForm(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context) {
    final cubit = context.read<StudySessionsCubit>();

    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: StudySessionFormPage(topics: topics),
        ),
      ),
    );
  }
}

class _StudySessionsBody extends StatelessWidget {
  final StudySessionsState state;
  final List<Topic> topics;

  const _StudySessionsBody({required this.state, required this.topics});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.studySessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.studySessions.isEmpty) {
      return const _EmptyStudySessionsView();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<StudySessionsCubit>().loadStudySessions(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: state.studySessions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final studySession = state.studySessions[index];

          return StudySessionCard(
            studySession: studySession,
            topic: _topicForStudySession(studySession),
            onDelete: () => _confirmDelete(context, studySession),
          );
        },
      ),
    );
  }

  Topic? _topicForStudySession(StudySession studySession) {
    final topicId = studySession.topicId;

    if (topicId == null) return null;

    for (final topic in topics) {
      if (topic.id == topicId) return topic;
    }

    return null;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    StudySession studySession,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir sessão?'),
          content: const Text('O registro de estudo será removido.'),
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

    await context.read<StudySessionsCubit>().deleteStudySession(
      studySession.id,
    );
  }
}

class _EmptyStudySessionsView extends StatelessWidget {
  const _EmptyStudySessionsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma sessão registrada',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Registre tempo de estudo para acompanhar seu progresso.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

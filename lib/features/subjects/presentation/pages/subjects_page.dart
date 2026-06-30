import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/subjects_cubit.dart';
import '../cubit/subjects_state.dart';
import '../widgets/subject_card.dart';
import 'subject_form_page.dart';

class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubjectsCubit, SubjectsState>(
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
            title: const Text('Matérias'),
            actions: [
              IconButton(
                tooltip: 'Atualizar matérias',
                onPressed: state.isLoading
                    ? null
                    : () => context.read<SubjectsCubit>().loadSubjects(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(child: _SubjectsBody(state: state)),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Adicionar matéria',
            onPressed: () => _openForm(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context) {
    final cubit = context.read<SubjectsCubit>();

    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const SubjectFormPage()),
      ),
    );
  }
}

class _SubjectsBody extends StatelessWidget {
  final SubjectsState state;

  const _SubjectsBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.subjects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.subjects.isEmpty) {
      return const _EmptySubjectsView();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<SubjectsCubit>().loadSubjects(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: state.subjects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final subject = state.subjects[index];

          return SubjectCard(
            subject: subject,
            onDelete: () => _confirmDelete(context, subject.id),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String subjectId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir matéria?'),
          content: const Text(
            'Os tópicos e registros vinculados também serão afetados.',
          ),
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

    await context.read<SubjectsCubit>().deleteSubject(subjectId);
  }
}

class _EmptySubjectsView extends StatelessWidget {
  const _EmptySubjectsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma matéria cadastrada',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Adicione sua primeira matéria para organizar seus tópicos e estudos.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

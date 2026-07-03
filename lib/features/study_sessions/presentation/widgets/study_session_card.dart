import 'package:flutter/material.dart';

import '../../../topics/domain/entities/topic.dart';
import '../../domain/entities/study_session.dart';
import 'study_session_formatters.dart';

class StudySessionCard extends StatelessWidget {
  final StudySession studySession;
  final Topic? topic;
  final VoidCallback onDelete;

  const StudySessionCard({
    super.key,
    required this.studySession,
    required this.topic,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final notes = studySession.notes;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    formatStudySessionDuration(studySession.durationInMinutes),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Excluir sessão',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              topic?.title ?? 'Sem tópico',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              formatStudySessionDate(studySession.studiedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                notes,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

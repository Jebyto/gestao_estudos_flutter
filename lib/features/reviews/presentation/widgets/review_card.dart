import 'package:flutter/material.dart';

import '../../../topics/domain/entities/topic.dart';
import '../../domain/entities/review.dart';
import 'review_formatters.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final Topic? topic;
  final String? subjectName;
  final ValueChanged<ReviewQuality> onComplete;
  final Future<void> Function() onCancel;
  final Future<void> Function(DateTime) onReschedule;
  final DateTime referenceDate;
  final bool isBusy;

  const ReviewCard({
    super.key,
    required this.review,
    required this.topic,
    this.subjectName,
    required this.onComplete,
    required this.onCancel,
    required this.onReschedule,
    required this.referenceDate,
    this.isBusy = false,
  });

  Future<void> _cancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar revisão?'),
        content: const Text(
          'Esta revisão pendente será excluída. O histórico concluído será mantido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Cancelar revisão'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await onCancel();
  }

  Future<void> _reschedule(BuildContext context) async {
    final local = referenceDate.toLocal();
    final today = DateTime(local.year, local.month, local.day);
    final scheduled = review.scheduledFor.toLocal();
    final initial = scheduled.isBefore(today) ? today : scheduled;
    final limit = DateTime(today.year + 10, 12, 31);
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: initial.isAfter(limit) ? initial : limit,
      helpText: 'Reagendar revisão',
      confirmText: 'Reagendar',
      cancelText: 'Voltar',
    );
    if (date != null && context.mounted) await onReschedule(date);
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                Expanded(
                  child: Text(
                    topic?.title ?? 'Tópico não encontrado',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Reagendar revisão',
                  onPressed: isBusy ? null : () => _reschedule(context),
                  icon: const Icon(Icons.edit_calendar_outlined),
                ),
                IconButton(
                  tooltip: 'Cancelar revisão',
                  onPressed: isBusy ? null : () => _cancel(context),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            if (subjectName != null) ...[
              const SizedBox(height: 4),
              Text(
                subjectName!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Agendada para ${formatReviewDate(review.scheduledFor)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: isBusy
                      ? null
                      : () => onComplete(ReviewQuality.hard),
                  icon: const Icon(Icons.priority_high),
                  label: Text(reviewQualityLabel(ReviewQuality.hard)),
                ),
                FilledButton.tonalIcon(
                  onPressed: isBusy
                      ? null
                      : () => onComplete(ReviewQuality.good),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(reviewQualityLabel(ReviewQuality.good)),
                ),
                FilledButton.tonalIcon(
                  onPressed: isBusy
                      ? null
                      : () => onComplete(ReviewQuality.easy),
                  icon: const Icon(Icons.done_all_outlined),
                  label: Text(reviewQualityLabel(ReviewQuality.easy)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

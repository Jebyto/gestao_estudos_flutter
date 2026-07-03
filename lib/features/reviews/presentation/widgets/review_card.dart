import 'package:flutter/material.dart';

import '../../../topics/domain/entities/topic.dart';
import '../../domain/entities/review.dart';
import 'review_formatters.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final Topic? topic;
  final ValueChanged<ReviewQuality> onComplete;

  const ReviewCard({
    super.key,
    required this.review,
    required this.topic,
    required this.onComplete,
  });

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
            Text(
              topic?.title ?? 'Tópico não encontrado',
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
                  onPressed: () => onComplete(ReviewQuality.hard),
                  icon: const Icon(Icons.priority_high),
                  label: Text(reviewQualityLabel(ReviewQuality.hard)),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => onComplete(ReviewQuality.good),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(reviewQualityLabel(ReviewQuality.good)),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => onComplete(ReviewQuality.easy),
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

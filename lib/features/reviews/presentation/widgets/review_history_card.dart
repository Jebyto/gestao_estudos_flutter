import 'package:flutter/material.dart';

import '../../../topics/domain/entities/topic.dart';
import '../../domain/entities/review.dart';
import 'review_formatters.dart';

class ReviewHistoryCard extends StatelessWidget {
  final Review review;
  final Topic? topic;

  const ReviewHistoryCard({
    super.key,
    required this.review,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final reviewedAt = review.reviewedAt;
    final quality = review.quality;

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
            if (reviewedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Revisada em ${formatReviewDate(reviewedAt)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (quality != null) ...[
              const SizedBox(height: 4),
              Text(
                'Qualidade: ${reviewQualityLabel(quality)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

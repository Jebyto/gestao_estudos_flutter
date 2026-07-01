import 'package:flutter/material.dart';

import '../../domain/entities/topic.dart';
import 'topic_formatters.dart';

class TopicCard extends StatelessWidget {
  final Topic topic;
  final ValueChanged<TopicStatus> onStatusChanged;
  final VoidCallback onDelete;

  const TopicCard({
    super.key,
    required this.topic,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final description = topic.description;

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
                    topic.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<TopicStatus>(
                  tooltip: 'Alterar status',
                  initialValue: topic.status,
                  onSelected: onStatusChanged,
                  itemBuilder: (context) {
                    return TopicStatus.values.map((status) {
                      return PopupMenuItem<TopicStatus>(
                        value: status,
                        child: Text(topicStatusLabel(status)),
                      );
                    }).toList();
                  },
                ),
                IconButton(
                  tooltip: 'Excluir tópico',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TopicChip(
                  icon: Icons.flag_outlined,
                  label: topicPriorityLabel(topic.priority),
                ),
                _TopicChip(
                  icon: Icons.radio_button_checked,
                  label: topicStatusLabel(topic.status),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TopicChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

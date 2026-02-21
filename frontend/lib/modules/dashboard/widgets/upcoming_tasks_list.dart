import 'package:flutter/material.dart';

/// List of upcoming tasks. Uses theme.
class UpcomingTasksList extends StatelessWidget {
  const UpcomingTasksList({super.key, this.items = const []});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No upcoming tasks',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        return Row(
          children: [
            Icon(
              Icons.circle,
              size: 6,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                items[i],
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}

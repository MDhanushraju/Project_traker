import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../../../../core/constants/task_status.dart';

/// Card for a single task. Uses theme. Shows due date when available.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  final TaskModel task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = task.title ?? 'Task';
    final status = task.status ?? TaskStatus.todo;
    final dueDate = task.dueDate;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _StatusIndicator(status: status),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatusChip(status: status),
                        if (dueDate != null && dueDate.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dueDate,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;
    switch (status) {
      case TaskStatus.done:
        color = theme.colorScheme.primary;
        icon = Icons.check_circle_rounded;
        break;
      case TaskStatus.inProgress:
        color = theme.colorScheme.tertiary;
        icon = Icons.pending_rounded;
        break;
      default:
        color = theme.colorScheme.outline;
        icon = Icons.radio_button_unchecked_rounded;
    }
    return Icon(icon, color: color, size: 24);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = status == TaskStatus.inProgress
        ? 'In progress'
        : status == TaskStatus.done
            ? 'Done'
            : 'To do';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

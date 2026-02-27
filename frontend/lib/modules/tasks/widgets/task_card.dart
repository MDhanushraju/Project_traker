import 'package:flutter/material.dart';

import '../../../../core/constants/task_status.dart';
import '../models/task_model.dart';

/// Card for a single task. Uses theme. Shows status dropdown, delete, due date.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChange,
    this.onDelete,
    this.canEdit = false,
  });

  final TaskModel task;
  final VoidCallback? onTap;
  final void Function(String status)? onStatusChange;
  final VoidCallback? onDelete;
  final bool canEdit;

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
                    const SizedBox(height: 6),
                    Text(
                      TaskStatus.label(status),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if ((task.assigneeName ?? '').isNotEmpty || (task.projectName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        [
                          if ((task.assigneeName ?? '').isNotEmpty) 'Assigned to ${task.assigneeName}',
                          if ((task.projectName ?? '').isNotEmpty) 'Project: ${task.projectName}',
                        ].join(' · '),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (dueDate != null && dueDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
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
                      ),
                    ],
                  ],
                ),
              ),
              if (canEdit && onStatusChange != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StatusDropdown(
                    value: status,
                    onChanged: onStatusChange!,
                  ),
                ),
              if (canEdit && onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 22),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                )
              else if (!canEdit || onStatusChange == null)
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
    if (status == TaskStatus.completed || status == TaskStatus.done || status == 'done') {
      color = Colors.green;
      icon = Icons.check_circle_rounded;
    } else if (status == TaskStatus.ongoing || status == TaskStatus.inProgress || status == 'in_progress') {
      color = theme.colorScheme.tertiary;
      icon = Icons.pending_rounded;
    } else {
      color = theme.colorScheme.outline;
      icon = Icons.schedule_rounded;
    }
    return Icon(icon, color: color, size: 24);
  }
}

String _normalizeStatus(String s) {
  if (TaskStatus.all.contains(s)) return s;
  if (s == TaskStatus.inProgress || s == 'in_progress') return TaskStatus.ongoing;
  if (s == TaskStatus.done || s == 'done') return TaskStatus.completed;
  return TaskStatus.needToStart;
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});

  final String value;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _normalizeStatus(value),
          isDense: true,
          iconSize: 18,
          items: TaskStatus.all.map((s) => DropdownMenuItem(
            value: s,
            child: Text(TaskStatus.label(s), style: theme.textTheme.labelSmall),
          )).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = TaskStatus.label(status);
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

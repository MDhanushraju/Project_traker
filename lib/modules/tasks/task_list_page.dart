import 'package:flutter/material.dart';

import '../../../core/constants/task_status.dart';
import '../../../data/mock_data.dart';
import '../../../shared/animations/fade_in.dart';
import '../../../shared/layouts/main_layout.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../app/app_routes.dart';
import 'widgets/task_card.dart';

/// Task list screen. Uses [MainLayout]; filter chips and task cards.
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var tasks = MockData.tasks;
    if (_filter != 'all') {
      tasks = tasks.where((t) => t.status == _filter).toList();
    }

    return MainLayout(
      title: 'Tasks',
      currentRoute: AppRoutes.tasks,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: FadeIn(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'To do',
                      selected: _filter == TaskStatus.todo,
                      onTap: () => setState(() => _filter = TaskStatus.todo),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'In progress',
                      selected: _filter == TaskStatus.inProgress,
                      onTap: () => setState(() => _filter = TaskStatus.inProgress),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Done',
                      selected: _filter == TaskStatus.done,
                      onTap: () => setState(() => _filter = TaskStatus.done),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: tasks.isEmpty
                ? EmptyState(
                    icon: Icons.task_alt_rounded,
                    title: 'No tasks',
                    subtitle: 'No tasks match this filter.',
                    actionLabel: 'Add task',
                    onAction: () {},
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      FadeIn(
                        child: Text(
                          '${tasks.length} task${tasks.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...tasks.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FadeIn(
                            child: TaskCard(task: t),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      side: BorderSide(
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/constants/roles.dart';
import '../../../core/constants/task_status.dart';
import '../../../data/data_provider.dart';
import '../../../data/mock_data.dart';
import '../../../shared/animations/fade_in.dart';
import '../../../shared/layouts/main_layout.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../app/app_routes.dart';
import 'models/task_model.dart';
import 'widgets/task_card.dart';

/// Task list screen. Loads from API.
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

/// Bucket task status into one of: need_to_start, ongoing, completed.
String _columnStatus(String? s) {
  if (s == null || s.isEmpty) return TaskStatus.needToStart;
  final lower = s.toLowerCase();
  if (lower.contains('ongoing') || lower == 'in_progress') return TaskStatus.ongoing;
  if (lower.contains('complete') || lower == 'done') return TaskStatus.completed;
  return TaskStatus.needToStart;
}

/// Max tasks to show per status page (remove "fake" clutter; show only a few).
const int _kMaxTasksPerPage = 3;

class _TaskListPageState extends State<TaskListPage> {
  /// Current page filter: null = All, or one of needToStart, ongoing, completed.
  String? _statusFilter;

  bool _canAddOrEditTasks() {
    final role = AuthState.instance.currentUser?.role;
    return role == AppRole.admin || role == AppRole.member || role == AppRole.teamLeader || role == AppRole.manager;
  }

  Future<void> _showAddTaskSheet() async {
    final controller = TextEditingController();
    final descriptionController = TextEditingController();
    final statusNotifier = ValueNotifier<String>(TaskStatus.needToStart);
    final addingNotifier = ValueNotifier<bool>(false);
    final result = await showModalBottomSheet<(bool, TaskModel?)>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ValueListenableBuilder<bool>(
        valueListenable: addingNotifier,
        builder: (_, adding, __) => ValueListenableBuilder<String>(
          valueListenable: statusNotifier,
          builder: (__, status, ___) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add Task', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      hintText: 'e.g. Fix login bug',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                    enabled: !adding,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Add more details about the task',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    enabled: !adding,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: TaskStatus.all.map((s) => DropdownMenuItem(value: s, child: Text(TaskStatus.label(s)))).toList(),
                    onChanged: adding ? null : (v) => statusNotifier.value = v ?? TaskStatus.needToStart,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: adding ? null : () => Navigator.pop(ctx, (false, null)),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: adding
                              ? null
                              : () async {
                                  final title = controller.text.trim();
                                  if (title.isEmpty) return;
                                  final desc = descriptionController.text.trim();
                                  addingNotifier.value = true;
                                  final (ok, errorMsg, createdTask) = await DataProvider.instance.createTaskWithMessage(
                                    title: title,
                                    status: status,
                                    description: desc.isEmpty ? null : desc,
                                  );
                                  if (ctx.mounted) {
                                    addingNotifier.value = false;
                                    Navigator.pop(ctx, (ok, createdTask));
                                    if (!ok && errorMsg != null) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg),
                                          backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: adding
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (result != null && result.$1 && mounted) {
      if (result.$2 != null) MockData.prependTask(result.$2!);
      await MockData.refreshFromApi();
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task added')));
    }
  }

  Future<void> _updateStatus(String taskId, String status) async {
    if (taskId.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task ID missing; cannot update')));
      return;
    }
    final (ok, msg) = await DataProvider.instance.updateTaskStatusWithMessage(taskId: taskId, status: status);
    if (ok && mounted) {
      await MockData.refreshFromApi();
      setState(() {});
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg ?? 'Failed to update status')),
      );
    }
  }

  Future<void> _deleteTask(String taskId) async {
    if (taskId.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task ID missing; cannot delete')));
      return;
    }
    final (ok, msg) = await DataProvider.instance.deleteTaskWithMessage(taskId);
    if (ok && mounted) {
      await MockData.refreshFromApi();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg ?? 'Failed to delete')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    MockData.refreshFromApi().then((_) {
      if (!mounted) return;
      setState(() {});
      if (MockData.lastError != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not load tasks: ${MockData.lastError}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (MockData.isLoading) {
      return MainLayout(
        title: 'Tasks',
        currentRoute: AppRoutes.tasks,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading tasks...'),
            ],
          ),
        ),
      );
    }
    final allTasks = MockData.tasks;
    final canEdit = _canAddOrEditTasks();

    // Filter by selected status (page). Only real API data – no fake tasks.
    List<TaskModel> filtered;
    String pageTitle;
    if (_statusFilter == null) {
      filtered = allTasks;
      pageTitle = 'All tasks';
    } else {
      filtered = allTasks.where((t) => _columnStatus(t.status) == _statusFilter).toList();
      pageTitle = _statusFilter == TaskStatus.needToStart
          ? 'Yet to start'
          : _statusFilter == TaskStatus.ongoing
              ? 'Ongoing'
              : 'Completed';
    }
    // Show only 3 tasks per page (remove clutter).
    final displayed = filtered.take(_kMaxTasksPerPage).toList();

    return MainLayout(
      title: 'Tasks',
      currentRoute: AppRoutes.tasks,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeIn(
                  child: Text(
                    '${allTasks.length} task${allTasks.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await MockData.refreshFromApi();
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh tasks',
                    ),
                    if (canEdit) ...[
                      const SizedBox(width: 4),
                      FilledButton(
                        onPressed: _showAddTaskSheet,
                        child: const Text('Add (to me)'),
                      ),
                      const SizedBox(width: 6),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.assignTask);
                        },
                        child: const Text('Assign to member'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 4 buttons: All, Yet to start, Ongoing, Completed – click to go to that page.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PageButton(
                    label: 'All',
                    selected: _statusFilter == null,
                    onTap: () => setState(() => _statusFilter = null),
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _PageButton(
                    label: 'Yet to start',
                    selected: _statusFilter == TaskStatus.needToStart,
                    onTap: () => setState(() => _statusFilter = TaskStatus.needToStart),
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _PageButton(
                    label: 'Ongoing',
                    selected: _statusFilter == TaskStatus.ongoing,
                    onTap: () => setState(() => _statusFilter = TaskStatus.ongoing),
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _PageButton(
                    label: 'Completed',
                    selected: _statusFilter == TaskStatus.completed,
                    onTap: () => setState(() => _statusFilter = TaskStatus.completed),
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: allTasks.isEmpty && MockData.lastError != null
                ? EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Could not load tasks',
                    subtitle: '${MockData.lastError}\n\nMake sure the backend is running (e.g. gradlew bootRun) and you are logged in.',
                    actionLabel: 'Retry',
                    onAction: () async {
                      await MockData.refreshFromApi();
                      if (mounted) setState(() {});
                    },
                  )
                : displayed.isEmpty
                    ? EmptyState(
                        icon: Icons.task_alt_rounded,
                        title: pageTitle,
                        subtitle: _statusFilter == null
                            ? 'No tasks. Tap Refresh or add a task.'
                            : 'No tasks in "$pageTitle". Add one or choose another page.',
                        actionLabel: canEdit ? 'Add task' : 'Refresh',
                        onAction: canEdit ? _showAddTaskSheet : () async {
                          await MockData.refreshFromApi();
                          if (mounted) setState(() {});
                        },
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              pageTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          ...displayed.map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FadeIn(
                                child: TaskCard(
                                  task: t,
                                  canEdit: canEdit,
                                  onStatusChange: canEdit ? (s) => _updateStatus(t.id ?? '', s) : null,
                                  onDelete: canEdit ? () => _deleteTask(t.id ?? '') : null,
                                ),
                              ),
                            ),
                          ),
                          if (filtered.length > _kMaxTasksPerPage)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Showing ${displayed.length} of ${filtered.length}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
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

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: selected ? theme.colorScheme.primaryContainer : null,
        foregroundColor: selected ? theme.colorScheme.onPrimaryContainer : null,
      ),
      child: Text(label),
    );
  }
}

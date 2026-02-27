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
import 'widgets/task_card.dart';

/// Task list screen. Loads from API.
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String _filter = 'all';

  bool _canAddOrEditTasks() {
    final role = AuthState.instance.currentUser?.role;
    return role == AppRole.admin || role == AppRole.member || role == AppRole.teamLeader || role == AppRole.manager;
  }

  Future<void> _showAddTaskSheet() async {
    final controller = TextEditingController();
    final statusNotifier = ValueNotifier<String>(TaskStatus.needToStart);
    final addingNotifier = ValueNotifier<bool>(false);
    final result = await showModalBottomSheet<bool>(
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
                          onPressed: adding ? null : () => Navigator.pop(ctx, false),
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
                                  addingNotifier.value = true;
                                  final (ok, errorMsg) = await DataProvider.instance.createTaskWithMessage(
                                    title: title,
                                    status: status,
                                  );
                                  if (ctx.mounted) {
                                    addingNotifier.value = false;
                                    Navigator.pop(ctx, ok);
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
    if (result == true && mounted) {
      await MockData.refreshFromApi();
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task added')));
    }
  }

  Future<void> _updateStatus(String taskId, String status) async {
    final ok = await DataProvider.instance.updateTaskStatus(taskId: taskId, status: status);
    if (ok && mounted) {
      // Optimistically update: refresh data then rebuild so status label under title updates quickly.
      await MockData.refreshFromApi();
      setState(() {});
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  Future<void> _deleteTask(String taskId) async {
    final ok = await DataProvider.instance.deleteTask(taskId);
    if (ok && mounted) {
      await MockData.refreshFromApi();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete')));
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
    var tasks = MockData.tasks;
    if (_filter != 'all') {
      tasks = tasks.where((t) {
        final s = t.status ?? '';
        if (_filter == TaskStatus.needToStart) return s == TaskStatus.needToStart || s == TaskStatus.todo || s == TaskStatus.yetToStart;
        if (_filter == TaskStatus.ongoing) return s == TaskStatus.ongoing || s == TaskStatus.inProgress;
        if (_filter == TaskStatus.completed) return s == TaskStatus.completed || s == TaskStatus.done;
        return s == _filter;
      }).toList();
    }

    final canEdit = _canAddOrEditTasks();
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
                Expanded(
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
                            label: 'Need to Start',
                            selected: _filter == TaskStatus.needToStart,
                            onTap: () => setState(() => _filter = TaskStatus.needToStart),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Ongoing',
                            selected: _filter == TaskStatus.ongoing,
                            onTap: () => setState(() => _filter = TaskStatus.ongoing),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Completed',
                            selected: _filter == TaskStatus.completed,
                            onTap: () => setState(() => _filter = TaskStatus.completed),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: tasks.isEmpty && MockData.lastError != null
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
                : tasks.isEmpty
                    ? EmptyState(
                        icon: Icons.task_alt_rounded,
                        title: 'No tasks',
                        subtitle: 'No tasks match this filter. Tap Refresh above or add a task.',
                        actionLabel: canEdit ? 'Add task' : 'Refresh',
                        onAction: canEdit ? _showAddTaskSheet : () async {
                          await MockData.refreshFromApi();
                          if (mounted) setState(() {});
                        },
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
                            child: TaskCard(
                              task: t,
                              canEdit: canEdit,
                              onStatusChange: canEdit ? (s) => _updateStatus(t.id ?? '', s) : null,
                              onDelete: canEdit ? () => _deleteTask(t.id ?? '') : null,
                            ),
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

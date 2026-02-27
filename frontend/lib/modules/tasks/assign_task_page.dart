import 'package:flutter/material.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/constants/roles.dart';
import '../../../data/data_provider.dart';
import '../../../data/mock_data.dart';

/// Assign tasks to team members. Admin/Manager: all users. Team Leader: only their team members.
class AssignTaskPage extends StatefulWidget {
  const AssignTaskPage({super.key});

  @override
  State<AssignTaskPage> createState() => _AssignTaskPageState();
}

class _UserOption {
  final int id;
  final String name;
  _UserOption({required this.id, required this.name});
}

class _AssignTaskPageState extends State<AssignTaskPage> {
  String? _selectedUser;
  int? _selectedUserId;
  String? _selectedTask;
  String? _selectedProject;
  DateTime? _dueDate;
  final _taskTitleController = TextEditingController();
  bool _createNewTask = false;
  bool _sendNotification = true;
  List<_UserOption> _assignableUsers = [];
  bool _loadingUsers = true;

  List<String> get _userNames =>
      _assignableUsers.map((u) => u.name).toList()..sort();

  @override
  void initState() {
    super.initState();
    _loadAssignableUsers();
  }

  Future<void> _loadAssignableUsers() async {
    setState(() => _loadingUsers = true);
    final role = AuthState.instance.currentUser?.role;
    if (role == AppRole.teamLeader) {
      final teamMap = MockData.teamLeaderTeamMembers;
      final projects = _selectedProject != null
          ? [_selectedProject!]
          : MockData.teamLeaderAssignedProjects;
      final byId = <int, _UserOption>{};
      for (final p in projects) {
        for (final m in teamMap[p] ?? []) {
          final id = m['id'];
          if (id != null) {
            final idInt = id is int ? id : int.tryParse(id.toString());
            if (idInt != null && !byId.containsKey(idInt)) {
              byId[idInt] = _UserOption(
                id: idInt,
                name: (m['name'] ?? '').toString(),
              );
            }
          }
        }
      }
      _assignableUsers = byId.values.toList();
    } else {
      final users = await DataProvider.instance.getAllUsers();
      final roleStr = (u) => (u['role'] ?? '').toString().toLowerCase();
      final filtered = role == AppRole.manager
          ? users.where((u) => roleStr(u) == 'team_leader' || roleStr(u) == 'member')
          : role == AppRole.admin
              ? users.where((u) => roleStr(u) != 'admin')
              : users;
      _assignableUsers = filtered
          .map((u) {
            final id = u['id'];
            if (id == null) return null;
            final idInt = id is int ? id : int.tryParse(id.toString());
            final name = (u['name'] ?? u['fullName'] ?? '').toString();
            return idInt != null ? _UserOption(id: idInt, name: name) : null;
          })
          .whereType<_UserOption>()
          .toList();
    }
    setState(() {
      _loadingUsers = false;
      if (_selectedUser != null) {
        for (final o in _assignableUsers) {
          if (o.name == _selectedUser) {
            _selectedUserId = o.id;
            break;
          }
        }
      }
    });
  }

  List<String> get _existingTasks =>
      MockData.tasks.map((t) => t.title ?? '').where((t) => t.isNotEmpty).toList();

  @override
  void dispose() {
    _taskTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Assign Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign a task to a user',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select user and task. Create a new task or pick from existing tasks.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            if (AuthState.instance.currentUser?.role == AppRole.teamLeader ||
                AuthState.instance.currentUser?.role == AppRole.manager ||
                AuthState.instance.currentUser?.role == AppRole.admin) ...[
              _DropdownField(
                label: 'Project',
                hint: 'Assign task to this project',
                icon: Icons.folder_outlined,
                value: _selectedProject ?? 'All',
                options: ['All', ...MockData.projects.map((p) => p.name ?? '').where((n) => n.isNotEmpty)],
                onSelected: (v) {
                  setState(() {
                    _selectedProject = v == 'All' ? null : v;
                    if (AuthState.instance.currentUser?.role == AppRole.teamLeader) {
                      _selectedUser = null;
                      _selectedUserId = null;
                      _loadAssignableUsers();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            _DropdownField(
              label: 'Assign to',
              hint: _loadingUsers
                  ? 'Loading...'
                  : (_userNames.isEmpty ? 'No team members' : 'Select team member'),
              icon: Icons.person_outline_rounded,
              value: _selectedUser,
              options: _userNames,
              onSelected: (v) {
                int? id;
                for (final o in _assignableUsers) {
                  if (o.name == v) {
                    id = o.id;
                    break;
                  }
                }
                setState(() {
                  _selectedUser = v;
                  _selectedUserId = id;
                });
              },
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Create new task'),
              subtitle: Text(
                _createNewTask ? 'Enter task title below' : 'Pick from existing tasks',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: _createNewTask,
              onChanged: (v) => setState(() {
                _createNewTask = v;
                if (!v) _taskTitleController.clear();
              }),
            ),
            if (_createNewTask) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _taskTitleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g. Fix login bug',
                  prefixIcon: const Icon(Icons.task_alt_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              _DropdownField(
                label: 'Task',
                hint: 'Select task',
                icon: Icons.task_alt_outlined,
                value: _selectedTask,
                options: _existingTasks,
                onSelected: (v) => setState(() => _selectedTask = v),
              ),
            ],
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (d != null) setState(() => _dueDate = d);
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  hintText: 'Optional',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _dueDate != null
                      ? '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: _dueDate != null ? null : Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.notifications_outlined, size: 24, color: theme.colorScheme.onSurface),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Notification',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Notify user via email & app',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _sendNotification,
                  onChanged: (v) => setState(() => _sendNotification = v),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _onAssign,
                icon: const Icon(Icons.assignment_rounded, size: 20),
                label: const Text('Assign Task'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAssign() async {
    if (_selectedUserId == null || _selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a user')),
      );
      return;
    }
    final taskTitle = _createNewTask ? _taskTitleController.text.trim() : _selectedTask;
    if (taskTitle == null || taskTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select or create a task')),
      );
      return;
    }
    String? dueStr;
    if (_dueDate != null) {
      dueStr =
          '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}';
    }
    int? projectId;
    if (_selectedProject != null) {
      for (final p in MockData.projects) {
        if (p.name == _selectedProject && p.id != null) {
          projectId = int.tryParse(p.id!);
          break;
        }
      }
    }
    final ok = await DataProvider.instance.assignTask(
      userId: _selectedUserId!,
      taskTitle: taskTitle,
      dueDate: dueStr,
      projectId: projectId,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task "$taskTitle" assigned to $_selectedUser')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to assign task')),
      );
    }
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.hint,
    required this.icon,
    this.value,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final List<String> options;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: options.isEmpty
          ? null
          : () => showModalBottomSheet<String>(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      ...options.map((o) => ListTile(
                            title: Text(o),
                            onTap: () {
                              onSelected(o);
                              Navigator.pop(ctx);
                            },
                          )),
                    ],
                  ),
                ),
              ),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          value ?? hint,
          style: TextStyle(
            color: value != null ? null : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}

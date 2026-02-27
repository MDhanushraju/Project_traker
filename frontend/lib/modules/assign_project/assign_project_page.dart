import 'package:flutter/material.dart';

import '../../data/data_provider.dart';
import '../../data/positions_data.dart';
import '../projects/models/project_model.dart';

/// Project role: 1 Manager per project; max 3 Team Leaders; Team Members unlimited.
enum _ProjectRole {
  manager('Manager', '1 per project'),
  teamLeader('Team Leader', 'Max 3 per project'),
  teamMember('Team Member', 'Unlimited');

  const _ProjectRole(this.label, this.hint);
  final String label;
  final String hint;
}

/// Full-screen Assign Project form. Loads projects and users from API.
/// Manager: show all managers, assign one per project. Team Leader: show all, unlimited.
class AssignProjectPage extends StatefulWidget {
  const AssignProjectPage({super.key});

  @override
  State<AssignProjectPage> createState() => _AssignProjectPageState();
}

class _AssignProjectPageState extends State<AssignProjectPage> {
  bool _sendNotification = true;
  List<ProjectModel> _projects = [];
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _projectTeam;
  bool _loading = true;

  String? _selectedProjectName;
  int? _selectedProjectId;
  Map<String, dynamic>? _selectedUser;
  _ProjectRole? _selectedRole;
  String? _selectedPosition;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<_AssignmentEntry> _currentAssignments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final projects = await DataProvider.instance.getProjects();
    final users = await DataProvider.instance.getAllUsers();
    if (mounted) {
      setState(() {
        _projects = projects;
        _users = users;
        _loading = false;
      });
    }
  }

  Future<void> _loadProjectTeam(int projectId) async {
    final team = await DataProvider.instance.getProjectTeam(projectId);
    if (mounted) setState(() => _projectTeam = team);
  }

  /// Users with the selected role from API (all managers, all team leaders, or all members).
  List<Map<String, dynamic>> get _usersForSelectedRole {
    if (_selectedRole == null) return [];
    final roleStr = (Map<String, dynamic> u) => (u['role'] ?? '').toString().toLowerCase();
    if (_selectedRole == _ProjectRole.manager) {
      return _users.where((u) => roleStr(u) == 'manager').toList();
    }
    if (_selectedRole == _ProjectRole.teamLeader) {
      return _users.where((u) => roleStr(u) == 'team_leader').toList();
    }
    if (_selectedRole == _ProjectRole.teamMember) {
      if (_selectedPosition == null) return _users.where((u) => roleStr(u) == 'member').toList();
      return _users.where((u) {
        if (roleStr(u) != 'member') return false;
        final pos = (u['position'] ?? u['title'] ?? '').toString();
        return pos.toLowerCase().contains(_selectedPosition!.toLowerCase());
      }).toList();
    }
    return [];
  }

  String get _memberHint {
    final list = _usersForSelectedRole;
    if (list.isEmpty) return 'No users with this role';
    return 'Choose from ${list.length} ${_selectedRole!.label}(s)';
  }

  /// Project already has a manager (from API team); only one manager per project.
  bool get _projectHasManager {
    if (_projectTeam == null) return false;
    final members = _projectTeam!['members'];
    if (members is! List) return false;
    for (final m in members) {
      if (m is Map && (m['projectRole'] ?? '').toString().toLowerCase() == 'manager') return true;
    }
    return false;
  }

  /// Project already has 3 team leaders (max per project).
  bool get _projectHasThreeTeamLeaders {
    if (_projectTeam == null) return false;
    final members = _projectTeam!['members'];
    if (members is! List) return false;
    int count = 0;
    for (final m in members) {
      if (m is Map && (m['projectRole'] ?? '').toString().toLowerCase() == 'team_leader') count++;
    }
    return count >= 3;
  }

  /// Manager: only if project has no manager. Team Leader: only if fewer than 3. Member: always.
  List<_ProjectRole> get _availableRolesForProject {
    if (_selectedProjectId == null) return _ProjectRole.values;
    return _ProjectRole.values.where((r) {
      if (r == _ProjectRole.manager && _projectHasManager) return false;
      if (r == _ProjectRole.teamLeader && _projectHasThreeTeamLeaders) return false;
      return true;
    }).toList();
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
        title: const Text('Assign Project'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Assignment',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select role first. One Manager per project; Team Leaders and Members unlimited. When you select Manager, all managers are shown; when you select Team Leader, all team leaders are shown.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
            _DropdownField(
              label: 'Active Project',
              hint: 'Choose an active project.',
              icon: Icons.folder_outlined,
              value: _selectedProjectName,
              onTap: () => _showProjectPicker(context),
            ),
            const SizedBox(height: 16),
            _DropdownField(
              label: 'Role & Permissions',
              hint: 'Select role first.',
              icon: Icons.badge_outlined,
              value: _selectedRole?.label,
              onTap: () => _showRolePicker(context),
            ),
            if (_selectedRole != null && _selectedRole == _ProjectRole.teamMember) ...[
              const SizedBox(height: 16),
              _DropdownField(
                label: 'Position (optional)',
                hint: 'Filter by position (Developer, Tester, etc.)',
                icon: Icons.groups_rounded,
                value: _selectedPosition,
                onTap: () => _showPositionPicker(context),
              ),
            ],
            if (_selectedRole != null) ...[
              const SizedBox(height: 16),
              _DropdownField(
                label: _selectedRole == _ProjectRole.manager ? 'Manager' : _selectedRole == _ProjectRole.teamLeader ? 'Team Leader' : 'Team Member',
                hint: _memberHint,
                icon: Icons.person_outline_rounded,
                value: _selectedUser != null ? (_selectedUser!['fullName'] ?? _selectedUser!['name'] ?? '').toString() : null,
                onTap: () => _showTeamMemberPicker(context),
              ),
            ],
            if (_selectedRole != null) ...[
              const SizedBox(height: 4),
              Text(
                _selectedRole!.hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Manager: one per project. Team Leader & Member: unlimited. Assign from Users with the selected role.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _pickDate(context, isStart: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DateField(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _pickDate(context, isStart: false),
                  ),
                ),
              ],
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
                onPressed: _onConfirm,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                label: const Text('Confirm Assignment'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            ], // end if (!_loading)
            if (_currentAssignments.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Added to this session (${_currentAssignments.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ..._currentAssignments.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${e.member} → ${e.role}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _selectedUser = null;
                    _selectedRole = null;
                    _startDate = null;
                    _endDate = null;
                  }),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add another member'),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showProjectPicker(BuildContext context) {
    if (_projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No projects loaded')));
      return;
    }
    showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => _PickerSheet(
        title: 'Active Project',
        options: _projects.map((p) => p.name ?? '').where((n) => n.isNotEmpty).toList(),
        onSelected: (name) {
          ProjectModel? p;
          for (final x in _projects) {
            if (x.name == name) { p = x; break; }
          }
          final id = p != null ? int.tryParse(p.id ?? '') : null;
          setState(() {
            _selectedProjectName = name;
            _selectedProjectId = id;
            _selectedRole = null;
            _selectedUser = null;
            _projectTeam = null;
          });
          Navigator.pop(ctx);
          if (id != null) _loadProjectTeam(id);
        },
      ),
    );
  }

  void _showTeamMemberPicker(BuildContext context) {
    final list = _usersForSelectedRole;
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No ${_selectedRole?.label ?? ''} users available')),
      );
      return;
    }
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select ${_selectedRole?.label ?? 'Member'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ...list.map((u) {
              final name = (u['fullName'] ?? u['name'] ?? '').toString();
              final id = u['id'];
              final idInt = id is int ? id : (id != null ? int.tryParse(id.toString()) : null);
              return ListTile(
                title: Text(name),
                subtitle: u['email'] != null ? Text((u['email']).toString()) : null,
                onTap: () {
                  Navigator.pop(ctx, idInt != null ? u : null);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ).then((user) {
      if (user != null) setState(() => _selectedUser = user);
    });
  }

  void _showPositionPicker(BuildContext context) {
    final positions = PositionsData.instance.positions;
    if (positions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No positions configured')));
      return;
    }
    showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => _PickerSheet(
        title: 'Position',
        options: positions,
        onSelected: (v) {
          setState(() { _selectedPosition = v; _selectedUser = null; });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showRolePicker(BuildContext context) {
    setState(() { _selectedUser = null; _selectedPosition = null; });
    if (_selectedProjectId != null && _projectTeam == null) _loadProjectTeam(_selectedProjectId!);
    final available = _availableRolesForProject;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This project already has a manager')),
      );
      return;
    }
    showModalBottomSheet<_ProjectRole>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Role & Permissions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ...available.map((r) => ListTile(
              title: Text(r.label),
              subtitle: Text(r.hint, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              onTap: () {
                setState(() => _selectedRole = r);
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _onConfirm() async {
    if (_selectedProjectId == null || _selectedProjectName == null || _selectedUser == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select project, role, and user')),
      );
      return;
    }
    if (!_availableRolesForProject.contains(_selectedRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This project already has a manager')),
      );
      return;
    }

    final userId = _selectedUser!['id'];
    final userIdInt = userId is int ? userId : (userId != null ? int.tryParse(userId.toString()) : null);
    if (userIdInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid user')));
      return;
    }

    final roleStr = _selectedRole == _ProjectRole.manager ? 'manager' : _selectedRole == _ProjectRole.teamLeader ? 'team_leader' : 'team_member';
    final name = (_selectedUser!['fullName'] ?? _selectedUser!['name'] ?? '').toString();

    final result = await DataProvider.instance.assignUserToProject(userIdInt, _selectedProjectId!, roleStr);
    if (!mounted) return;
    if (result != null) {
      final roleLabel = _selectedRole!.label;
      _currentAssignments.add(_AssignmentEntry(
        project: _selectedProjectName!,
        member: name,
        role: roleLabel,
      ));
      await _loadProjectTeam(_selectedProjectId!);
      setState(() {
        _selectedUser = null;
        _selectedRole = null;
        _selectedPosition = null;
        _startDate = null;
        _endDate = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name assigned as $roleLabel')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to assign. User may already be on this project or project already has a manager.')),
      );
    }
  }
}

class _AssignmentEntry {
  _AssignmentEntry({required this.project, required this.member, required this.role});
  final String project;
  final String member;
  final String role;
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.hint,
    required this.icon,
    this.value,
    required this.onTap,
  });

  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(value ?? hint, style: TextStyle(color: value != null ? null : Theme.of(context).hintColor)),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  String _format(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'MM/DD/YYYY',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: const Icon(Icons.calendar_month_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          date != null ? _format(date!) : '',
          style: TextStyle(color: date != null ? null : Theme.of(context).hintColor),
        ),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ...options.map((o) => ListTile(title: Text(o), onTap: () => onSelected(o))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

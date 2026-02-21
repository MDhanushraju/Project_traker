import 'package:flutter/material.dart';

import '../../data/positions_data.dart';
import '../../data/team_members_data.dart';

/// Project role: 1 Manager, 1 Team Leader, multiple Team Members per project.
enum _ProjectRole {
  manager('Manager', '1 per project'),
  teamLeader('Team Leader', '1 per project'),
  teamMember('Team Member', 'Unlimited');

  const _ProjectRole(this.label, this.hint);
  final String label;
  final String hint;
}

/// Full-screen Assign Project form. Flow: Add project → Add members with roles.
/// Roles: 1 Manager, 1 Team Leader, multiple Team Members (dynamic).
class AssignProjectPage extends StatefulWidget {
  const AssignProjectPage({super.key});

  @override
  State<AssignProjectPage> createState() => _AssignProjectPageState();
}

class _AssignProjectPageState extends State<AssignProjectPage> {
  bool _sendNotification = true;
  String? _selectedProject;
  String? _selectedMember;
  _ProjectRole? _selectedRole;
  String? _selectedPosition;
  DateTime? _startDate;
  DateTime? _endDate;

  /// Tracks assignments per project. Replace with API/state later.
  final Map<String, Set<_ProjectRole>> _projectAssignments = {};
  final List<_AssignmentEntry> _currentAssignments = [];

  List<TeamMemberData> get _membersForSelectedRoleAndPosition {
    if (_selectedRole == null) return [];
    if (_selectedRole == _ProjectRole.manager) return membersByRole(TeamMemberRole.manager);
    if (_selectedPosition == null) return [];
    return membersByPositionAndRole(_selectedPosition!, _selectedRole == _ProjectRole.teamLeader ? TeamMemberRole.teamLeader : TeamMemberRole.teamMember);
  }

  TeamMemberRole? get _projectRoleToMemberRole {
    if (_selectedRole == null) return null;
    switch (_selectedRole!) {
      case _ProjectRole.manager:
        return TeamMemberRole.manager;
      case _ProjectRole.teamLeader:
        return TeamMemberRole.teamLeader;
      case _ProjectRole.teamMember:
        return TeamMemberRole.teamMember;
    }
  }

  List<TeamMemberData> get _membersForSelectedRole => _membersForSelectedRoleAndPosition;

  String get _memberHint {
    final list = _membersForSelectedRole;
    if (list.isEmpty) return 'No users with this role';
    return 'Choose from ${list.length} ${_selectedRole!.label}(s)';
  }

  List<_ProjectRole> get _availableRolesForProject {
    if (_selectedProject == null) return _ProjectRole.values.toList();
    final assigned = _projectAssignments[_selectedProject] ?? {};
    return _ProjectRole.values.where((r) {
      if (r == _ProjectRole.manager || r == _ProjectRole.teamLeader) {
        return !assigned.contains(r);
      }
      return true; // Team Member: unlimited
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
              'Select role first — only users with that role can be assigned. One Manager and one Team Leader per project.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            _DropdownField(
              label: 'Active Project',
              hint: 'Choose an active project.',
              icon: Icons.folder_outlined,
              value: _selectedProject,
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
            if (_selectedRole != null && _selectedRole != _ProjectRole.manager) ...[
              const SizedBox(height: 16),
              _DropdownField(
                label: 'Position (Team)',
                hint: 'Select position (Developer, Tester, etc.)',
                icon: Icons.groups_rounded,
                value: _selectedPosition,
                onTap: () => _showPositionPicker(context),
              ),
            ],
            if (_selectedRole != null && (_selectedRole == _ProjectRole.manager || _selectedPosition != null)) ...[
              const SizedBox(height: 16),
              _DropdownField(
                label: 'Team Member',
                hint: _memberHint,
                icon: Icons.person_outline_rounded,
                value: _selectedMember,
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
              'Manager: full control. Team Leader: edit & team management. Team Member: task execution.',
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
                    _selectedMember = null;
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
    showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => _PickerSheet(
        title: 'Active Project',
        options: const ['Website Redesign', 'Mobile App', 'API Integration', 'ALPHA', 'GAMMA'],
        onSelected: (v) {
          setState(() {
            _selectedProject = v;
            _selectedRole = null;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showTeamMemberPicker(BuildContext context) {
    final members = _membersForSelectedRole;
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No ${_selectedRole?.label ?? ''} users available')),
      );
      return;
    }
    showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => _PickerSheet(
        title: 'Select ${_selectedRole?.label ?? 'Member'}',
        options: members.map((m) => '${m.name}${m.isTemporary ? ' (Temp)' : ''}').toList(),
        onSelected: (v) {
          final name = v.replaceAll(' (Temp)', '');
          setState(() => _selectedMember = name);
          Navigator.pop(ctx);
        },
      ),
    );
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
          setState(() { _selectedPosition = v; _selectedMember = null; });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showRolePicker(BuildContext context) {
    setState(() { _selectedMember = null; _selectedPosition = null; });
    final available = _availableRolesForProject;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manager and Team Leader already assigned for this project')),
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

  void _onConfirm() {
    if (_selectedProject == null || _selectedMember == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select project, member, and role')),
      );
      return;
    }
    if (!_availableRolesForProject.contains(_selectedRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This role is already assigned for the selected project')),
      );
      return;
    }

    _projectAssignments.putIfAbsent(_selectedProject!, () => {}).add(_selectedRole!);
    _currentAssignments.add(_AssignmentEntry(
      project: _selectedProject!,
      member: _selectedMember!,
      role: _selectedRole!.label,
    ));

    setState(() {
      _selectedMember = null;
      _selectedRole = null;
      _startDate = null;
      _endDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_currentAssignments.last.member} assigned as ${_currentAssignments.last.role}')),
    );
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

import 'package:flutter/material.dart';

import '../../data/positions_data.dart';
import '../../data/team_members_data.dart';

/// Project role: 1 Manager, 1 Team Leader, multiple Team Members.
enum _ProjectRole {
  manager('Manager', '1 per project'),
  teamLeader('Team Leader', '1 per project'),
  teamMember('Team Member', 'Unlimited');

  const _ProjectRole(this.label, this.hint);
  final String label;
  final String hint;
}

/// Add New Project: name, description, technologies, and assign members.
class AddNewProjectPage extends StatefulWidget {
  const AddNewProjectPage({super.key});

  @override
  State<AddNewProjectPage> createState() => _AddNewProjectPageState();
}

class _AddNewProjectPageState extends State<AddNewProjectPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _technologiesController = TextEditingController();
  String? _selectedMember;
  _ProjectRole? _selectedRole;
  String? _selectedPosition;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _sendNotification = true;

  final List<_AssignmentRow> _assignedMembers = [];

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

  List<TeamMemberData> get _membersForSelectedRole {
    if (_selectedRole == null) return [];
    if (_selectedRole == _ProjectRole.manager) return membersByRole(TeamMemberRole.manager);
    if (_selectedPosition == null) return [];
    return membersByPositionAndRole(_selectedPosition!, _selectedRole == _ProjectRole.teamLeader ? TeamMemberRole.teamLeader : TeamMemberRole.teamMember);
  }

  String get _memberHint {
    final list = _membersForSelectedRole;
    if (list.isEmpty) return 'No users with this role';
    return 'Choose from ${list.length} ${_selectedRole!.label}(s)';
  }

  List<_ProjectRole> get _availableRoles {
    final hasManager = _assignedMembers.any((e) => e.role == 'Manager');
    final hasLeader = _assignedMembers.any((e) => e.role == 'Team Leader');
    return _ProjectRole.values.where((r) {
      if (r == _ProjectRole.manager) return !hasManager;
      if (r == _ProjectRole.teamLeader) return !hasLeader;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
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
        title: const Text('Add New Project'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a new project',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter project details, technologies, and assign team members.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                hintText: 'e.g. Mobile App Redesign',
                prefixIcon: const Icon(Icons.folder_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the project goals, scope, and deliverables...',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _technologiesController,
              decoration: InputDecoration(
                labelText: 'Technologies',
                hintText: 'e.g. Flutter, React, Node.js, PostgreSQL',
                prefixIcon: const Icon(Icons.code_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Add Members',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select role first — only users with that role can be assigned. Manager: 1, Team Leader: 1, Team Members: unlimited.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _DropdownField(
              label: 'Role',
              hint: 'Select role first',
              icon: Icons.badge_outlined,
              value: _selectedRole?.label,
              onTap: () => _showRolePicker(context),
            ),
            if (_selectedRole != null && _selectedRole != _ProjectRole.manager) ...[
              const SizedBox(height: 12),
              _DropdownField(
                label: 'Position (Team)',
                hint: 'Select position (Developer, Tester, etc.)',
                icon: Icons.groups_rounded,
                value: _selectedPosition,
                onTap: () => _showPositionPicker(context),
              ),
            ],
            if (_selectedRole != null && (_selectedRole == _ProjectRole.manager || _selectedPosition != null)) ...[
              const SizedBox(height: 12),
              _DropdownField(
                label: 'Team Member',
                hint: _memberHint,
                icon: Icons.person_outline_rounded,
                value: _selectedMember,
                onTap: () => _showMemberPicker(context),
              ),
            ],
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addMember,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add Member'),
              ),
            ),
            if (_assignedMembers.isNotEmpty) ...[
              const SizedBox(height: 20),
              ..._assignedMembers.map((e) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                  title: Text(e.member),
                  subtitle: Text(e.role),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _assignedMembers.remove(e)),
                  ),
                ),
              )),
            ],
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
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Notify assigned users via email & app',
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
                onPressed: _onCreate,
                icon: const Icon(Icons.add_task_rounded, size: 20),
                label: const Text('Create Project'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberPicker(BuildContext context) {
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
    final available = _availableRoles;
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manager and Team Leader already assigned')),
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
              child: Text('Role', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
            ...available.map((r) => ListTile(
              title: Text(r.label),
              subtitle: Text(r.hint, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              onTap: () {
                setState(() => _selectedRole = r);
                Navigator.pop(ctx);
              },
            )),
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
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  void _addMember() {
    if (_selectedMember == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select member and role')),
      );
      return;
    }
    if (!_availableRoles.contains(_selectedRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This role is already assigned')),
      );
      return;
    }
    setState(() {
      _assignedMembers.add(_AssignmentRow(member: _selectedMember!, role: _selectedRole!.label));
      _selectedMember = null;
      _selectedRole = null;
    });
  }

  void _onCreate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter project name')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Project "$name" created')),
    );
    Navigator.of(context).pop();
  }
}

class _AssignmentRow {
  _AssignmentRow({required this.member, required this.role});
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
  const _DateField({required this.label, this.date, required this.onTap});

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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(date != null ? _format(date!) : '', style: TextStyle(color: date != null ? null : Theme.of(context).hintColor)),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({required this.title, required this.options, required this.onSelected});

  final String title;
  final List<String> options;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ...options.map((o) => ListTile(title: Text(o), onTap: () => onSelected(o))),
        ],
      ),
    );
  }
}

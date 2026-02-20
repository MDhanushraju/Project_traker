import 'package:flutter/material.dart';

import '../../../data/mock_data.dart';

/// Shift or remove a team member from one project to another.
/// Available to both Admin and Manager.
class ShiftTeamMemberPage extends StatefulWidget {
  const ShiftTeamMemberPage({super.key});

  @override
  State<ShiftTeamMemberPage> createState() => _ShiftTeamMemberPageState();
}

class _ShiftTeamMemberPageState extends State<ShiftTeamMemberPage> {
  static Map<String, List<String>> _memberProjects = {
    'David Chen': ['API Integration', 'Website Redesign'],
    'Elena Rodriguez': ['Mobile App'],
    'Sophie Walters': ['Mobile App'],
    'Marcus Thorne': ['API Integration'],
    'Maya Patel': ['Website Redesign'],
    'John Doe': ['Website Redesign'],
  };

  String? _selectedMember;
  String? _selectedFromProject;
  String? _selectedToProject;
  String _action = 'shift';
  bool _sendNotification = true;

  List<String> get _members => _memberProjects.keys.toList()..sort();
  List<String> get _projects =>
      MockData.projects.map((p) => p.name ?? '').where((n) => n.isNotEmpty).toList();
  List<String> get _memberCurrentProjects =>
      _selectedMember != null ? (_memberProjects[_selectedMember] ?? []) : [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Shift / Remove Team Member'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Move or remove team member across projects',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a member, choose their current project, then shift to another project or remove.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            _buildDropdown('Team Member', Icons.person_outline_rounded, _selectedMember, _members,
                (v) => setState(() {
                  _selectedMember = v;
                  _selectedFromProject = null;
                  _selectedToProject = null;
                })),
            if (_selectedMember != null) ...[
              const SizedBox(height: 16),
              _buildDropdown('From Project', Icons.folder_outlined, _selectedFromProject,
                  _memberCurrentProjects, (v) => setState(() {
                    _selectedFromProject = v;
                    _selectedToProject = null;
                  })),
            ],
            if (_selectedFromProject != null) ...[
              const SizedBox(height: 20),
              Text('Action',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionChip(
                      label: 'Shift to another',
                      icon: Icons.swap_horiz_rounded,
                      selected: _action == 'shift',
                      onTap: () => setState(() => _action = 'shift'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionChip(
                      label: 'Remove',
                      icon: Icons.person_remove_rounded,
                      selected: _action == 'remove',
                      onTap: () => setState(() {
                        _action = 'remove';
                        _selectedToProject = null;
                      }),
                    ),
                  ),
                ],
              ),
              if (_action == 'shift') ...[
                const SizedBox(height: 16),
                _buildDropdown('To Project', Icons.folder_rounded, _selectedToProject,
                    _projects.where((p) => p != _selectedFromProject).toList(),
                    (v) => setState(() => _selectedToProject = v)),
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
                        Text('Send Notification',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        Text('Notify member about the change',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Switch(
                      value: _sendNotification,
                      onChanged: (v) => setState(() => _sendNotification = v)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _onConfirm,
                  icon: Icon(_action == 'shift' ? Icons.swap_horiz_rounded : Icons.person_remove_rounded, size: 20),
                  label: Text(_action == 'shift'
                      ? 'Shift to ${_selectedToProject ?? "..."}'
                      : 'Remove from $_selectedFromProject'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, IconData icon, String? value, List<String> options,
      void Function(String) onSelected) {
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
                        child: Text(label,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
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
          hintText: 'Select $label',
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(value ?? 'Select $label',
            style: TextStyle(color: value != null ? null : Theme.of(context).hintColor)),
      ),
    );
  }

  void _onConfirm() {
    if (_selectedMember == null || _selectedFromProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select member and from project')));
      return;
    }
    if (_action == 'shift' && _selectedToProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select target project')));
      return;
    }
    setState(() {
      final list = _memberProjects[_selectedMember] ?? [];
      _memberProjects[_selectedMember!] = list.where((p) => p != _selectedFromProject).toList();
      if (_action == 'shift' && _selectedToProject != null) {
        _memberProjects[_selectedMember!]!.add(_selectedToProject!);
      }
    });
    final msg = _action == 'shift'
        ? '$_selectedMember shifted from $_selectedFromProject to $_selectedToProject'
        : '$_selectedMember removed from $_selectedFromProject';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.of(context).pop();
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
          : theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected ? theme.colorScheme.primary : null,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

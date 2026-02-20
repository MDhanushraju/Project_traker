import 'package:flutter/material.dart';

import '../../core/auth/auth_state.dart';
import '../../core/constants/roles.dart';
import '../../data/positions_data.dart';
import '../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';
import 'user_details_page.dart';

enum _UserRole { teamManager, teamLeader, teamMember }

/// Users page: All Managers, then position teams (Developer, Tester, etc.) with Team Leaders + Team Members.
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  static List<_UserItem> _teamManagers = [
    const _UserItem(
      name: 'Sarah Jenkins',
      title: 'Director of Product Operations',
      role: _UserRole.teamManager,
      projects: ['Website Redesign', 'Mobile App'],
      status: 'Active',
    ),
  ];

  static List<_UserItem> _byPosition = [
    const _UserItem(name: 'Marcus Thorne', title: 'Tech Lead', role: _UserRole.teamLeader, position: 'Developer', projects: ['API Integration'], status: 'Active'),
    const _UserItem(name: 'Elena Vance', title: 'Design Lead', role: _UserRole.teamLeader, position: 'Designer', projects: ['Mobile App Redesign'], status: 'Active'),
    const _UserItem(name: 'David Chen', title: 'Lead Developer', role: _UserRole.teamMember, position: 'Developer', projects: ['API Integration', 'Website Redesign'], status: 'Active'),
    const _UserItem(name: 'Sophie Walters', title: 'QA Engineer', role: _UserRole.teamMember, position: 'Tester', projects: ['Mobile App'], status: 'Active'),
    const _UserItem(name: 'James Wilson', title: 'Backend Architect', role: _UserRole.teamMember, position: 'Developer', projects: [], status: 'On Leave'),
    const _UserItem(name: 'Maya Patel', title: 'Content Strategist', role: _UserRole.teamMember, position: 'Analyst', projects: ['Website Redesign'], status: 'Active'),
    const _UserItem(name: 'Elena Rodriguez', title: 'Senior UI Designer', role: _UserRole.teamMember, position: 'Designer', projects: ['Mobile App Redesign'], status: 'Active'),
    const _UserItem(name: 'John Doe', title: 'Developer', role: _UserRole.teamMember, position: 'Developer', projects: [], status: 'Active'),
    const _UserItem(name: 'Mike Chen', title: 'Designer', role: _UserRole.teamMember, position: 'Designer', projects: [], status: 'Active'),
    const _UserItem(name: 'Sarah Kim', title: 'Analyst', role: _UserRole.teamMember, position: 'Analyst', projects: [], status: 'Active', isTemporary: true),
  ];

  @override
  void initState() {
    super.initState();
    PositionsData.instance.addListener(_onPositionsChanged);
  }

  @override
  void dispose() {
    PositionsData.instance.removeListener(_onPositionsChanged);
    super.dispose();
  }

  void _onPositionsChanged() => setState(() {});

  List<_UserItem> _leadersFor(String position) =>
      _byPosition.where((u) => u.role == _UserRole.teamLeader && u.position == position).toList();
  List<_UserItem> _membersFor(String position) =>
      _byPosition.where((u) => u.role == _UserRole.teamMember && u.position == position).toList();

  Set<String> get _usedPositions =>
      _byPosition.map((u) => u.position).whereType<String>().toSet();

  String _roleLabel(_UserRole r) {
    switch (r) {
      case _UserRole.teamManager:
        return 'Team Manager';
      case _UserRole.teamLeader:
        return 'Team Leader';
      case _UserRole.teamMember:
        return 'Team Member';
    }
  }

  void _openAddMember(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddMemberSheet(
        positions: PositionsData.instance.positions,
        onAdd: (name, email, role, position, isTemporary) {
          final item = _UserItem(
            name: name,
            title: email,
            role: role,
            position: position,
            projects: [],
            status: 'Active',
            isTemporary: isTemporary,
          );
          setState(() {
            if (role == _UserRole.teamManager) {
              _teamManagers = [..._teamManagers, item];
            } else {
              _byPosition = [..._byPosition, item];
            }
          });
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name added')),
          );
        },
      ),
    );
  }

  void _openCreatePosition(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Position'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Position name',
            hintText: 'e.g. DevOps, Data Analyst',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              PositionsData.instance.addPosition(controller.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Position "${controller.text}" added')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, _UserItem user) {
    Navigator.of(context).pushNamed(
      AppRoutes.userDetails,
      arguments: UserDetailsArgs(
        name: user.name,
        title: user.title,
        role: user.position != null ? '${user.position} · ${_roleLabel(user.role)}' : _roleLabel(user.role),
        projects: user.projects,
        status: user.status,
        isTemporary: user.isTemporary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = AuthState.instance.currentUser?.role == AppRole.admin;
    final positions = PositionsData.instance.positions;
    final usedPositions = _usedPositions;
    final allPositions = {...positions, ...usedPositions}.toList()..sort();

    return MainLayout(
      title: 'Users',
      currentRoute: AppRoutes.users,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Users', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OutlinedButton.icon(
                        onPressed: () => _openCreatePosition(context),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Create Position'),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: () => _openAddMember(context),
                    icon: const Icon(Icons.person_add_rounded, size: 20),
                    label: const Text('Add Member'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'All Managers', count: _teamManagers.length, icon: Icons.badge_rounded, theme: theme),
          const SizedBox(height: 12),
          ..._teamManagers.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u))),
          ...allPositions.map((pos) {
            final leaders = _leadersFor(pos);
            final members = _membersFor(pos);
            if (leaders.isEmpty && members.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                _SectionHeader(title: '$pos Team', count: leaders.length + members.length, icon: Icons.groups_rounded, theme: theme),
                const SizedBox(height: 8),
                if (leaders.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('Team Leaders (${leaders.length})', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                  ),
                  ...leaders.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u))),
                  const SizedBox(height: 8),
                ],
                if (members.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('Team Members (${members.length})', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                  ),
                  ...members.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u))),
                ],
              ],
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _UserItem {
  const _UserItem({
    required this.name,
    required this.title,
    required this.role,
    this.position,
    this.projects = const [],
    this.status = 'Active',
    this.isTemporary = false,
  });

  final String name;
  final String title;
  final _UserRole role;
  final String? position;
  final List<String> projects;
  final String status;
  final bool isTemporary;
}

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet({
    required this.positions,
    required this.onAdd,
  });

  final List<String> positions;
  final void Function(String name, String email, _UserRole role, String? position, bool isTemporary) onAdd;

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  _UserRole _selectedRole = _UserRole.teamMember;
  String? _selectedPosition;
  bool _isTemporary = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Member', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Choose role and position (Developer, Tester, etc.).',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', hintText: 'Enter name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', hintText: 'email@example.com', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Text('Role', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Team Manager'),
                  selected: _selectedRole == _UserRole.teamManager,
                  onSelected: (_) => setState(() { _selectedRole = _UserRole.teamManager; _selectedPosition = null; }),
                ),
                ChoiceChip(
                  label: const Text('Team Leader'),
                  selected: _selectedRole == _UserRole.teamLeader,
                  onSelected: (_) => setState(() { _selectedRole = _UserRole.teamLeader; _selectedPosition = _selectedPosition ?? widget.positions.firstOrNull; }),
                ),
                ChoiceChip(
                  label: const Text('Team Member'),
                  selected: _selectedRole == _UserRole.teamMember,
                  onSelected: (_) => setState(() { _selectedRole = _UserRole.teamMember; _selectedPosition = _selectedPosition ?? widget.positions.firstOrNull; }),
                ),
              ],
            ),
            if (_selectedRole != _UserRole.teamManager && widget.positions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Position', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPosition ?? widget.positions.first,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: widget.positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _selectedPosition = v),
              ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Temporary position'),
              subtitle: Text('Mark this role as temporary', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              value: _isTemporary,
              onChanged: (v) => setState(() => _isTemporary = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                final name = _nameController.text.trim();
                final email = _emailController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter name')));
                  return;
                }
                if (_selectedRole != _UserRole.teamManager && (_selectedPosition == null || _selectedPosition!.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a position')));
                  return;
                }
                widget.onAdd(name, email.isNotEmpty ? email : name, _selectedRole, _selectedPosition, _isTemporary);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count, required this.icon, required this.theme});

  final String title;
  final int count;
  final IconData icon;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text('$title ($count)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.theme, required this.onDetails});

  final _UserItem user;
  final ThemeData theme;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(user.name.split(' ').map((w) => w[0]).take(2).join(), style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
        ),
        title: Text(user.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          user.isTemporary ? '${user.title} (Temporary)' : user.title,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(onPressed: onDetails, child: const Text('Details')),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message ${user.name}'))),
              icon: const Icon(Icons.message_rounded, size: 18),
              label: const Text('Message'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            ),
          ],
        ),
      ),
    );
  }
}

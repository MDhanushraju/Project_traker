import 'package:flutter/material.dart';

import '../../core/auth/auth_state.dart';
import '../../core/constants/roles.dart';
import '../../data/data_provider.dart';
import '../../data/positions_data.dart';
import '../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';
import 'user_details_page.dart';

enum _UserRole { admin, teamManager, teamLeader, teamMember }

/// Users page: All Managers, then position teams (Developer, Tester, etc.) with Team Leaders + Team Members.
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<_UserItem> _admins = [];
  List<_UserItem> _teamManagers = [];
  List<_UserItem> _byPosition = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    PositionsData.instance.addListener(_onPositionsChanged);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await DataProvider.instance.getAllUsers();
      final managers = <_UserItem>[];
      final byPos = <_UserItem>[];
      final admins = <_UserItem>[];
      for (final u in users) {
        final id = (u['id'] is int) ? u['id'] as int : int.tryParse((u['id'] ?? '').toString()) ?? 0;
        final name = (u['name'] ?? u['fullName'] ?? '').toString();
        final title = (u['title'] ?? '').toString();
        final roleStr = (u['role'] ?? '').toString().toLowerCase();
        final position = (u['position'] as String?)?.toString();
        final isTemp = u['temporary'] == true;
        if (roleStr == 'admin') {
          admins.add(_UserItem(id: id, name: name, title: title, role: _UserRole.admin, status: 'Active'));
        } else if (roleStr == 'manager') {
          managers.add(_UserItem(id: id, name: name, title: title, role: _UserRole.teamManager, status: 'Active'));
        } else if (roleStr == 'team_leader') {
          byPos.add(_UserItem(id: id, name: name, title: title, role: _UserRole.teamLeader, position: position, status: 'Active'));
        } else {
          byPos.add(_UserItem(id: id, name: name, title: title, role: _UserRole.teamMember, position: position, status: 'Active', isTemporary: isTemp));
        }
      }
      if (mounted) {
        setState(() {
          _admins = admins;
          _teamManagers = managers;
          _byPosition = byPos;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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

  /// Team leaders/members with no position (e.g. from signup).
  List<_UserItem> get _noPositionLeaders =>
      _byPosition.where((u) => u.role == _UserRole.teamLeader && (u.position == null || u.position!.isEmpty)).toList();
  List<_UserItem> get _noPositionMembers =>
      _byPosition.where((u) => u.role == _UserRole.teamMember && (u.position == null || u.position!.isEmpty)).toList();

  Set<String> get _usedPositions =>
      _byPosition.map((u) => u.position).whereType<String>().toSet();

  String _roleLabel(_UserRole r) {
    switch (r) {
      case _UserRole.admin:
        return 'Admin';
      case _UserRole.teamManager:
        return 'Team Manager';
      case _UserRole.teamLeader:
        return 'Team Leader';
      case _UserRole.teamMember:
        return 'Team Member';
    }
  }

  void _openAddMember(BuildContext context) {
    final isAdmin = AuthState.instance.currentUser?.role == AppRole.admin;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddMemberSheet(
        positions: PositionsData.instance.positions,
        isAdmin: isAdmin,
        onAdd: (name, email, password, role, position, isTemporary) async {
          final roleStr = _roleToApi(role);
          final created = await DataProvider.instance.createUser(
            fullName: name,
            email: email,
            password: password?.trim().isEmpty ?? true ? null : password,
            role: roleStr,
            position: position,
            temporary: isTemporary,
          );
          if (!mounted) return;
          Navigator.pop(ctx);
          if (created != null) {
            await _loadUsers();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name added successfully')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add user. Email may already exist.')),
            );
          }
        },
      ),
    );
  }

  void _openAssignRole(BuildContext context, _UserItem user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AssignRoleSheet(
        user: user,
        positions: PositionsData.instance.positions,
        onAssign: (role, position) async {
          final roleStr = _roleToApi(role);
          final updated = await DataProvider.instance.assignRole(
            user.id,
            role: roleStr,
            position: position,
          );
          if (!mounted) return;
          Navigator.pop(ctx);
          if (updated != null) {
            await _loadUsers();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Role updated for ${user.name}')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update role')),
            );
          }
        },
      ),
    );
  }

  String _roleToApi(_UserRole r) {
    switch (r) {
      case _UserRole.admin:
        return 'admin';
      case _UserRole.teamManager:
        return 'manager';
      case _UserRole.teamLeader:
        return 'team_leader';
      case _UserRole.teamMember:
        return 'member';
    }
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
    if (_loading) {
      return MainLayout(
        title: 'Users',
        currentRoute: AppRoutes.users,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading users...'),
            ],
          ),
        ),
      );
    }
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
          if (_admins.isNotEmpty) ...[
            _SectionHeader(title: 'Admins', count: _admins.length, icon: Icons.admin_panel_settings_rounded, theme: theme),
            const SizedBox(height: 12),
            ..._admins.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u))),
            const SizedBox(height: 28),
          ],
          _SectionHeader(title: 'All Managers', count: _teamManagers.length, icon: Icons.badge_rounded, theme: theme),
          const SizedBox(height: 12),
          ..._teamManagers.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u))),
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
                  ...leaders.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u))),
                  const SizedBox(height: 8),
                ],
                if (members.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('Team Members (${members.length})', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                  ),
                  ...members.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u))),
                ],
              ],
            );
          }),
          if (_noPositionLeaders.isNotEmpty || _noPositionMembers.isNotEmpty) ...[
            const SizedBox(height: 28),
            _SectionHeader(
              title: 'Other (no position)',
              count: _noPositionLeaders.length + _noPositionMembers.length,
              icon: Icons.person_outline_rounded,
              theme: theme,
            ),
            const SizedBox(height: 8),
            if (_noPositionLeaders.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text('Team Leaders (${_noPositionLeaders.length})', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
              ),
              ..._noPositionLeaders.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u))),
              const SizedBox(height: 8),
            ],
            if (_noPositionMembers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text('Team Members (${_noPositionMembers.length})', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
              ),
              ..._noPositionMembers.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u))),
            ],
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _UserItem {
  const _UserItem({
    required this.id,
    required this.name,
    required this.title,
    required this.role,
    this.position,
    this.projects = const [],
    this.status = 'Active',
    this.isTemporary = false,
  });

  final int id;
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
    required this.isAdmin,
  });

  final List<String> positions;
  final Future<void> Function(String name, String email, String? password, _UserRole role, String? position, bool isTemporary) onAdd;
  final bool isAdmin;

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  _UserRole _selectedRole = _UserRole.teamMember;
  String? _selectedPosition;
  bool _isTemporary = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (optional)',
                hintText: 'Leave blank for default Welcome@1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('Role', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (widget.isAdmin)
                  ChoiceChip(
                    label: const Text('Admin'),
                    selected: _selectedRole == _UserRole.admin,
                    onSelected: (_) => setState(() { _selectedRole = _UserRole.admin; _selectedPosition = null; }),
                  ),
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
              onPressed: _isLoading ? null : () async {
                final name = _nameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text;
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter name')));
                  return;
                }
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter email')));
                  return;
                }
                if (_selectedRole != _UserRole.admin && _selectedRole != _UserRole.teamManager && (_selectedPosition == null || _selectedPosition!.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a position')));
                  return;
                }
                setState(() => _isLoading = true);
                await widget.onAdd(name, email, password.isEmpty ? null : password, _selectedRole, _selectedPosition, _isTemporary);
                if (mounted) setState(() => _isLoading = false);
              },
              child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignRoleSheet extends StatefulWidget {
  const _AssignRoleSheet({
    required this.user,
    required this.positions,
    required this.onAssign,
  });

  final _UserItem user;
  final List<String> positions;
  final Future<void> Function(_UserRole role, String? position) onAssign;

  @override
  State<_AssignRoleSheet> createState() => _AssignRoleSheetState();
}

class _AssignRoleSheetState extends State<_AssignRoleSheet> {
  _UserRole _selectedRole = _UserRole.teamMember;
  String? _selectedPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    _selectedPosition = widget.user.position;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = AuthState.instance.currentUser?.role == AppRole.admin;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Assign Role', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Update role for ${widget.user.name}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            Text('Role', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (isAdmin)
                  ChoiceChip(
                    label: const Text('Admin'),
                    selected: _selectedRole == _UserRole.admin,
                    onSelected: (_) => setState(() { _selectedRole = _UserRole.admin; _selectedPosition = null; }),
                  ),
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
            if (_selectedRole != _UserRole.admin && _selectedRole != _UserRole.teamManager && widget.positions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Position', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPosition ?? widget.positions.firstOrNull ?? widget.positions.first,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: widget.positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _selectedPosition = v),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : () async {
                if (_selectedRole != _UserRole.admin && _selectedRole != _UserRole.teamManager && (_selectedPosition == null || _selectedPosition!.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a position')));
                  return;
                }
                setState(() => _isLoading = true);
                await widget.onAssign(_selectedRole, _selectedPosition);
                if (mounted) setState(() => _isLoading = false);
              },
              child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Assign Role'),
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
  const _UserCard({required this.user, required this.theme, required this.onDetails, required this.onAssignRole});

  final _UserItem user;
  final ThemeData theme;
  final VoidCallback onDetails;
  final VoidCallback onAssignRole;

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
            OutlinedButton.icon(
              onPressed: onAssignRole,
              icon: const Icon(Icons.badge_rounded, size: 18),
              label: const Text('Assign Role'),
            ),
            const SizedBox(width: 8),
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

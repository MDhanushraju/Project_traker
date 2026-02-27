import 'package:flutter/material.dart';

import '../../core/auth/auth_state.dart';
import '../../core/constants/roles.dart';
import '../../data/data_provider.dart';
import '../../data/mock_data.dart';
import '../../data/positions_data.dart';
import '../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';
import 'user_details_page.dart' show UserDetailsArgs, showPromoteDemoteSheet;

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
  String? _loadError;
  int? _backendUserCount;

  @override
  void initState() {
    super.initState();
    PositionsData.instance.addListener(_onPositionsChanged);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final List<Map<String, dynamic>> users = await DataProvider.instance.getAllUsers();
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
        final email = (u['email'] ?? '').toString();
        final loginId = u['loginId'] is int ? u['loginId'] as int? : int.tryParse((u['loginId'] ?? '').toString());
        final photoUrl = (u['photoUrl'] ?? '').toString();
        final currentProject = (u['currentProject'] ?? '').toString();
        final projectsCompleted = u['projectsCompletedCount'] is int ? u['projectsCompletedCount'] as int? : int.tryParse((u['projectsCompletedCount'] ?? '').toString());
        final managerName = (u['managerName'] ?? '').toString();
        final teamLeaderName = (u['teamLeaderName'] ?? '').toString();
        final item = _UserItem(
          id: id,
          name: name,
          title: title,
          role: roleStr == 'admin' ? _UserRole.admin : roleStr == 'manager' ? _UserRole.teamManager : roleStr == 'team_leader' ? _UserRole.teamLeader : _UserRole.teamMember,
          position: position,
          status: 'Active',
          isTemporary: isTemp,
          email: email.isEmpty ? null : email,
          loginId: loginId,
          photoUrl: photoUrl.isEmpty ? null : photoUrl,
          currentProject: currentProject.isEmpty ? null : currentProject,
          projectsCompletedCount: projectsCompleted ?? 0,
          managerName: managerName.isEmpty ? null : managerName,
          teamLeaderName: teamLeaderName.isEmpty ? null : teamLeaderName,
        );
        if (roleStr == 'admin') admins.add(item);
        else if (roleStr == 'manager') managers.add(item);
        else if (roleStr == 'team_leader') byPos.add(item);
        else byPos.add(item);
      }
      if (mounted) {
        setState(() {
          _admins = admins;
          _teamManagers = managers;
          _byPosition = byPos;
          _loading = false;
          _loadError = null;
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '').split('\n').first.trim();
        });
      }
      debugPrint('Users load error: $e\n$st');
    }
  }

  Future<void> _checkBackendCount() async {
    final count = await DataProvider.instance.getUserCount();
    if (mounted) setState(() => _backendUserCount = count);
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

  void _openPromote(BuildContext context, _UserItem user) {
    _showPermanentTemporaryChoice(context, isPromote: true).then((temporary) {
      if (temporary == null || !mounted) return;
      showPromoteDemoteSheet(context, user.id, _roleToApi(user.role), user.name, true, initialTemporary: temporary)
          .then((ok) {
        if (ok == true && mounted) _loadUsers();
      });
    });
  }

  void _openDemote(BuildContext context, _UserItem user) {
    _showPermanentTemporaryChoice(context, isPromote: false).then((temporary) {
      if (temporary == null || !mounted) return;
      showPromoteDemoteSheet(context, user.id, _roleToApi(user.role), user.name, false, initialTemporary: temporary)
          .then((ok) {
        if (ok == true && mounted) _loadUsers();
      });
    });
  }

  /// After tapping Promotion or Demotion: choose Permanent or Temporary. Returns false = permanent, true = temporary, null = cancelled.
  Future<bool?> _showPermanentTemporaryChoice(BuildContext context, {required bool isPromote}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isPromote ? 'Promotion' : 'Demotion'),
        content: const Text('Choose Permanent or Temporary for this role change.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx, false),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: const Text('Permanent'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.schedule_rounded, size: 20),
            label: const Text('Temporary'),
          ),
        ],
      ),
    );
  }

  Future<void> _onKick(BuildContext context, _UserItem user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kick user'),
        content: Text('Remove ${user.name} from the system? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kick')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final (ok, errorMsg) = await DataProvider.instance.kickUserWithMessage(user.id);
    if (mounted) {
      if (ok) {
        _loadUsers();
        await MockData.refreshFromApi();
        if (mounted) setState(() {});
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user.name} has been removed')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMsg?.isNotEmpty == true ? errorMsg! : 'Failed to kick user'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ));
      }
    }
  }

  void _openDetails(BuildContext context, _UserItem user) {
    Navigator.of(context).pushNamed(
      AppRoutes.userDetails,
      arguments: UserDetailsArgs(
        userId: user.id,
        name: user.name,
        title: user.title,
        role: user.position != null ? '${user.position} · ${_roleLabel(user.role)}' : _roleLabel(user.role),
        roleApi: _roleToApi(user.role),
        projects: user.projects,
        status: user.status,
        isTemporary: user.isTemporary,
        email: user.email,
        loginId: user.loginId,
        photoUrl: user.photoUrl,
        currentProject: user.currentProject,
        projectsCompletedCount: user.projectsCompletedCount,
        managerName: user.managerName,
        teamLeaderName: user.teamLeaderName,
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
    final hasNoUsers = _admins.isEmpty && _teamManagers.isEmpty && _byPosition.isEmpty;

    return MainLayout(
      title: 'Users',
      currentRoute: AppRoutes.users,
      child: hasNoUsers
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Users', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    FilledButton.icon(
                      onPressed: () => _openAddMember(context),
                      icon: const Icon(Icons.person_add_rounded, size: 20),
                      label: const Text('Add Member'),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No users yet',
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        if (_loadError != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _loadError!,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        if (_backendUserCount != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Database has $_backendUserCount user${_backendUserCount == 1 ? '' : 's'}. List failed to load.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Backend must be running on http://localhost:8080. Add a member or tap Retry.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: _loadUsers,
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              label: const Text('Retry'),
                            ),
                            if (_backendUserCount == null) ...[
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await _checkBackendCount();
                                },
                                icon: const Icon(Icons.storage_rounded, size: 18),
                                label: const Text('Check DB count'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView(
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
            ..._admins.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u), isAdminViewer: isAdmin, isManagerViewer: AuthState.instance.currentUser?.role == AppRole.manager, onKick: () => _onKick(context, u), onPromote: () => _openPromote(context, u), onDemote: () => _openDemote(context, u))),
            const SizedBox(height: 28),
          ],
          _SectionHeader(title: 'All Managers', count: _teamManagers.length, icon: Icons.badge_rounded, theme: theme),
          const SizedBox(height: 12),
          ..._teamManagers.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u), isAdminViewer: isAdmin, isManagerViewer: AuthState.instance.currentUser?.role == AppRole.manager, onKick: () => _onKick(context, u), onPromote: () => _openPromote(context, u), onDemote: () => _openDemote(context, u))),
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
                  ...leaders.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u), isAdminViewer: isAdmin, isManagerViewer: AuthState.instance.currentUser?.role == AppRole.manager, onKick: () => _onKick(context, u), onPromote: () => _openPromote(context, u), onDemote: () => _openDemote(context, u))),
                  const SizedBox(height: 8),
                ],
                if (members.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('Team Members (${members.length})', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                  ),
                  ...members.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u), isAdminViewer: isAdmin, isManagerViewer: AuthState.instance.currentUser?.role == AppRole.manager, onKick: () => _onKick(context, u), onPromote: () => _openPromote(context, u), onDemote: () => _openDemote(context, u))),
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
              ..._noPositionLeaders.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u), isAdminViewer: isAdmin, isManagerViewer: AuthState.instance.currentUser?.role == AppRole.manager, onKick: () => _onKick(context, u), onPromote: () => _openPromote(context, u), onDemote: () => _openDemote(context, u))),
              const SizedBox(height: 8),
            ],
            if (_noPositionMembers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text('Team Members (${_noPositionMembers.length})', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
              ),
              ..._noPositionMembers.map((u) => _UserCard(user: u, theme: theme, onDetails: () => _openDetails(context, u), onAssignRole: () => _openAssignRole(context, u), isAdminViewer: isAdmin, isManagerViewer: AuthState.instance.currentUser?.role == AppRole.manager, onKick: () => _onKick(context, u), onPromote: () => _openPromote(context, u), onDemote: () => _openDemote(context, u))),
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
    this.email,
    this.loginId,
    this.photoUrl,
    this.currentProject,
    this.projectsCompletedCount = 0,
    this.managerName,
    this.teamLeaderName,
  });

  final int id;
  final String name;
  final String title;
  final _UserRole role;
  final String? position;
  final List<String> projects;
  final String status;
  final bool isTemporary;
  final String? email;
  final int? loginId;
  final String? photoUrl;
  final String? currentProject;
  final int projectsCompletedCount;
  final String? managerName;
  final String? teamLeaderName;
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

enum _UserCardAction { message, details, kick, promote, demote }

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.theme,
    required this.onDetails,
    required this.onAssignRole,
    this.isAdminViewer = false,
    this.isManagerViewer = false,
    this.onKick,
    this.onPromote,
    this.onDemote,
  });

  final _UserItem user;
  final ThemeData theme;
  final VoidCallback onDetails;
  final VoidCallback onAssignRole;
  final bool isAdminViewer;
  final bool isManagerViewer;
  final VoidCallback? onKick;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;

  /// Kick: only Admin and Manager. Admin can kick non-admins; Manager can kick Team Leader or Team Member.
  bool get _canKick =>
      onKick != null &&
      ((isAdminViewer && user.role != _UserRole.admin) ||
          (isManagerViewer && (user.role == _UserRole.teamLeader || user.role == _UserRole.teamMember)));

  /// Promotion and Demotion (with Permanent/Temporary): only Admin and Manager see them. Not shown for Admin users (head cannot be promoted/demoted).
  bool get _showPD =>
      (isAdminViewer || isManagerViewer) &&
      user.role != _UserRole.admin &&
      onPromote != null &&
      onDemote != null;

  @override
  Widget build(BuildContext context) {
    final roleLabel = user.role == _UserRole.admin ? 'Admin' : user.role == _UserRole.teamManager ? 'Manager' : user.role == _UserRole.teamLeader ? 'Team Leader' : 'Team Member';
    final idLine = user.loginId != null ? 'ID: ${user.loginId}' : '';
    final emailLine = user.email != null && user.email!.isNotEmpty ? user.email! : '';
    final subtitle = [if (roleLabel.isNotEmpty) roleLabel, if (idLine.isNotEmpty) idLine, if (emailLine.isNotEmpty) emailLine].join(' · ');
    final items = <PopupMenuEntry<_UserCardAction>>[
      const PopupMenuItem(value: _UserCardAction.message, child: ListTile(leading: Icon(Icons.message_rounded, size: 20), title: Text('Message'), dense: true)),
      const PopupMenuItem(value: _UserCardAction.details, child: ListTile(leading: Icon(Icons.person_rounded, size: 20), title: Text('Details'), dense: true)),
      if (_canKick) const PopupMenuItem(value: _UserCardAction.kick, child: ListTile(leading: Icon(Icons.person_remove_rounded, size: 20), title: Text('Kick'), dense: true)),
      if (_showPD) const PopupMenuItem(value: _UserCardAction.promote, child: ListTile(leading: Icon(Icons.arrow_upward_rounded, size: 20), title: Text('Promotion'), dense: true)),
      if (_showPD) const PopupMenuItem(value: _UserCardAction.demote, child: ListTile(leading: Icon(Icons.arrow_downward_rounded, size: 20), title: Text('Demotion'), dense: true)),
    ];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null || user.photoUrl!.isEmpty
              ? Text(user.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase(), style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600, fontSize: 14))
              : null,
        ),
        title: Text(user.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle.isEmpty ? (user.isTemporary ? 'Temporary' : user.title) : subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<_UserCardAction>(
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: 'Actions',
              itemBuilder: (_) => items,
              onSelected: (action) {
                switch (action) {
                  case _UserCardAction.message:
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message ${user.name}')));
                    break;
                  case _UserCardAction.details:
                    onDetails();
                    break;
                  case _UserCardAction.kick:
                    onKick?.call();
                    break;
                  case _UserCardAction.promote:
                    onPromote?.call();
                    break;
                  case _UserCardAction.demote:
                    onDemote?.call();
                    break;
                }
              },
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: onDetails, child: const Text('Details')),
          ],
        ),
      ),
    );
  }
}

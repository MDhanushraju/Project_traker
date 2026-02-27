import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/auth/auth_state.dart';
import '../../core/constants/roles.dart';
import '../../data/data_provider.dart';
import '../../data/positions_data.dart';

/// Arguments for navigating to [UserDetailsPage].
class UserDetailsArgs {
  const UserDetailsArgs({
    this.userId,
    required this.name,
    required this.title,
    required this.role,
    this.roleApi,
    this.projects = const [],
    this.status = 'Active',
    this.isTemporary = false,
    this.email,
    this.loginId,
    this.photoUrl,
    this.currentProject,
    this.projectsCompletedCount = 0,
    this.age,
    this.skills,
    this.managerName,
    this.teamLeaderName,
  });

  final int? userId;
  final String name;
  final String title;
  final String role;
  final String? roleApi;
  final List<String> projects;
  final String status;
  final bool isTemporary;
  final String? email;
  final int? loginId;
  final String? photoUrl;
  final String? currentProject;
  final int projectsCompletedCount;
  final int? age;
  final String? skills;
  final String? managerName;
  final String? teamLeaderName;
}

/// User details page: photo, name, role, ID, email, age, skills, current project, projects completed; Manager/Team leader; Message; Promote/Demote.
class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({
    super.key,
    this.userId,
    required this.name,
    required this.title,
    required this.role,
    this.roleApi,
    this.projects = const [],
    this.status = 'Active',
    this.isTemporary = false,
    this.email,
    this.loginId,
    this.photoUrl,
    this.currentProject,
    this.projectsCompletedCount = 0,
    this.age,
    this.skills,
    this.managerName,
    this.teamLeaderName,
  });

  final int? userId;
  final String name;
  final String title;
  final String role;
  final String? roleApi;
  final List<String> projects;
  final String status;
  final bool isTemporary;
  final String? email;
  final int? loginId;
  final String? photoUrl;
  final String? currentProject;
  final int projectsCompletedCount;
  final int? age;
  final String? skills;
  final String? managerName;
  final String? teamLeaderName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('User Details'),
        centerTitle: true,
          actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              final isAdmin = AuthState.instance.currentUser?.role == AppRole.admin;
              final isManager = AuthState.instance.currentUser?.role == AppRole.manager;
              final isAdminOrManager = isAdmin || isManager;
              showModalBottomSheet(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_rounded),
                        title: const Text('Edit'),
                        onTap: () => Navigator.pop(ctx),
                      ),
                      ListTile(
                        leading: const Icon(Icons.message_rounded),
                        title: const Text('Message'),
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Message $name')),
                          );
                        },
                      ),
                      if (isAdminOrManager) ...[
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.assignment_rounded, color: theme.colorScheme.primary),
                          title: const Text('Assign Task'),
                          subtitle: const Text('Assign a task to this user'),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.of(context).pushNamed(AppRoutes.assignTask);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.swap_horiz_rounded, color: theme.colorScheme.primary),
                          title: const Text('Shift Project'),
                          subtitle: const Text('Move or remove from project'),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.of(context).pushNamed(AppRoutes.shiftTeamMember);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary),
                          title: const Text('Assign to project'),
                          subtitle: const Text('Add this user to a project (new joiner)'),
                          onTap: () {
                            Navigator.pop(ctx);
                            if (userId != null) _showAssignProjectSheet(context, userId!, name);
                          },
                        ),
                      ],
                      if (isAdmin || isManager) ...[
                        const Divider(),
                        if ((isAdmin && roleApi != null && roleApi != 'admin') || (isManager && roleApi != null && (roleApi == 'team_leader' || roleApi == 'member'))) ...[
                          ListTile(
                            leading: Icon(Icons.person_remove_rounded, color: theme.colorScheme.error),
                            title: const Text('Kick'),
                            subtitle: const Text('Remove user from the system'),
                            onTap: () {
                              Navigator.pop(ctx);
                              if (userId != null) _showKickConfirm(context, userId!, name);
                            },
                          ),
                        ],
                        if (isAdmin)
                          ListTile(
                            leading: Icon(Icons.schedule_rounded, color: theme.colorScheme.primary),
                            title: Text(isTemporary ? 'Remove temporary' : 'Set temporary position'),
                            subtitle: Text(isTemporary ? 'Make role permanent' : 'Mark role as temporary'),
                            onTap: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(isTemporary ? 'Made permanent' : 'Set as temporary')),
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: photoUrl != null && photoUrl!.isNotEmpty ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null || photoUrl!.isEmpty
                      ? Text(
                          name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase(),
                          style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 32, fontWeight: FontWeight.w600),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (loginId != null) Text('ID: $loginId', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                if (email != null && email!.isNotEmpty) Text(email!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                      child: Text(role, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
                    ),
                    if (isTemporary)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('Temporary', style: theme.textTheme.labelMedium?.copyWith(color: Colors.orange.shade800, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if ((managerName != null && managerName!.isNotEmpty) || (teamLeaderName != null && teamLeaderName!.isNotEmpty)) ...[
            _sectionLabel(theme, 'REPORTING'),
            const SizedBox(height: 8),
            if (managerName != null && managerName!.isNotEmpty) _detailCard(theme, 'Manager', managerName!),
            if (teamLeaderName != null && teamLeaderName!.isNotEmpty) _detailCard(theme, 'Team Leader', teamLeaderName!),
            const SizedBox(height: 24),
          ],
          _sectionLabel(theme, 'DETAILS'),
          const SizedBox(height: 8),
          _detailCard(theme, 'Age', age != null ? age.toString() : '—'),
          _detailCard(theme, 'Skills', skills != null && skills!.isNotEmpty ? skills! : '—'),
          _detailCard(theme, 'Current project', currentProject != null && currentProject!.isNotEmpty ? currentProject! : '—'),
          _detailCard(theme, 'Projects completed', projectsCompletedCount.toString()),
          const SizedBox(height: 24),
          _sectionLabel(theme, 'PROJECTS'),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No projects assigned',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...projects.map((p) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.folder_rounded, color: theme.colorScheme.primary),
                title: Text(p),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            )),
          const SizedBox(height: 24),
          _sectionLabel(theme, 'STATUS'),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: status.toLowerCase().contains('active')
                          ? Colors.green
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    status,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Message $name')),
                    );
                  },
                  icon: const Icon(Icons.message_rounded, size: 20),
                  label: const Text('Message'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _detailCard(ThemeData theme, String label, String value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500))),
            Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

void _showKickConfirm(BuildContext context, int userId, String userName) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Kick user'),
      content: Text('Remove $userName from the system? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final (ok, errorMsg) = await DataProvider.instance.kickUserWithMessage(userId);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? '$userName has been removed' : (errorMsg?.isNotEmpty == true ? errorMsg! : 'Failed to kick user')),
                  backgroundColor: ok ? null : Theme.of(context).colorScheme.errorContainer,
                ),
              );
            }
          },
          child: const Text('Kick'),
        ),
      ],
    ),
  );
}

Future<bool?> showPromoteDemoteSheet(BuildContext context, int userId, String? currentRoleApi, String userName, bool isPromote, {bool? initialTemporary}) {
  final current = (currentRoleApi ?? 'member').toLowerCase().replaceAll(' ', '_');
  final positions = PositionsData.instance.positions;
  final isAdmin = AuthState.instance.currentUser?.role == AppRole.admin;

  List<MapEntry<String, String>> options = [];
  if (isPromote) {
    if (current == 'member') options = [MapEntry('team_leader', 'Team Leader'), MapEntry('manager', 'Manager')];
    else if (current == 'team_leader') options = [MapEntry('manager', 'Manager')];
    else if (current == 'manager' && isAdmin) options = [MapEntry('admin', 'Admin')];
  } else {
    if (current == 'manager') options = [MapEntry('team_leader', 'Team Leader'), MapEntry('member', 'Team Member')];
    else if (current == 'team_leader') options = [MapEntry('member', 'Team Member')];
    else if (current == 'admin') options = [MapEntry('manager', 'Manager')];
  }

  if (options.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isPromote ? 'No higher role available' : 'No lower role available')));
    return Future.value(null);
  }

  String? selectedRoleApi;
  String? selectedPosition;
  bool temporaryPosition = initialTemporary ?? false;

  return showModalBottomSheet<bool?>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(isPromote ? 'P/D' : 'Demote', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Change role for $userName', style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  ...options.map((e) => ListTile(
                    title: Text(e.value),
                    onTap: () {
                      selectedRoleApi = e.key;
                      if (e.key == 'team_leader' || e.key == 'member') {
                        selectedPosition = positions.isNotEmpty ? positions.first : null;
                      } else {
                        selectedPosition = null;
                      }
                      setState(() {});
                    },
                    selected: selectedRoleApi == e.key,
                  )),
                  if ((selectedRoleApi == 'team_leader' || selectedRoleApi == 'member') && positions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedPosition ?? positions.first,
                      decoration: const InputDecoration(labelText: 'Position', border: OutlineInputBorder()),
                      items: positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => selectedPosition = v),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: temporaryPosition,
                        onChanged: (v) => setState(() => temporaryPosition = v ?? false),
                      ),
                      const Expanded(child: Text('Temporary position', style: TextStyle(fontSize: 14))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: selectedRoleApi == null ? null : () async {
                      final res = await DataProvider.instance.assignRole(userId, role: selectedRoleApi!, position: selectedPosition, temporary: temporaryPosition);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx, res != null);
                      if (res != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role updated for $userName')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update role')));
                      }
                    },
                    child: const Text('Update role'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showAssignProjectSheet(BuildContext context, int userId, String userName) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _AssignProjectSheet(
      userId: userId,
      userName: userName,
      onAssigned: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$userName assigned to project')));
      },
      onError: (msg) {
        if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
    ),
  );
}

class _AssignProjectSheet extends StatefulWidget {
  const _AssignProjectSheet({
    required this.userId,
    required this.userName,
    required this.onAssigned,
    required this.onError,
  });

  final int userId;
  final String userName;
  final VoidCallback onAssigned;
  final void Function(String message) onError;

  @override
  State<_AssignProjectSheet> createState() => _AssignProjectSheetState();
}

class _AssignProjectSheetState extends State<_AssignProjectSheet> {
  List<Map<String, dynamic>> _projects = [];
  bool _loading = true;
  int? _selectedProjectId;
  String _selectedRole = 'team_member';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final list = await DataProvider.instance.getProjects();
      if (!mounted) return;
      setState(() {
        _projects = list.map((p) => {'id': int.tryParse(p.id ?? '') ?? 0, 'name': p.name ?? ''}).where((e) => e['id'] != 0).toList();
        _loading = false;
        if (_projects.isNotEmpty && _selectedProjectId == null) _selectedProjectId = _projects.first['id'] as int?;
      });
    } catch (_) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_projects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No projects available', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Assign to project', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('Add ${widget.userName} to a project as manager, team leader, or team member.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _selectedProjectId ?? _projects.first['id'] as int?,
              decoration: const InputDecoration(labelText: 'Project', border: OutlineInputBorder()),
              items: _projects.map((p) => DropdownMenuItem(value: p['id'] as int, child: Text((p['name'] ?? '').toString()))).toList(),
              onChanged: (v) => setState(() => _selectedProjectId = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Project role', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'manager', child: Text('Manager')),
                DropdownMenuItem(value: 'team_leader', child: Text('Team Leader')),
                DropdownMenuItem(value: 'team_member', child: Text('Team Member')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v ?? 'team_member'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : () async {
                final projectId = _selectedProjectId ?? _projects.first['id'] as int?;
                if (projectId == null) {
                  widget.onError('Select a project');
                  return;
                }
                setState(() => _submitting = true);
                final res = await DataProvider.instance.assignUserToProject(widget.userId, projectId, _selectedRole);
                if (!mounted) return;
                setState(() => _submitting = false);
                if (res != null) {
                  widget.onAssigned();
                } else {
                  widget.onError('User may already be on this project or request failed');
                }
              },
              child: _submitting ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }
}

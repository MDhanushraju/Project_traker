import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/constants/task_status.dart';
import '../../data/data_provider.dart';
import '../tasks/models/task_model.dart';

/// Team Overview: fetches project team (Manager, Team Leader(s), Team Members) from API.
class TeamOverviewPage extends StatefulWidget {
  const TeamOverviewPage({super.key, this.projectId});

  final String? projectId;

  @override
  State<TeamOverviewPage> createState() => _TeamOverviewPageState();
}

class _TeamOverviewPageState extends State<TeamOverviewPage> {
  Map<String, dynamic>? _team;
  bool _loading = true;
  String? _error;
  List<TaskModel> _projectTasks = [];
  bool _tasksLoading = false;
  String? _tasksError;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  @override
  void didUpdateWidget(TeamOverviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      _loadTeam();
    }
  }

  Future<void> _loadTeam() async {
    final idStr = widget.projectId;
    if (idStr == null || idStr.isEmpty) {
      setState(() { _loading = false; _error = 'No project selected'; });
      return;
    }
    final id = int.tryParse(idStr);
    if (id == null) {
      setState(() { _loading = false; _error = 'Invalid project ID'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final team = await DataProvider.instance.getProjectTeam(id);
      if (mounted) {
        setState(() {
          _team = team;
          _loading = false;
          _error = team == null ? 'Project not found' : null;
        });
      }
      if (team != null && mounted) {
        await _loadProjectTasks(id);
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Failed to load team'; });
    }
  }

  Future<void> _loadProjectTasks(int projectId) async {
    setState(() {
      _tasksLoading = true;
      _tasksError = null;
    });
    try {
      final allTasks = await DataProvider.instance.getTasks();
      _projectTasks = allTasks.where((t) => t.projectId == projectId).toList();
      if (mounted) {
        setState(() {
          _tasksLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _tasksLoading = false;
          _tasksError = 'Failed to load project tasks';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectName = _team?['projectName']?.toString() ?? 'Team';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(_loading ? 'Team' : projectName),
          centerTitle: true,
          actions: [
            if (!_loading && _error == null)
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => _loadTeam(),
                tooltip: 'Refresh team',
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Team'),
              Tab(text: 'Project tasks'),
            ],
          ),
        ),
        body: _loading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading team...'),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(_error!, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  )
                : TabBarView(
                    children: [
                      _buildTeamList(context),
                      _buildProjectTasksTab(context),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTeamList(BuildContext context) {
    final theme = Theme.of(context);
    final members = _team!['members'] as List<dynamic>? ?? [];
    final managers = members.where((m) => (m['projectRole'] ?? '').toString().toLowerCase() == 'manager').toList();
    final leaders = members.where((m) => (m['projectRole'] ?? '').toString().toLowerCase() == 'team_leader').toList();
    final teamMembers = members.where((m) => (m['projectRole'] ?? '').toString().toLowerCase() == 'team_member').toList();

    if (managers.isEmpty && leaders.isEmpty && teamMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'No team members assigned yet',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Assign a manager, team leaders, and members to this project from User details or Settings.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ...managers.map((m) => _TeamManagerCard(
          name: (m['name'] ?? '').toString(),
          title: (m['title'] ?? '').toString(),
          avatarColor: Colors.orange,
          photoUrl: (m['photoUrl'] ?? '').toString(),
        )),
        if (managers.isNotEmpty) const SizedBox(height: 16),
        ...leaders.map((m) => _TeamLeaderCard(
          name: (m['name'] ?? '').toString(),
          title: (m['title'] ?? '').toString(),
          avatarColor: Colors.green,
          photoUrl: (m['photoUrl'] ?? '').toString(),
        )),
        if (leaders.isNotEmpty) const SizedBox(height: 24),
        if (teamMembers.isNotEmpty) ...[
          Text(
            'TEAM MEMBERS (${teamMembers.length})',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          ...teamMembers.map((m) => _TeamMemberCard(
            name: (m['name'] ?? '').toString(),
            title: (m['title'] ?? '').toString(),
            photoUrl: (m['photoUrl'] ?? '').toString(),
          )),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProjectTasksTab(BuildContext context) {
    final theme = Theme.of(context);
    final projectName = _team?['projectName']?.toString() ?? '';

    if (_tasksLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading project tasks...'),
          ],
        ),
      );
    }

    if (_tasksError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _tasksError!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final members = _team!['members'] as List<dynamic>? ?? [];
    if (members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No team members assigned to this project.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (projectName.isNotEmpty) ...[
          Text(
            projectName,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Tasks per member for this project',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
        ],
        ...members.map((m) => _ProjectMemberTasksTile(member: m as Map<String, dynamic>, tasks: _projectTasks)),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ProjectMemberTasksTile extends StatelessWidget {
  const _ProjectMemberTasksTile({required this.member, required this.tasks});

  final Map<String, dynamic> member;
  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawId = member['id'];
    final int? userId = rawId is int
        ? rawId
        : rawId is num
            ? rawId.toInt()
            : (rawId != null ? int.tryParse(rawId.toString()) : null);
    final String name = (member['name'] ?? '').toString();
    final String title = (member['title'] ?? '').toString();
    final String position = (member['position'] ?? '').toString();
    final String role = (member['projectRole'] ?? '').toString();

    final memberTasks = userId == null ? <TaskModel>[] : tasks.where((t) => t.assigneeId == userId).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
        title: Text(
          name,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (position.isNotEmpty) position,
            if (role.isNotEmpty) role.replaceAll('_', ' '),
          ].where((e) => e.isNotEmpty).join(' · '),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: memberTasks.isEmpty
            ? [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'No tasks for this member in this project.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ]
            : memberTasks
                .map(
                  (t) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      t.title ?? 'Task',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Status: ${TaskStatus.label(t.status ?? '')}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _TeamManagerCard extends StatelessWidget {
  const _TeamManagerCard({
    required this.name,
    required this.title,
    required this.avatarColor,
    this.photoUrl,
  });

  final String name;
  final String title;
  final Color avatarColor;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TEAM MANAGER',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: avatarColor.withValues(alpha: 0.3),
                  backgroundImage: photoUrl != null && photoUrl!.isNotEmpty ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null || photoUrl!.isEmpty
                      ? Text(
                          name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase(),
                          style: TextStyle(color: avatarColor, fontWeight: FontWeight.w600),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _MessageButton(onPressed: () => _onMessage(context, name)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamLeaderCard extends StatelessWidget {
  const _TeamLeaderCard({
    required this.name,
    this.title = '',
    required this.avatarColor,
    this.photoUrl,
  });

  final String name;
  final String title;
  final Color avatarColor;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TEAM LEADER',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: avatarColor.withValues(alpha: 0.3),
                  backgroundImage: photoUrl != null && photoUrl!.isNotEmpty ? NetworkImage(photoUrl!) : null,
                  child: photoUrl == null || photoUrl!.isEmpty
                      ? Text(
                          name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase(),
                          style: TextStyle(color: avatarColor, fontWeight: FontWeight.w600),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: () => _onContact(context, name),
                      child: const Text('Contact'),
                    ),
                    const SizedBox(width: 8),
                    _MessageButton(onPressed: () => _onMessage(context, name)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({
    required this.name,
    required this.title,
    this.photoUrl,
  });

  final String name;
  final String title;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
          child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              backgroundImage: photoUrl != null && photoUrl!.isNotEmpty ? NetworkImage(photoUrl!) : null,
              child: photoUrl == null || photoUrl!.isEmpty
                  ? Icon(Icons.person_rounded, color: theme.colorScheme.onSurfaceVariant)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => _onDetail(context, name),
                  child: const Text('Detail'),
                ),
                const SizedBox(width: 8),
                _MessageButton(onPressed: () => _onMessage(context, name)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.message_rounded, size: 18),
      label: const Text('Message'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

void _onMessage(BuildContext context, String name) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Message $name')),
  );
}

void _onContact(BuildContext context, String name) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Contact $name')),
  );
}

void _onDetail(BuildContext context, String name) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('View details for $name')),
  );
}

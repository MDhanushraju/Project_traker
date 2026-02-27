import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../data/data_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTeam();
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
      if (mounted) setState(() { _team = team; _loading = false; _error = team == null ? 'Project not found' : null; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Failed to load team'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectName = _team?['projectName']?.toString() ?? 'Team';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_loading ? 'Team' : projectName),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading team...')]))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error), const SizedBox(height: 16), Text(_error!, style: theme.textTheme.bodyLarge)]))
              : _buildTeamList(context),
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

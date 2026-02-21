import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

/// Team Overview: Team Manager, Team Leader, Team Members.
/// Shows each member with Detail and Message buttons.
class TeamOverviewPage extends StatelessWidget {
  const TeamOverviewPage({super.key, this.projectId});

  final String? projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Team Overview'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _TeamManagerCard(
            name: 'Sarah Jenkins',
            title: 'Director of Product Operations',
            avatarColor: Colors.orange,
          ),
          const SizedBox(height: 16),
          _TeamLeaderCard(
            name: 'Marcus Thorne',
            avatarColor: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            'TEAM MEMBERS (8)',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _TeamMemberCard(name: 'Elena Rodriguez', title: 'Senior UI Designer'),
          const SizedBox(height: 12),
          _TeamMemberCard(name: 'David Chen', title: 'Lead Developer'),
          const SizedBox(height: 12),
          _TeamMemberCard(name: 'Sophie Walters', title: 'QA Engineer'),
          const SizedBox(height: 12),
          _TeamMemberCard(name: 'James Wilson', title: 'Backend Architect'),
          const SizedBox(height: 12),
          _TeamMemberCard(name: 'Maya Patel', title: 'Content Strategist'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TeamManagerCard extends StatelessWidget {
  const _TeamManagerCard({
    required this.name,
    required this.title,
    required this.avatarColor,
  });

  final String name;
  final String title;
  final Color avatarColor;

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
                  child: Text(
                    name.split(' ').map((w) => w[0]).take(2).join(),
                    style: TextStyle(color: avatarColor, fontWeight: FontWeight.w600),
                  ),
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
    required this.avatarColor,
  });

  final String name;
  final Color avatarColor;

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
                  child: Text(
                    name.split(' ').map((w) => w[0]).take(2).join(),
                    style: TextStyle(color: avatarColor, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
  });

  final String name;
  final String title;

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
              child: Icon(Icons.person_rounded, color: theme.colorScheme.onSurfaceVariant),
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

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/auth/auth_state.dart';
import '../../core/constants/roles.dart';

/// Arguments for navigating to [UserDetailsPage].
class UserDetailsArgs {
  const UserDetailsArgs({
    required this.name,
    required this.title,
    required this.role,
    this.projects = const [],
    this.status = 'Active',
    this.isTemporary = false,
  });

  final String name;
  final String title;
  final String role;
  final List<String> projects;
  final String status;
  final bool isTemporary;
}

/// User details page: projects, status, and profile info.
class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({
    super.key,
    required this.name,
    required this.title,
    required this.role,
    this.projects = const [],
    this.status = 'Active',
    this.isTemporary = false,
  });

  final String name;
  final String title;
  final String role;
  final List<String> projects;
  final String status;
  final bool isTemporary;

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
                      ],
                      if (isAdmin) ...[
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.arrow_upward_rounded, color: theme.colorScheme.primary),
                          title: const Text('Promote'),
                          subtitle: const Text('Move to higher role'),
                          onTap: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Promote $name — coming soon')),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.arrow_downward_rounded, color: theme.colorScheme.primary),
                          title: const Text('Demote'),
                          subtitle: const Text('Move to lower role'),
                          onTap: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Demote $name — coming soon')),
                            );
                          },
                        ),
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
                  child: Text(
                    name.split(' ').map((w) => w[0]).take(2).join(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isTemporary)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Temporary',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
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
}

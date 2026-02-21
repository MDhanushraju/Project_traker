import 'package:flutter/material.dart';

import '../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';

/// Project Settings: configure defaults, permissions, workflows, preferences.
class ProjectSettingsPage extends StatelessWidget {
  const ProjectSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MainLayout(
      title: 'Project Settings',
      currentRoute: AppRoutes.settings,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings_rounded, size: 32, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Configure project defaults',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Set permissions, workflows, and preferences that apply across all projects.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Defaults',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: SwitchListTile(
              title: const Text('Auto-assign tasks'),
              subtitle: Text(
                'Assign new tasks to team leader by default',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: false,
              onChanged: (_) {},
            ),
          ),
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(top: 8),
            child: SwitchListTile(
              title: const Text('Require approval for status changes'),
              subtitle: Text(
                'Managers must approve status updates',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: false,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Workflows',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.account_tree_rounded),
              title: const Text('Default workflow'),
              subtitle: Text(
                'Todo → In Progress → Done',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';

/// Settings section: Project Settings. Admin only.
class ProjectSettingsSection extends StatelessWidget {
  const ProjectSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(top: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.settings_rounded, color: theme.colorScheme.primary, size: 24),
        ),
        title: const Text('Project Settings'),
        subtitle: Text(
          'Configure project defaults, permissions, workflows, and preferences that apply across all projects.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.projectSettings),
      ),
    );
  }
}

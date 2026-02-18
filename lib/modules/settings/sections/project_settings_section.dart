import 'package:flutter/material.dart';

/// Settings section: project settings.
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
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
        title: const Text('Project settings'),
        subtitle: Text(
          'Defaults and preferences',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
}

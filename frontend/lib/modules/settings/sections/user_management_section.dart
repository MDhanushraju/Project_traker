import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';

/// Settings section: User Management. Admin only.
class UserManagementSection extends StatelessWidget {
  const UserManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.people_rounded, color: theme.colorScheme.primary, size: 24),
        ),
        title: const Text('User Management'),
        subtitle: Text(
          'Assign roles, enable or disable accounts, and control user access across projects and features.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.users),
      ),
    );
  }
}

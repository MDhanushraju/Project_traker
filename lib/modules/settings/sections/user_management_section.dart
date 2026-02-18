import 'package:flutter/material.dart';

/// Settings section: user management.
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
        leading: Icon(Icons.people_rounded, color: theme.colorScheme.primary),
        title: const Text('User management'),
        subtitle: Text(
          'Manage team members and roles',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
}

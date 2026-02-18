import 'package:flutter/material.dart';

/// Settings section: client management.
class ClientManagementSection extends StatelessWidget {
  const ClientManagementSection({super.key});

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
        leading: Icon(Icons.business_rounded, color: theme.colorScheme.primary),
        title: const Text('Client management'),
        subtitle: Text(
          'Manage clients and contacts',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
}

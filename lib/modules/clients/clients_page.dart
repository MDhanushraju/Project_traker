import 'package:flutter/material.dart';

import '../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';

/// Client Management: create and manage client organizations, contacts, link to projects.
class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MainLayout(
      title: 'Client Management',
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
                      Icon(Icons.business_rounded, size: 32, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Manage client organizations',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create clients, maintain contact information, and link organizations to projects and assignments.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(Icons.add_business_rounded, size: 64, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  'No clients yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add client — coming soon')),
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Client'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

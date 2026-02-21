import 'package:flutter/material.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/constants/roles.dart';
import '../../../core/theme/theme_mode_state.dart';
import '../../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';
import 'sections/add_new_project_section.dart';
import 'sections/client_management_section.dart';
import 'sections/project_settings_section.dart';
import 'sections/user_management_section.dart';

/// Settings screen. Uses [MainLayout]; sections for user, client, project settings.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthState.instance.currentUser;

    return MainLayout(
      title: 'Settings',
      currentRoute: AppRoutes.settings,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (user != null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Text(
                        (user.displayName ?? user.label).substring(0, 1).toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? user.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Appearance',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  subtitle: const Text('Use light theme'),
                  value: ThemeMode.light,
                  groupValue: ThemeModeState.instance.themeMode,
                  onChanged: (v) {
                    if (v != null) {
                      ThemeModeState.instance.setThemeMode(v);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  subtitle: const Text('Use dark theme'),
                  value: ThemeMode.dark,
                  groupValue: ThemeModeState.instance.themeMode,
                  onChanged: (v) {
                    if (v != null) {
                      ThemeModeState.instance.setThemeMode(v);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('System'),
                  subtitle: const Text('Match device setting'),
                  value: ThemeMode.system,
                  groupValue: ThemeModeState.instance.themeMode,
                  onChanged: (v) {
                    if (v != null) {
                      ThemeModeState.instance.setThemeMode(v);
                    }
                  },
                ),
              ],
            ),
          ),
          if (user?.role == AppRole.admin) ...[
            const SizedBox(height: 24),
            Text(
              'Admin',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const UserManagementSection(),
            const AddNewProjectSection(),
            const ClientManagementSection(),
            const ProjectSettingsSection(),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

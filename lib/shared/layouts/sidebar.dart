import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/auth_state.dart';
import '../../core/auth/role_access.dart';

/// Nav item for sidebar and mobile nav (route + label + icon).
class NavItem {
  const NavItem(this.route, this.label, this.icon);

  final String route;
  final String label;
  final IconData icon;
}

/// Builds nav items for allowed routes only. Single source for route labels/icons.
class SidebarNav {
  SidebarNav._();

  static const Map<String, (String label, IconData icon)> _routeMeta = {
    AppRoutes.dashboard: ('Dashboard', Icons.dashboard_rounded),
    AppRoutes.projects: ('Projects', Icons.folder_rounded),
    AppRoutes.tasks: ('Tasks', Icons.task_alt_rounded),
    AppRoutes.settings: ('Settings', Icons.settings_rounded),
  };

  static List<NavItem> itemsForRoutes(List<String> routes) {
    return routes
        .where((r) => _routeMeta.containsKey(r))
        .map((r) {
          final meta = _routeMeta[r]!;
          return NavItem(r, meta.$1, meta.$2);
        })
        .toList();
  }
}

/// Sidebar content for drawer (mobile) and as reference for rail (desktop).
/// Nav list + user chip + logout.
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  final String currentRoute;
  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final user = AuthState.instance.currentUser;
    final allowedRoutes = user != null
        ? RoleAccess.allowedRoutesForRole(user.role)
        : <String>[];
    final items = SidebarNav.itemsForRoutes(allowedRoutes);
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Project Tracker',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...items.map((item) {
              final selected = item.route == currentRoute;
              return ListTile(
                leading: Icon(
                  item.icon,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(item.label),
                selected: selected,
                onTap: () => onNavigate(item.route),
              );
            }),
            const Spacer(),
            const Divider(),
            if (user != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child: Text(
                        user.label.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user.displayName ?? user.label,
                        style: theme.textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Log out'),
                onTap: () async {
                  await AuthService.instance.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (_) => false,
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
    );
  }
}

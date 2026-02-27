import 'package:flutter/material.dart';

import '../../core/auth/auth_state.dart';
import '../../core/auth/role_access.dart';
import '../widgets/user_profile_menu.dart';
import 'sidebar.dart';
import 'mobile_nav.dart';

/// Breakpoint width: >= this shows sidebar (web/desktop), < this shows drawer + bottom nav (mobile).
const double kLayoutBreakpoint = 600;

/// Global shell layout. Content injected via [child].
/// Web/Desktop → sidebar (NavigationRail). Mobile/iOS → Drawer + BottomNav.
/// Every protected page should use this.
class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
    this.showTopBarActions = true,
  });

  final String title;
  final String currentRoute;
  final Widget child;
  /// When false, top bar shows only title (no profile/notifications). Use for admin/manager dashboard.
  final bool showTopBarActions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kLayoutBreakpoint;
        final user = AuthState.instance.currentUser;
        final allowedRoutes =
            user != null ? RoleAccess.allowedRoutesForRole(user.role) : <String>[];
        final navItems = SidebarNav.itemsForRoutes(allowedRoutes);

        void onNavigate(String route) {
          if (!isDesktop) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).pushReplacementNamed(route);
        }

        if (isDesktop) {
          return _DesktopShell(
            title: title,
            currentRoute: currentRoute,
            navItems: navItems,
            onNavigate: onNavigate,
            child: child,
            showTopBarActions: showTopBarActions,
          );
        }

        return _MobileShell(
          title: title,
          currentRoute: currentRoute,
          navItems: navItems,
          onNavigate: onNavigate,
          child: child,
          showTopBarActions: showTopBarActions,
        );
      },
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.title,
    required this.currentRoute,
    required this.navItems,
    required this.onNavigate,
    required this.child,
    this.showTopBarActions = true,
  });

  final String title;
  final String currentRoute;
  final List<NavItem> navItems;
  final void Function(String route) onNavigate;
  final Widget child;
  final bool showTopBarActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex =
        navItems.indexWhere((i) => i.route == currentRoute);
    final index = selectedIndex >= 0 ? selectedIndex : 0;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: theme.colorScheme.surface,
            selectedIndex: index.clamp(0, navItems.length - 1),
            onDestinationSelected: (i) {
              if (i >= 0 && i < navItems.length) {
                onNavigate(navItems[i].route);
              }
            },
            destinations: navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                    selectedIcon: Icon(
                      item.icon,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (showTopBarActions) const UserProfileMenu(),
                      ],
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.title,
    required this.currentRoute,
    required this.navItems,
    required this.onNavigate,
    required this.child,
    this.showTopBarActions = true,
  });

  final String title;
  final String currentRoute;
  final List<NavItem> navItems;
  final void Function(String route) onNavigate;
  final Widget child;
  final bool showTopBarActions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: showTopBarActions ? const [UserProfileMenu()] : null,
      ),
      drawer: Drawer(
        child: Sidebar(
          currentRoute: currentRoute,
          onNavigate: onNavigate,
        ),
      ),
      body: child,
      bottomNavigationBar: navItems.isNotEmpty
          ? MobileNavBar(
              navItems: navItems,
              currentRoute: currentRoute,
              onNavigate: onNavigate,
            )
          : null,
    );
  }
}

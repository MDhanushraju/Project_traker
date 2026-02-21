import 'package:flutter/material.dart';

import 'sidebar.dart';

/// Bottom navigation bar for mobile. Shows only allowed routes.
class MobileNavBar extends StatelessWidget {
  const MobileNavBar({
    super.key,
    required this.navItems,
    required this.currentRoute,
    required this.onNavigate,
  });

  final List<NavItem> navItems;
  final String currentRoute;
  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = navItems.indexWhere((i) => i.route == currentRoute);
    final index = selectedIndex >= 0 ? selectedIndex : 0;

    return NavigationBar(
      selectedIndex: index.clamp(0, navItems.length - 1),
      onDestinationSelected: (i) {
        if (i >= 0 && i < navItems.length) {
          onNavigate(navItems[i].route);
        }
      },
      destinations: navItems
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
              selectedIcon: Icon(item.icon),
            ),
          )
          .toList(),
    );
  }
}

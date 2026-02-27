import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/constants/roles.dart';
import '../../core/auth/auth_state.dart';
import '../../app/app_routes.dart';

/// User profile dropdown: shows on hover (desktop) and tap (mobile).
/// Displays role, email placeholder, My Details, Settings, Logout.
class UserProfileMenu extends StatefulWidget {
  const UserProfileMenu({super.key});

  @override
  State<UserProfileMenu> createState() => _UserProfileMenuState();
}

class _UserProfileMenuState extends State<UserProfileMenu> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  String _roleLabel(AuthUser user) {
    switch (user.role) {
      case AppRole.admin:
        return 'ADMINISTRATOR';
      case AppRole.manager:
        return 'MANAGER';
      case AppRole.teamLeader:
        return 'TEAM LEADER';
      case AppRole.member:
        return 'TEAM MEMBER';
    }
  }

  String _emailPlaceholder(AuthUser user) {
    final name = (user.displayName ?? user.label).toLowerCase().replaceAll(' ', '.');
    return '$name@enterprise.com';
  }

  void _showMenu(BuildContext context) {
    _hideMenu();
    final user = AuthState.instance.currentUser;
    if (user == null) return;

    final theme = Theme.of(context);
    final nav = Navigator.of(context);

    final showSettings = user.role == AppRole.admin;
    _overlayEntry = OverlayEntry(
      builder: (ctx) => _MenuOverlay(
        layerLink: _layerLink,
        theme: theme,
        roleLabel: _roleLabel(user),
        email: _emailPlaceholder(user),
        showSettings: showSettings,
        onDismiss: _hideMenu,
        onMyDetails: () {
          _hideMenu();
          nav.pushNamed(AppRoutes.personalDetails);
        },
        onSettings: () {
          _hideMenu();
          nav.pushNamed(AppRoutes.settings);
        },
        onLogout: () async {
          _hideMenu();
          await AuthService.instance.logout();
          if (!context.mounted) return;
          nav.pushNamedAndRemoveUntil(AppRoutes.loginForm, (_) => false);
        },
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hideMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthState.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) return const SizedBox.shrink();

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _showMenu(context),
        onExit: (_) {
          // Menu stays open until tap outside or item selected
        },
        child: GestureDetector(
          onTap: () {
            if (_overlayEntry != null) {
              _hideMenu();
            } else {
              _showMenu(context);
            }
          },
          child: IconButton(
            icon: Icon(Icons.person_outline_rounded, color: theme.colorScheme.onSurface),
            tooltip: 'Profile',
            onPressed: () {
              if (_overlayEntry != null) {
                _hideMenu();
              } else {
                _showMenu(context);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _MenuOverlay extends StatefulWidget {
  const _MenuOverlay({
    required this.layerLink,
    required this.theme,
    required this.roleLabel,
    required this.email,
    required this.showSettings,
    required this.onDismiss,
    required this.onMyDetails,
    required this.onSettings,
    required this.onLogout,
  });

  final LayerLink layerLink;
  final ThemeData theme;
  final String roleLabel;
  final String email;
  final bool showSettings;
  final VoidCallback onDismiss;
  final VoidCallback onMyDetails;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  @override
  State<_MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<_MenuOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
        Positioned(
          width: 240,
          child: CompositedTransformFollower(
            link: widget.layerLink,
            showWhenUnlinked: false,
            offset: const Offset(-200, 48),
            child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: widget.theme.colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.roleLabel,
                              style: widget.theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.email.length > 28
                                  ? '${widget.email.substring(0, 25)}...'
                                  : widget.email,
                              style: widget.theme.textTheme.bodySmall?.copyWith(
                                color: widget.theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'My Details',
                        onTap: widget.onMyDetails,
                        theme: widget.theme,
                      ),
                      if (widget.showSettings)
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          onTap: widget.onSettings,
                          theme: widget.theme,
                        ),
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        onTap: widget.onLogout,
                        theme: widget.theme,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: isDestructive ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

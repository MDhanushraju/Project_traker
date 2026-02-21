import 'package:flutter/material.dart';

/// Top navbar placeholder. Use in layouts if needed.
class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavbar({super.key, this.title});

  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!) : null,
    );
  }
}

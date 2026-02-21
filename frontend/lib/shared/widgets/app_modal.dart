import 'package:flutter/material.dart';

/// Modal bottom sheet / dialog shell. Uses theme.
class AppModal {
  AppModal._();

  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (_) => SafeArea(child: child),
    );
  }

  static Future<T?> openDialog<T>(BuildContext context, {required Widget child}) {
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(child: child),
    );
  }
}

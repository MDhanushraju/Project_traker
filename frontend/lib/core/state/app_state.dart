import 'package:flutter/foundation.dart';

/// Global app state (e.g. connectivity, locale). Extend as needed.
class AppState extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  set isOnline(bool v) {
    if (_isOnline != v) {
      _isOnline = v;
      notifyListeners();
    }
  }
}

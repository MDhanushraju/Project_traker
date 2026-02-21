import 'package:flutter/foundation.dart';

/// Positions like Developer, Tester, Designer. Admin can add more.
class PositionsData extends ChangeNotifier {
  PositionsData._();
  static final PositionsData instance = PositionsData._();

  final List<String> _positions = ['Developer', 'Tester', 'Designer', 'Analyst'];
  List<String> get positions => List.unmodifiable(_positions);

  void addPosition(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _positions.contains(trimmed)) return;
    _positions.add(trimmed);
    notifyListeners();
  }
}

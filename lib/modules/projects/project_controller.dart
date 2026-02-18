import 'package:flutter/foundation.dart';

import 'models/project_model.dart';

/// Controller for project list/detail. Replace with real state when wiring API.
class ProjectController extends ChangeNotifier {
  final List<ProjectModel> _items = [];
  List<ProjectModel> get items => List.unmodifiable(_items);
}

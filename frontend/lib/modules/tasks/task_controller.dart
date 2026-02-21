import 'package:flutter/foundation.dart';

import 'models/task_model.dart';

/// Controller for task list/detail.
class TaskController extends ChangeNotifier {
  final List<TaskModel> _items = [];
  List<TaskModel> get items => List.unmodifiable(_items);
}

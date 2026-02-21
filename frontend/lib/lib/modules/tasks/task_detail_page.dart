import 'package:flutter/material.dart';

import '../../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';
import 'models/task_model.dart';

/// Task detail screen. Add route when needed.
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, this.task});

  final TaskModel? task;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Task',
      currentRoute: AppRoutes.tasks,
      child: Center(child: Text(task?.title ?? 'Task detail')),
    );
  }
}

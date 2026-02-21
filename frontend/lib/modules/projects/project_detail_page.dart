import 'package:flutter/material.dart';

import '../../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';
import 'models/project_model.dart';

/// Project detail screen. Add route when needed.
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, this.project});

  final ProjectModel? project;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Project',
      currentRoute: AppRoutes.projects,
      child: Center(child: Text(project?.name ?? 'Project detail')),
    );
  }
}

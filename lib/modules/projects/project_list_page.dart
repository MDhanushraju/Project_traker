import 'package:flutter/material.dart';

import '../../../data/mock_data.dart';
import '../../../shared/animations/fade_in.dart';
import '../../../shared/layouts/main_layout.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../app/app_routes.dart';
import 'widgets/project_card.dart';

/// Project list screen. Uses [MainLayout]; content injected as child.
class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = MockData.projects;

    if (projects.isEmpty) {
      return MainLayout(
        title: 'Projects',
        currentRoute: AppRoutes.projects,
        child: EmptyState(
          icon: Icons.folder_rounded,
          title: 'No projects yet',
          subtitle: 'Create a project to get started.',
          actionLabel: 'Add New Project',
          onAction: () => Navigator.of(context).pushNamed(AppRoutes.addNewProject),
        ),
      );
    }

    return MainLayout(
      title: 'Projects',
      currentRoute: AppRoutes.projects,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeIn(
                child: Text(
                  '${projects.length} project${projects.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addNewProject),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add New Project'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...projects.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FadeIn(
                child: ProjectCard(
                  project: p,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.teamOverview,
                    arguments: p.id,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

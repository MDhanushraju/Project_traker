import 'package:flutter/material.dart';

import '../../../data/mock_data.dart';
import '../../../shared/animations/fade_in.dart';
import '../../../shared/layouts/main_layout.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../app/app_routes.dart';
import 'widgets/project_card.dart';

/// Project list screen. Loads from API.
class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  @override
  void initState() {
    super.initState();
    MockData.refreshFromApi().then((_) {
      if (!mounted) return;
      setState(() {});
      if (MockData.lastError != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not load projects: ${MockData.lastError}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = MockData.projects;

    if (MockData.isLoading) {
      return MainLayout(
        title: 'Projects',
        currentRoute: AppRoutes.projects,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading projects...'),
            ],
          ),
        ),
      );
    }

    if (projects.isEmpty && MockData.lastError != null) {
      return MainLayout(
        title: 'Projects',
        currentRoute: AppRoutes.projects,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Could not load projects',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  MockData.lastError ?? '',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

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

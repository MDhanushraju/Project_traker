import 'package:flutter/material.dart';
import '../../../data/data_provider.dart';
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
  Future<void> _refreshProjects() async {
    await MockData.refreshFromApi();
    if (mounted) setState(() {});
  }

  void _navigateToAddProject() {
    Navigator.of(context).pushNamed(AppRoutes.addNewProject).then((_) => _refreshProjects());
  }

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
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    await _refreshProjects();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Retry'),
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
          onAction: () => _navigateToAddProject(),
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
                onPressed: _navigateToAddProject,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ProjectCard(
                        project: p,
                        onTap: (p.id != null && p.id!.isNotEmpty)
                            ? () => Navigator.of(context).pushNamed(
                                  AppRoutes.teamOverview,
                                  arguments: p.id!,
                                )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Delete project',
                      icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete project'),
                            content: Text('Are you sure you want to delete "${p.name ?? 'this project'}"? This will also remove its tasks and assignments.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.error,
                                  foregroundColor: theme.colorScheme.onError,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                        // p.id is String? from API; parse to int for delete.
                        final int? projectId = p.id != null && p.id!.isNotEmpty
                            ? int.tryParse(p.id!)
                            : null;
                        if (projectId == null) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid project id; cannot delete')),
                          );
                          return;
                        }
                        final ok = await DataProvider.instance.deleteProject(projectId);
                        if (!mounted) return;
                        if (ok) {
                          await _refreshProjects();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Project "${p.name}" deleted')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete project')),
                          );
                        }
                      },
                    ),
                  ],
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

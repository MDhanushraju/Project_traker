import 'package:flutter/material.dart';

import '../../../core/auth/auth_state.dart';
import '../../../data/mock_data.dart';
import '../../../shared/animations/fade_in.dart';
import '../../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';
import 'widgets/project_status_card.dart';
import 'widgets/upcoming_tasks_list.dart';

/// Dashboard screen. Stats, active projects, upcoming tasks, quick actions.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthState.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    final theme = Theme.of(context);
    final projects = MockData.projects;
    final upcomingTitles = MockData.upcomingTaskTitles;

    return MainLayout(
      title: 'Dashboard',
      currentRoute: AppRoutes.dashboard,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FadeIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user.displayName ?? user.label}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here’s what’s going on.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FadeIn(
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Projects',
                    value: '${MockData.projectCount}',
                    icon: Icons.folder_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Tasks',
                    value: '${MockData.taskCount}',
                    icon: Icons.task_alt_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FadeIn(
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Overdue',
                    value: '${MockData.overdueCount}',
                    icon: Icons.schedule_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _SectionHeader(
            title: 'Active projects',
            onSeeAll: () => Navigator.of(context).pushNamed(AppRoutes.projects),
          ),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No projects yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...projects.take(3).map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ProjectStatusCard(
                      title: p.name ?? 'Project',
                      status: p.status ?? '',
                      icon: Icons.folder_rounded,
                    ),
                  ),
                ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Upcoming tasks',
            onSeeAll: () => Navigator.of(context).pushNamed(AppRoutes.tasks),
          ),
          const SizedBox(height: 12),
          UpcomingTasksList(items: upcomingTitles),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See all'),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

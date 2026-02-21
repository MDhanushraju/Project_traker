import 'package:flutter/material.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/constants/roles.dart';
import '../../../core/constants/task_status.dart';
import '../../../data/data_provider.dart';
import '../../../data/mock_data.dart';
import '../users/user_details_page.dart';
import '../../../shared/animations/fade_in.dart';
import '../../../shared/layouts/main_layout.dart';
import '../../app/app_routes.dart';
import 'widgets/project_status_card.dart';

/// Dashboard screen. Stats, active projects, upcoming tasks, quick actions.
/// Loads data from API on init.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
                content: Text('Could not load data: ${MockData.lastError}'),
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
    final user = AuthState.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    if (MockData.isLoading) {
      return MainLayout(
        title: 'Dashboard',
        currentRoute: AppRoutes.dashboard,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }

    if (user.role == AppRole.admin) {
      return MainLayout(
        title: 'Admin Hub',
        currentRoute: AppRoutes.dashboard,
        child: const _AdminHubContent(),
      );
    }

    if (user.role == AppRole.manager) {
      return MainLayout(
        title: 'Manager Hub',
        currentRoute: AppRoutes.dashboard,
        child: const _ManagerHubContent(),
      );
    }

    if (user.role == AppRole.teamLeader) {
      return MainLayout(
        title: 'Team Leader Hub',
        currentRoute: AppRoutes.dashboard,
        child: const _TeamLeaderHubContent(),
      );
    }

    if (user.role == AppRole.member) {
      return MainLayout(
        title: 'My Work',
        currentRoute: AppRoutes.dashboard,
        child: const _MemberHubContent(),
      );
    }

    final theme = Theme.of(context);

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
                    label: 'Updates',
                    value: '${MockData.projectCount}',
                    icon: Icons.update_rounded,
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
            title: 'Projects',
            onSeeAll: () => Navigator.of(context).pushNamed(AppRoutes.projects),
          ),
          const SizedBox(height: 12),
          if (MockData.projects.isEmpty)
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
            ...MockData.projects.take(4).map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ProjectStatusCard(
                      title: p.name ?? 'Project',
                      status: p.status ?? '',
                      icon: Icons.folder_rounded,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.projects),
                    ),
                  ),
                ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addSmallChange),
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  label: const Text('Add Small Change'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.updateExistingProject),
                  icon: const Icon(Icons.update_rounded, size: 20),
                  label: const Text('Update Existing Project'),
                ),
              ),
            ],
          ),
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

/// Manager Hub: Projects, Assign Project, Assign Task, Shift Member, etc.
class _ManagerHubContent extends StatelessWidget {
  const _ManagerHubContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = MockData.projects;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'TEAM & PROJECTS',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _AdminStatCard(
                value: '${MockData.projectCount}',
                label: 'PROJECTS',
                icon: Icons.folder_rounded,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.projects),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AdminStatCard(
                value: '${MockData.taskCount}',
                label: 'TASKS',
                icon: Icons.task_alt_rounded,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.tasks),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _AssignProjectSection(theme: theme),
        const SizedBox(height: 20),
        _AssignTaskSection(theme: theme),
        const SizedBox(height: 20),
        _ShiftTeamMemberSection(theme: theme),
        const SizedBox(height: 32),
        _ProjectsSection(theme: theme),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ASSIGNMENTS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('HISTORY')),
          ],
        ),
        const SizedBox(height: 12),
        _RecentAssignmentRow(
          name: 'John Doe',
          role: 'Assigned as Lead Developer',
          tag: 'ALPHA',
          tagColor: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _RecentAssignmentRow(
          name: 'Elena Vance',
          role: 'Assigned as UI Designer',
          tag: 'GAMMA',
          tagColor: Colors.green,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

/// Team Leader Hub: Assigned projects, team members, tasks, assign task, team manager.
class _TeamLeaderHubContent extends StatelessWidget {
  const _TeamLeaderHubContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = MockData.teamLeaderAssignedProjects;
    final teamMembers = MockData.teamLeaderTeamMembers;
    final teamManager = MockData.teamManager;
    final tasks = MockData.tasks;
    final doneTasks = tasks.where((t) => t.status == 'done').toList();
    final pendingTasks = tasks.where((t) => t.status != 'done').toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'MY ASSIGNED PROJECTS',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...projects.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ProjectStatusCard(
                title: p,
                status: 'Active',
                icon: Icons.folder_rounded,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.teamOverview,
                  arguments: p,
                ),
              ),
            )),
        const SizedBox(height: 32),
        Text(
          'TEAM MANAGER',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        _TeamManagerCard(
          name: teamManager['name'] ?? 'Team Manager',
          title: teamManager['title'] ?? '',
          onMessage: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message ${teamManager['name']}')),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'ASSIGN TASK',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.assignTask),
            icon: const Icon(Icons.assignment_turned_in_rounded, size: 20),
            label: const Text('Assign Task to Team Members'),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'TEAM MEMBERS',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'View details and tasks',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...projects.expand((project) {
          final members = teamMembers[project] ?? [];
          return members.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TeamMemberCard(
                  name: m['name'] ?? '',
                  title: m['title'] ?? '',
                  project: project,
                  onDetails: () => Navigator.of(context).pushNamed(
                    AppRoutes.userDetails,
                    arguments: UserDetailsArgs(
                      name: m['name'] ?? '',
                      title: m['title'] ?? '',
                      role: '${m['position']} · Team Member',
                      projects: [project],
                      status: 'Active',
                    ),
                  ),
                ),
              ));
        }),
        const SizedBox(height: 32),
        Text(
          'TASKS',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        if (doneTasks.isNotEmpty) ...[
          Text(
            'Done',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...doneTasks.map((t) => _TaskRow(
                title: t.title ?? '',
                status: t.status ?? '',
                dueDate: t.dueDate ?? '',
              )),
          const SizedBox(height: 16),
        ],
        if (pendingTasks.isNotEmpty) ...[
          Text(
            'Pending / In Progress',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...pendingTasks.map((t) => _TaskRow(
                title: t.title ?? '',
                status: t.status ?? '',
                dueDate: t.dueDate ?? '',
              )),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _TeamManagerCard extends StatelessWidget {
  const _TeamManagerCard({
    required this.name,
    required this.title,
    required this.onMessage,
  });

  final String name;
  final String title;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
              child: Text(
                name.split(' ').map((w) => w[0]).take(2).join(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onMessage,
              icon: const Icon(Icons.message_rounded, size: 18),
              label: const Text('Message'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({
    required this.name,
    required this.title,
    required this.project,
    required this.onDetails,
  });

  final String name;
  final String title;
  final String project;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
          child: Text(
            name.split(' ').map((w) => w[0]).take(2).join(),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('$title · $project',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        trailing: OutlinedButton(onPressed: onDetails, child: const Text('Details')),
      ),
    );
  }
}

/// Team Member Hub: My Projects, My Tasks, Message Team Leader/Manager/Members.
class _MemberHubContent extends StatefulWidget {
  const _MemberHubContent();

  @override
  State<_MemberHubContent> createState() => _MemberHubContentState();
}

class _MemberHubContentState extends State<_MemberHubContent> {
  String _taskFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = MockData.memberAssignedProjects;
    final contacts = MockData.memberContacts;
    var tasks = MockData.tasks;
    if (_taskFilter != 'all') {
      tasks = tasks.where((t) => (t.status ?? '') == _taskFilter).toList();
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'MY PROJECTS',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...projects.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ProjectStatusCard(
                title: p,
                status: 'Active',
                icon: Icons.folder_rounded,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.teamOverview,
                  arguments: p,
                ),
              ),
            )),
        const SizedBox(height: 32),
        Text(
          'MESSAGE',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Team Leader, Manager & Team Members',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...contacts.map((c) => _MessageContactCard(
              name: c['name'] ?? '',
              title: c['title'] ?? '',
              type: c['type'] ?? '',
              onMessage: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message ${c['name']}')),
              ),
            )),
        const SizedBox(height: 32),
        Text(
          'MY TASKS',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _MemberFilterChip(label: 'All', value: 'all', current: _taskFilter, onTap: () => setState(() => _taskFilter = 'all')),
              const SizedBox(width: 8),
              _MemberFilterChip(label: 'Yet to Start', value: TaskStatus.yetToStart, current: _taskFilter, onTap: () => setState(() => _taskFilter = TaskStatus.yetToStart)),
              const SizedBox(width: 8),
              _MemberFilterChip(label: 'Todo', value: TaskStatus.todo, current: _taskFilter, onTap: () => setState(() => _taskFilter = TaskStatus.todo)),
              const SizedBox(width: 8),
              _MemberFilterChip(label: 'Ongoing', value: TaskStatus.inProgress, current: _taskFilter, onTap: () => setState(() => _taskFilter = TaskStatus.inProgress)),
              const SizedBox(width: 8),
              _MemberFilterChip(label: 'Completed', value: TaskStatus.done, current: _taskFilter, onTap: () => setState(() => _taskFilter = TaskStatus.done)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No tasks in this filter.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MemberTaskCard(
                  title: t.title ?? '',
                  status: t.status ?? '',
                  dueDate: t.dueDate ?? '',
                ),
              )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.tasks),
            icon: const Icon(Icons.list_rounded, size: 20),
            label: const Text('View All Tasks'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _MemberFilterChip extends StatelessWidget {
  const _MemberFilterChip({required this.label, required this.value, required this.current, required this.onTap});

  final String label;
  final String value;
  final String current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = current == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      side: BorderSide(
        color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
      ),
    );
  }
}

class _MessageContactCard extends StatelessWidget {
  const _MessageContactCard({
    required this.name,
    required this.title,
    required this.type,
    required this.onMessage,
  });

  final String name;
  final String title;
  final String type;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
          child: Text(
            name.split(' ').map((w) => w[0]).take(2).join(),
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        title: Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('$title · $type', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        trailing: FilledButton.icon(
          onPressed: onMessage,
          icon: const Icon(Icons.message_rounded, size: 18),
          label: const Text('Message'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        ),
      ),
    );
  }
}

class _MemberTaskCard extends StatelessWidget {
  const _MemberTaskCard({required this.title, required this.status, required this.dueDate});

  final String title;
  final String status;
  final String dueDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = status == TaskStatus.done;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 24,
          color: isDone ? Colors.green : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: dueDate.isNotEmpty ? Text(dueDate, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)) : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(TaskStatus.label(status), style: theme.textTheme.labelSmall),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.title, required this.status, required this.dueDate});

  final String title;
  final String status;
  final String dueDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = status == 'done';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: isDone ? Colors.green : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? theme.colorScheme.onSurfaceVariant : null,
              ),
            ),
          ),
          if (dueDate.isNotEmpty)
            Text(
              dueDate,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// Admin Hub: PROJECT OVERVIEW, Assign Project, Assign Task, Shift Member, Recent Assignments.
class _AdminHubContent extends StatelessWidget {
  const _AdminHubContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'PROJECT OVERVIEW',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _AdminStatCard(
                value: '42',
                label: 'ACTIVE PROJECTS',
                icon: Icons.rocket_launch_rounded,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.projects),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AdminStatCard(
                value: '${MockData.projectCount}',
                label: 'PROJECTS',
                icon: Icons.folder_rounded,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.projects),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _AssignProjectSection(theme: theme),
        const SizedBox(height: 20),
        _AssignTaskSection(theme: theme),
        const SizedBox(height: 20),
        _ShiftTeamMemberSection(theme: theme),
        const SizedBox(height: 32),
        _ProjectsSection(theme: theme),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ASSIGNMENTS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('HISTORY'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _RecentAssignmentRow(
          name: 'John Doe',
          role: 'Assigned as Lead Developer',
          tag: 'ALPHA',
          tagColor: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _RecentAssignmentRow(
          name: 'Elena Vance',
          role: 'Assigned as UI Designer',
          tag: 'GAMMA',
          tagColor: Colors.green,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignTaskSection extends StatelessWidget {
  const _AssignTaskSection({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_rounded, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text('Assign Task', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Assign tasks to team members',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.assignTask),
            icon: const Icon(Icons.assignment_turned_in_rounded, size: 20),
            label: const Text('Assign Task'),
          ),
        ),
      ],
    );
  }
}

class _ShiftTeamMemberSection extends StatelessWidget {
  const _ShiftTeamMemberSection({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.swap_horiz_rounded, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text('Shift / Remove Team Member', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Move members between projects or remove from project',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.shiftTeamMember),
            icon: const Icon(Icons.swap_horiz_rounded, size: 20),
            label: const Text('Shift or Remove Member'),
          ),
        ),
      ],
    );
  }
}

class _AssignProjectSection extends StatelessWidget {
  const _AssignProjectSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_add_rounded, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Assign Project',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Allocate resources to new initiatives',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.assignProject),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
            label: const Text('Assign Project'),
          ),
        ),
      ],
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final projects = MockData.projects;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PROJECTS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.projects),
              child: const Text('See all'),
            ),
          ],
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
          ...projects.take(4).map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ProjectStatusCard(
                    title: p.name ?? 'Project',
                    status: p.status ?? '',
                    icon: Icons.folder_rounded,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.projects),
                  ),
                ),
              ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addSmallChange),
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                label: const Text('Add Small Change'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.updateExistingProject),
                icon: const Icon(Icons.update_rounded, size: 20),
                label: const Text('Update Existing Project'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentAssignmentRow extends StatelessWidget {
  const _RecentAssignmentRow({
    required this.name,
    required this.role,
    required this.tag,
    required this.tagColor,
  });

  final String name;
  final String role;
  final String tag;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Text(
                name.split(' ').map((w) => w[0]).join().toUpperCase().substring(0, 1),
                style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text(role, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tagColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

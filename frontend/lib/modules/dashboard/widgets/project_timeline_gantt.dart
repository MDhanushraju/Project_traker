import 'package:flutter/material.dart';

/// Single task row for the Gantt chart (letter avatar, title, subtitle).
class _GanttTaskCard extends StatelessWidget {
  const _GanttTaskCard({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String letter;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.25),
              child: Text(
                letter,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Project timeline / Gantt view: task list on left, progress bars on timeline, status row at bottom.
class ProjectTimelineGantt extends StatelessWidget {
  const ProjectTimelineGantt({super.key});

  static const List<int> _timelineDays = [28, 29, 30, 31, 1, 2, 3, 4, 5, 6];
  static const List<String> _statusLabels = [
    'DRAFT',
    'IN PROGRESS',
    'EDITING',
    'DONE',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = [
      (letter: 'A', title: 'INCIDIDUNT UT LABORE ET', subtitle: 'Lorem ipsum dolor sit amet', color: Colors.blue, progress: 0.55, label: 'Lorem'),
      (letter: 'B', title: 'ENIM AD MINIM VENIAM', subtitle: 'Lorem ipsum dolor sit amet', color: Colors.purple, progress: 0.80, label: 'Ipsum'),
      (letter: 'C', title: 'ADIPISCING ELIT EIUSMOD', subtitle: 'Lorem ipsum dolor sit amet', color: Colors.pink, progress: 0.65, label: 'Dolor'),
      (letter: 'D', title: 'EXCEPTEUR SINT OCCAECAT', subtitle: 'Lorem ipsum dolor sit amet', color: Colors.orange, progress: 0.75, label: 'Magni'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline header
        Padding(
          padding: const EdgeInsets.only(left: 200),
          child: Row(
            children: _timelineDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    '$d',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Task list + Gantt bars
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: tasks
                    .map(
                      (t) => _GanttTaskCard(
                        letter: t.letter,
                        title: t.title,
                        subtitle: t.subtitle,
                        color: t.color,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: tasks.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final filledWidth = constraints.maxWidth * t.progress;
                        return Container(
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: (t.progress * 100).round(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: t.color.withValues(alpha: 0.85),
                                        borderRadius: const BorderRadius.horizontal(
                                          left: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 100 - (t.progress * 100).round(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: t.color.withValues(alpha: 0.35),
                                        borderRadius: const BorderRadius.horizontal(
                                          right: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                left: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Icon(
                                    Icons.nightlight_round,
                                    size: 18,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 32,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text(
                                    t.label,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Text(
                                    '${(t.progress * 100).round()}%',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Status labels
        Padding(
          padding: const EdgeInsets.only(left: 200),
          child: Row(
            children: _statusLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

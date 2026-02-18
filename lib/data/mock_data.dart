import '../modules/projects/models/project_model.dart';
import '../modules/tasks/models/task_model.dart';

/// Mock data for UI. Replace with API later.
class MockData {
  MockData._();

  static List<ProjectModel> get projects => [
        const ProjectModel(
          id: '1',
          name: 'Website Redesign',
          status: 'Active',
          progress: 65,
        ),
        const ProjectModel(
          id: '2',
          name: 'Mobile App',
          status: 'Active',
          progress: 30,
        ),
        const ProjectModel(
          id: '3',
          name: 'API Integration',
          status: 'On hold',
          progress: 10,
        ),
      ];

  static List<TaskModel> get tasks => [
        const TaskModel(
          id: '1',
          title: 'Review wireframes',
          status: 'in_progress',
          dueDate: '2025-02-20',
        ),
        const TaskModel(
          id: '2',
          title: 'Setup dev environment',
          status: 'done',
          dueDate: '2025-02-15',
        ),
        const TaskModel(
          id: '3',
          title: 'Design system audit',
          status: 'todo',
          dueDate: '2025-02-25',
        ),
        const TaskModel(
          id: '4',
          title: 'User testing session',
          status: 'todo',
          dueDate: '2025-03-01',
        ),
        const TaskModel(
          id: '5',
          title: 'Deploy staging',
          status: 'in_progress',
          dueDate: '2025-02-22',
        ),
      ];

  static List<String> get upcomingTaskTitles =>
      tasks.take(3).map((t) => t.title ?? '').toList();

  static int get projectCount => projects.length;
  static int get taskCount => tasks.length;
  static int get overdueCount => 1;
}

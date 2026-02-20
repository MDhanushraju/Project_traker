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
        const ProjectModel(
          id: '4',
          name: 'Bug Fix - Login Flow',
          status: 'Active',
          progress: 45,
        ),
        const ProjectModel(
          id: '5',
          name: 'UI Color Theme Update',
          status: 'Active',
          progress: 80,
        ),
        const ProjectModel(
          id: '6',
          name: 'Dashboard Performance',
          status: 'In Progress',
          progress: 55,
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
        const TaskModel(
          id: '6',
          title: 'API documentation',
          status: 'yet_to_start',
          dueDate: '2025-03-05',
        ),
        const TaskModel(
          id: '7',
          title: 'Security review',
          status: 'yet_to_start',
          dueDate: '2025-03-10',
        ),
      ];

  static List<String> get upcomingTaskTitles =>
      tasks.take(3).map((t) => t.title ?? '').toList();

  static int get projectCount => projects.length;
  static int get taskCount => tasks.length;
  static int get overdueCount => 1;

  /// Mock: projects assigned to the current Team Leader. Replace with API.
  static List<String> get teamLeaderAssignedProjects =>
      ['API Integration', 'Website Redesign'];

  /// Mock: team members under Team Leader per project. Replace with API.
  static Map<String, List<Map<String, String>>> get teamLeaderTeamMembers => {
        'API Integration': [
          {'name': 'David Chen', 'title': 'Lead Developer', 'position': 'Developer'},
          {'name': 'James Wilson', 'title': 'Backend Architect', 'position': 'Developer'},
        ],
        'Website Redesign': [
          {'name': 'David Chen', 'title': 'Lead Developer', 'position': 'Developer'},
          {'name': 'Maya Patel', 'title': 'Content Strategist', 'position': 'Analyst'},
          {'name': 'John Doe', 'title': 'Developer', 'position': 'Developer'},
        ],
      };

  /// Mock: Team Manager for Team Leader to contact. Replace with API.
  static Map<String, String> get teamManager => {
        'name': 'Sarah Jenkins',
        'title': 'Director of Product Operations',
      };

  /// Mock: projects assigned to current Team Member. Replace with API.
  static List<String> get memberAssignedProjects => ['API Integration', 'Website Redesign'];

  /// Mock: Team Member contacts - Team Leader, Manager, other members. Replace with API.
  static List<Map<String, String>> get memberContacts => [
        {'name': 'Marcus Thorne', 'title': 'Tech Lead', 'type': 'Team Leader'},
        {'name': 'Sarah Jenkins', 'title': 'Director of Product Operations', 'type': 'Manager'},
        {'name': 'David Chen', 'title': 'Lead Developer', 'type': 'Team Member'},
        {'name': 'Sophie Walters', 'title': 'QA Engineer', 'type': 'Team Member'},
        {'name': 'Maya Patel', 'title': 'Content Strategist', 'type': 'Team Member'},
      ];
}

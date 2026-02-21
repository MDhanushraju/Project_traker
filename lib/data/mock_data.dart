import '../modules/projects/models/project_model.dart';
import '../modules/tasks/models/task_model.dart';
import 'api_repository.dart';

/// Data for UI. Loads from API; falls back to empty when offline.
class MockData {
  MockData._();

  static List<ProjectModel>? _projectsCache;
  static List<TaskModel>? _tasksCache;
  static List<String>? _teamLeaderProjectsCache;
  static Map<String, List<Map<String, dynamic>>>? _teamLeaderMembersCache;
  static Map<String, String>? _teamManagerCache;
  static List<String>? _memberProjectsCache;
  static List<Map<String, String>>? _memberContactsCache;
  static int? _overdueCountCache;
  static bool _isLoading = false;
  static String? _lastError;

  static final _api = ApiRepository.instance;

  static bool get isLoading => _isLoading;
  static String? get lastError => _lastError;

  /// Call to load from API. Triggers rebuild of consumers when done.
  static Future<void> refreshFromApi() async {
    _isLoading = true;
    _lastError = null;
    try {
      _projectsCache = await _api.getProjects();
      _tasksCache = await _api.getTasks();
      _teamLeaderProjectsCache = await _api.getTeamLeaderProjects();
      _teamLeaderMembersCache = await _api.getTeamLeaderTeamMembers();
      _teamManagerCache = await _api.getTeamManager();
      _memberProjectsCache = await _api.getMemberProjects();
      _memberContactsCache = await _api.getMemberContacts();
      _overdueCountCache = null;
      final now = DateTime.now();
      _overdueCountCache = (_tasksCache ?? []).where((t) {
        final d = t.dueDate;
        if (d == null || d.isEmpty) return false;
        try {
          return DateTime.parse(d).isBefore(now) && (t.status ?? '') != 'done';
        } catch (_) {
          return false;
        }
      }).length;
    } catch (e) {
      _lastError = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _isLoading = false;
    }
  }

  static List<ProjectModel> get projects => _projectsCache ?? [];
  static List<TaskModel> get tasks => _tasksCache ?? [];
  static List<String> get upcomingTaskTitles => tasks.take(3).map((t) => t.title ?? '').toList();
  static int get projectCount => projects.length;
  static int get taskCount => tasks.length;
  static int get overdueCount => _overdueCountCache ?? 0;

  static List<String> get teamLeaderAssignedProjects =>
      _teamLeaderProjectsCache ?? ['API Integration', 'Website Redesign'];

  static Map<String, List<Map<String, dynamic>>> get teamLeaderTeamMembers =>
      _teamLeaderMembersCache ?? {
        'API Integration': [
          {'id': 0, 'name': 'David Chen', 'title': 'Lead Developer', 'position': 'Developer'},
          {'id': 0, 'name': 'James Wilson', 'title': 'Backend Architect', 'position': 'Developer'},
        ],
        'Website Redesign': [
          {'id': 0, 'name': 'David Chen', 'title': 'Lead Developer', 'position': 'Developer'},
          {'id': 0, 'name': 'Maya Patel', 'title': 'Content Strategist', 'position': 'Analyst'},
          {'id': 0, 'name': 'John Doe', 'title': 'Developer', 'position': 'Developer'},
        ],
      };

  static Map<String, String> get teamManager =>
      _teamManagerCache ?? {'name': 'Sarah Jenkins', 'title': 'Director of Product Operations'};

  static List<String> get memberAssignedProjects =>
      _memberProjectsCache ?? ['API Integration', 'Website Redesign'];

  static List<Map<String, String>> get memberContacts =>
      _memberContactsCache ?? [
        {'name': 'Marcus Thorne', 'title': 'Tech Lead', 'type': 'Team Leader'},
        {'name': 'Sarah Jenkins', 'title': 'Director of Product Operations', 'type': 'Manager'},
        {'name': 'David Chen', 'title': 'Lead Developer', 'type': 'Team Member'},
        {'name': 'Sophie Walters', 'title': 'QA Engineer', 'type': 'Team Member'},
        {'name': 'Maya Patel', 'title': 'Content Strategist', 'type': 'Team Member'},
      ];
}

import '../modules/projects/models/project_model.dart';
import '../modules/tasks/models/task_model.dart';
import 'api_repository.dart';

/// Provides data from API. Use in FutureBuilder.
class DataProvider {
  DataProvider._();
  static final DataProvider instance = DataProvider._();

  final _api = ApiRepository.instance;

  Future<List<ProjectModel>> getProjects() => _api.getProjects();

  Future<List<TaskModel>> getTasks() => _api.getTasks();

  Future<int> getProjectCount() async {
    final list = await getProjects();
    return list.length;
  }

  Future<int> getTaskCount() async {
    final list = await getTasks();
    return list.length;
  }

  Future<int> getOverdueCount() async {
    final tasks = await getTasks();
    final now = DateTime.now();
    return tasks.where((t) {
      final d = t.dueDate;
      if (d == null || d.isEmpty) return false;
      try {
        final due = DateTime.parse(d);
        return due.isBefore(now) && (t.status ?? '') != 'done';
      } catch (_) {
        return false;
      }
    }).length;
  }

  Future<List<String>> getTeamLeaderProjects() => _api.getTeamLeaderProjects();

  Future<Map<String, List<Map<String, dynamic>>>> getTeamLeaderTeamMembers() =>
      _api.getTeamLeaderTeamMembers();

  Future<List<Map<String, dynamic>>> getAllUsers({String? forRole, String? forEmail}) =>
      _api.getAllUsers(forRole: forRole, forEmail: forEmail);

  Future<int?> getUserCount() => _api.getUserCount();

  Future<Map<String, dynamic>?> getProjectTeam(int projectId) => _api.getProjectTeam(projectId);

  Future<Map<String, dynamic>?> assignUserToProject(int userId, int projectId, String projectRole) =>
      _api.assignUserToProject(userId, projectId, projectRole);

  Future<Map<String, dynamic>?> getUserById(int id) => _api.getUserById(id);

  Future<Map<String, dynamic>?> updateUserProfile(int userId, {String? photoUrl, int? age, String? skills}) =>
      _api.updateUserProfile(userId, photoUrl: photoUrl, age: age, skills: skills);

  Future<Map<String, dynamic>?> createUser({
    required String fullName,
    required String email,
    String? password,
    required String role,
    String? position,
    String? title,
    bool temporary = false,
  }) =>
      _api.createUser(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        position: position,
        title: title,
        temporary: temporary,
      );

  Future<Map<String, dynamic>?> assignRole(int userId, {required String role, String? position, bool? temporary}) =>
      _api.assignRole(userId, role: role, position: position, temporary: temporary);

  Future<Map<String, dynamic>?> setUserTemporary(int userId, bool temporary) =>
      _api.updateUserProfile(userId, temporary: temporary);

  Future<bool> createTask({
    required String title,
    String status = 'need_to_start',
    String? dueDate,
    int? assignedToId,
    int? projectId,
  }) =>
      _api.createTask(title: title, status: status, dueDate: dueDate, assignedToId: assignedToId, projectId: projectId);

  Future<bool> updateTaskStatus({required String taskId, required String status}) =>
      _api.updateTaskStatus(taskId: taskId, status: status);

  Future<bool> deleteTask(String taskId) => _api.deleteTask(taskId);

  Future<bool> kickUser(int userId) => _api.kickUser(userId);

  Future<(bool, String?)> kickUserWithMessage(int userId) => _api.kickUserWithMessage(userId);

  Future<bool> assignTask({
    required int userId,
    required String taskTitle,
    String? dueDate,
    int? projectId,
  }) =>
      _api.assignTask(
        userId: userId,
        taskTitle: taskTitle,
        dueDate: dueDate,
        projectId: projectId,
      );

  Future<Map<String, String>> getTeamManager() => _api.getTeamManager();

  Future<List<String>> getMemberProjects() => _api.getMemberProjects();

  Future<List<Map<String, String>>> getMemberContacts() => _api.getMemberContacts();
}

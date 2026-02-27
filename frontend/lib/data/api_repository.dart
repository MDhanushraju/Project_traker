import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../modules/projects/models/project_model.dart';
import '../modules/tasks/models/task_model.dart';

/// Repository for API data. Replaces MockData.
class ApiRepository {
  ApiRepository._();
  static final ApiRepository instance = ApiRepository._();

  final _client = ApiClient.instance;

  Future<List<ProjectModel>> getProjects() async {
    try {
      final res = await _client.get('/api/projects');
      final data = res is List ? res : (res['data'] ?? res);
      if (data is! List) return [];
      return (data as List).map((e) => _projectFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      final res = await _client.get('/api/tasks');
      final data = res is List ? res : (res['data'] ?? res);
      if (data is! List) return [];
      return (data as List).map((e) => _taskFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> getTeamLeaderProjects() async {
    try {
      final res = await _client.get('/api/users/team-leader/projects');
      final data = res['data'];
      if (data is! List) return [];
      return (data as List).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> getTeamLeaderTeamMembers() async {
    try {
      final res = await _client.get('/api/users/team-leader/team-members');
      final data = (res is Map ? res['data'] : null) as Map<String, dynamic>?;
      if (data == null) return {};
      final result = <String, List<Map<String, dynamic>>>{};
      for (final e in data.entries) {
        final list = e.value as List?;
        result[e.key] = (list ?? []).map((m) {
          final map = m as Map<String, dynamic>;
          return {
            'id': map['id'],
            'name': (map['name'] ?? '').toString(),
            'title': (map['title'] ?? '').toString(),
            'position': (map['position'] ?? '').toString(),
          };
        }).toList();
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, String>> getTeamManager() async {
    try {
      final res = await _client.get('/api/users/team-leader/team-manager');
      final data = res['data'] as Map<String, dynamic>?;
      if (data == null) return {};
      return data.map((k, v) => MapEntry(k.toString(), (v ?? '').toString()));
    } catch (_) {
      return {};
    }
  }

  Future<List<String>> getMemberProjects() async {
    try {
      final res = await _client.get('/api/users/member/projects');
      final data = res['data'];
      if (data is! List) return [];
      return (data as List).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, String>>> getMemberContacts() async {
    try {
      final res = await _client.get('/api/users/member/contacts');
      final data = res['data'];
      if (data is! List) return [];
      return (data as List).map((m) {
        final map = m as Map<String, dynamic>;
        return {
          'name': (map['name'] ?? '').toString(),
          'title': (map['title'] ?? '').toString(),
          'type': (map['type'] ?? '').toString(),
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> createUser({
    required String fullName,
    required String email,
    String? password,
    required String role,
    String? position,
    String? title,
    bool temporary = false,
  }) async {
    try {
      final payload = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'role': role,
        'temporary': temporary,
        if (password != null && password.isNotEmpty) 'password': password,
        if (position != null && position.isNotEmpty) 'position': position,
        if (title != null && title.isNotEmpty) 'title': title,
      };
      final res = await _client.post('/api/users', payload);
      final data = res is Map ? res['data'] : null;
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> assignRole(int userId, {required String role, String? position, bool? temporary}) async {
    try {
      final payload = <String, dynamic>{
        'role': role,
        if (position != null && position.isNotEmpty) 'position': position,
        if (temporary != null) 'temporary': temporary,
      };
      final res = await _client.patch('/api/users/$userId/role', payload);
      final data = res is Map ? res['data'] : null;
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers({String? forRole, String? forEmail}) async {
    final query = <String, dynamic>{};
    if (forRole != null && forRole.isNotEmpty) query['forRole'] = forRole;
    if (forEmail != null && forEmail.isNotEmpty) query['forEmail'] = forEmail;
    final res = await _client.get('/api/users', query.isEmpty ? null : query);
    final data = res is Map ? res['data'] : res;
    if (data is! List) return [];
    return (data as List).map((e) => e as Map<String, dynamic>).toList();
  }

  /// Returns total user count from backend (for verification). Returns null on error.
  Future<int?> getUserCount() async {
    try {
      final res = await _client.get('/api/users/count');
      final data = res is Map ? res['data'] : null;
      if (data is Map && data['count'] != null) {
        final c = data['count'];
        if (c is int) return c;
        if (c is num) return c.toInt();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProjectTeam(int projectId) async {
    try {
      final res = await _client.get('/api/projects/$projectId/team');
      final data = res is Map ? res['data'] : null;
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> assignUserToProject(int userId, int projectId, String projectRole) async {
    try {
      final res = await _client.post('/api/users/$userId/assign-project', {'projectId': projectId, 'projectRole': projectRole});
      final data = res is Map ? res['data'] : null;
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final res = await _client.get('/api/users/$id');
      final data = res is Map ? res['data'] : null;
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUserProfile(int userId, {String? photoUrl, int? age, String? skills, bool? temporary}) async {
    try {
      final payload = <String, dynamic>{};
      if (photoUrl != null) payload['photoUrl'] = photoUrl;
      if (age != null) payload['age'] = age;
      if (skills != null) payload['skills'] = skills;
      if (temporary != null) payload['temporary'] = temporary;
      final res = await _client.patch('/api/users/$userId/profile', payload);
      final data = res is Map ? res['data'] : null;
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> createTask({
    required String title,
    String status = 'need_to_start',
    String? dueDate,
    int? assignedToId,
    int? projectId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'title': title,
        'status': status,
        if (dueDate != null) 'dueDate': dueDate,
        if (assignedToId != null) 'assignedToId': assignedToId,
        if (projectId != null) 'projectId': projectId,
      };
      await _client.post('/api/tasks', payload);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateTaskStatus({required String taskId, required String status}) async {
    try {
      await _client.patch('/api/tasks/$taskId/status', {'status': status});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _client.delete('/api/tasks/$taskId');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Kick (remove) user. Admin: anyone except admin. Manager: team leader or team member only.
  /// Returns [true] on success, [false] on failure. Use [kickUserWithMessage] to get error text.
  Future<bool> kickUser(int userId) async {
    final result = await kickUserWithMessage(userId);
    return result.$1;
  }

  /// Same as [kickUser] but returns (success, errorMessage). Error message is from backend when success is false.
  Future<(bool, String?)> kickUserWithMessage(int userId) async {
    try {
      await _client.delete('/api/users/$userId');
      return (true, null);
    } catch (e) {
      String? msg;
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        msg = data['message'] as String? ?? data['error'] as String?;
      }
      return (false, msg);
    }
  }

  Future<bool> assignTask({
    required int userId,
    required String taskTitle,
    String? dueDate,
    int? projectId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'userId': userId,
        'taskTitle': taskTitle,
        if (dueDate != null) 'dueDate': dueDate,
        if (projectId != null) 'projectId': projectId,
      };
      await _client.post('/api/tasks/assign', payload);
      return true;
    } catch (_) {
      return false;
    }
  }

  ProjectModel _projectFromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString(),
      status: json['status']?.toString(),
      progress: (json['progress'] is int) ? json['progress'] as int : int.tryParse(json['progress']?.toString() ?? '0') ?? 0,
    );
  }

  TaskModel _taskFromJson(Map<String, dynamic> json) {
    final aid = json['assigneeId'];
    final pid = json['projectId'];
    return TaskModel(
      id: (json['id'] ?? '').toString(),
      title: json['title']?.toString(),
      status: json['status']?.toString(),
      dueDate: json['dueDate']?.toString(),
      assigneeId: aid is int ? aid : (aid != null ? int.tryParse(aid.toString()) : null),
      assigneeName: json['assigneeName']?.toString(),
      projectId: pid is int ? pid : (pid != null ? int.tryParse(pid.toString()) : null),
      projectName: json['projectName']?.toString(),
    );
  }
}

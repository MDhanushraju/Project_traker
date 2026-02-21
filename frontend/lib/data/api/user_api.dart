import '../../../core/network/api_client.dart';
import '../../data/team_members_data.dart';

class UserApi {
  static final _client = ApiClient.instance;

  static Future<List<TeamMemberData>> getUsers() async {
    final json = await _client.get('/api/users');
    final data = json['data'];
    if (data is! List) return [];
    return (data as List).map((e) {
      final roleStr = e['role']?.toString() ?? 'member';
      final role = _parseRole(roleStr);
      return TeamMemberData(
        name: e['name']?.toString() ?? '',
        title: e['title']?.toString() ?? '',
        role: role,
        position: e['position']?.toString(),
        isTemporary: e['temporary'] == true,
      );
    }).toList();
  }

  static Future<List<String>> getTeamLeaderProjects() async {
    final json = await _client.get('/api/users/team-leader/projects');
    final data = json['data'];
    if (data is! List) return [];
    return (data as List).map((e) => e.toString()).toList();
  }

  static Future<Map<String, List<Map<String, String>>>> getTeamLeaderTeamMembers() async {
    final json = await _client.get('/api/users/team-leader/team-members');
    final data = json['data'];
    if (data is! Map) return {};
    final result = <String, List<Map<String, String>>>{};
    for (final entry in (data as Map).entries) {
      final key = entry.key.toString();
      final val = entry.value;
      if (val is List) {
        result[key] = (val as List)
            .map((e) => {
                  'name': e['name']?.toString() ?? '',
                  'title': e['title']?.toString() ?? '',
                  'position': e['position']?.toString() ?? '',
                })
            .toList();
      }
    }
    return result;
  }

  static Future<Map<String, String>> getTeamManager() async {
    final json = await _client.get('/api/users/team-leader/team-manager');
    final data = json['data'];
    if (data is! Map) return {'name': 'Team Manager', 'title': ''};
    return {
      'name': data['name']?.toString() ?? 'Team Manager',
      'title': data['title']?.toString() ?? '',
    };
  }

  static Future<List<String>> getMemberProjects() async {
    final json = await _client.get('/api/users/member/projects');
    final data = json['data'];
    if (data is! List) return [];
    return (data as List).map((e) => e.toString()).toList();
  }

  static Future<List<Map<String, String>>> getMemberContacts() async {
    final json = await _client.get('/api/users/member/contacts');
    final data = json['data'];
    if (data is! List) return [];
    return (data as List)
        .map((e) => {
              'name': e['name']?.toString() ?? '',
              'title': e['title']?.toString() ?? '',
              'type': e['type']?.toString() ?? '',
            })
        .toList();
  }

  static TeamMemberRole _parseRole(String s) {
    switch (s.toLowerCase()) {
      case 'manager':
        return TeamMemberRole.manager;
      case 'team_leader':
      case 'teamleader':
        return TeamMemberRole.teamLeader;
      default:
        return TeamMemberRole.teamMember;
    }
  }
}

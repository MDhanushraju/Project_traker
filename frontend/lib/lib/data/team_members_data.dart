/// Shared team member data. Used by Assign Project, Add Project, and Users.
/// Replace with API later.
class TeamMemberData {
  const TeamMemberData({
    required this.name,
    required this.title,
    required this.role,
    this.position,
    this.isTemporary = false,
  });

  final String name;
  final String title;
  final TeamMemberRole role;
  /// Position/team: Developer, Tester, Designer, etc.
  final String? position;
  final bool isTemporary;

  String get roleLabel {
    switch (role) {
      case TeamMemberRole.manager:
        return 'Team Manager';
      case TeamMemberRole.teamLeader:
        return 'Team Leader';
      case TeamMemberRole.teamMember:
        return 'Team Member';
    }
  }

  String get displayPosition =>
      isTemporary ? '$roleLabel (Temporary)' : roleLabel;
}

enum TeamMemberRole { manager, teamLeader, teamMember }

/// Mock team members. In real app, fetch from API.
List<TeamMemberData> get teamMembers => [
  const TeamMemberData(
    name: 'Sarah Jenkins',
    title: 'Director of Product Operations',
    role: TeamMemberRole.manager,
  ),
  const TeamMemberData(
    name: 'Marcus Thorne',
    title: 'Tech Lead',
    role: TeamMemberRole.teamLeader,
    position: 'Developer',
  ),
  const TeamMemberData(
    name: 'Elena Vance',
    title: 'Design Lead',
    role: TeamMemberRole.teamLeader,
    position: 'Designer',
  ),
  const TeamMemberData(
    name: 'David Chen',
    title: 'Lead Developer',
    role: TeamMemberRole.teamMember,
    position: 'Developer',
  ),
  const TeamMemberData(
    name: 'Sophie Walters',
    title: 'QA Engineer',
    role: TeamMemberRole.teamMember,
    position: 'Tester',
  ),
  const TeamMemberData(
    name: 'James Wilson',
    title: 'Backend Architect',
    role: TeamMemberRole.teamMember,
    position: 'Developer',
  ),
  const TeamMemberData(
    name: 'Maya Patel',
    title: 'Content Strategist',
    role: TeamMemberRole.teamMember,
    position: 'Analyst',
  ),
  const TeamMemberData(
    name: 'Elena Rodriguez',
    title: 'Senior UI Designer',
    role: TeamMemberRole.teamMember,
    position: 'Designer',
  ),
  const TeamMemberData(
    name: 'John Doe',
    title: 'Developer',
    role: TeamMemberRole.teamMember,
    position: 'Developer',
  ),
  const TeamMemberData(
    name: 'Mike Chen',
    title: 'Designer',
    role: TeamMemberRole.teamMember,
    position: 'Designer',
  ),
  const TeamMemberData(
    name: 'Sarah Kim',
    title: 'Analyst',
    role: TeamMemberRole.teamMember,
    position: 'Analyst',
    isTemporary: true,
  ),
];

List<TeamMemberData> membersByRole(TeamMemberRole role) =>
    teamMembers.where((m) => m.role == role).toList();

List<TeamMemberData> membersByPositionAndRole(String position, TeamMemberRole role) =>
    teamMembers.where((m) => m.position == position && m.role == role).toList();

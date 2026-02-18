import 'package:flutter/material.dart';

/// Card for a team member. Uses theme.
class TeamMemberCard extends StatelessWidget {
  const TeamMemberCard({super.key, this.name = ''});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(name)));
  }
}

import 'package:flutter/material.dart';

import '../models/subtask_model.dart';

/// List of subtasks. Uses theme.
class SubtaskList extends StatelessWidget {
  const SubtaskList({super.key, this.items = const []});

  final List<SubtaskModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, i) => CheckboxListTile(
        title: Text(items[i].title ?? ''),
        value: items[i].done,
        onChanged: (_) {},
      ),
    );
  }
}

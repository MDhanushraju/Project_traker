/// Subtask model.
class SubtaskModel {
  const SubtaskModel({this.id, this.title, this.done = false});

  final String? id;
  final String? title;
  final bool done;
}

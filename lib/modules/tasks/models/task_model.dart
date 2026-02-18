/// Task model. Add fromJson/toJson when wiring API.
class TaskModel {
  const TaskModel({
    this.id,
    this.title,
    this.status,
    this.dueDate,
  });

  final String? id;
  final String? title;
  final String? status;
  final String? dueDate;
}

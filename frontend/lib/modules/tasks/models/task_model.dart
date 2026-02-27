/// Task model. Add fromJson/toJson when wiring API.
class TaskModel {
  const TaskModel({
    this.id,
    this.title,
    this.status,
    this.dueDate,
    this.assigneeId,
    this.assigneeName,
    this.projectId,
    this.projectName,
  });

  final String? id;
  final String? title;
  final String? status;
  final String? dueDate;
  final int? assigneeId;
  final String? assigneeName;
  final int? projectId;
  final String? projectName;
}

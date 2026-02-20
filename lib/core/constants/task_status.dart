/// Task status values. Use for API and UI consistency.
class TaskStatus {
  TaskStatus._();

  static const String yetToStart = 'yet_to_start';
  static const String todo = 'todo';
  static const String inProgress = 'in_progress';
  static const String done = 'done';

  /// Display label for each status.
  static String label(String status) {
    switch (status) {
      case yetToStart:
        return 'Yet to Start';
      case todo:
        return 'Todo';
      case inProgress:
        return 'Ongoing';
      case done:
        return 'Completed';
      default:
        return status;
    }
  }
}

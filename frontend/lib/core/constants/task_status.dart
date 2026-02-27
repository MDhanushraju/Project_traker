/// Task status values. Use for API and UI consistency.
class TaskStatus {
  TaskStatus._();

  static const String needToStart = 'need_to_start';
  static const String ongoing = 'ongoing';
  static const String completed = 'completed';

  // Legacy aliases
  static const String yetToStart = 'need_to_start';
  static const String todo = 'need_to_start';
  static const String inProgress = 'ongoing';
  static const String done = 'completed';

  static const List<String> all = [needToStart, ongoing, completed];

  /// Display label for each status.
  static String label(String status) {
    switch (status) {
      case needToStart:
      case yetToStart:
      case todo:
        return 'Yet to start';
      case ongoing:
      case inProgress:
        return 'Ongoing';
      case completed:
      case done:
        return 'Completed';
      default:
        return status;
    }
  }
}

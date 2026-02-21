/// App date utilities (named to avoid clash with package/API names).
class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

/// DateTime extensions (formatting, relative time).
extension DateTimeExtensions on DateTime {
  String toDateString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

/// num/int/double extensions (formatting, padding).
extension NumExtensions on num {
  String pad(int width) => toString().padLeft(width, '0');
}

/// String extensions (validation, formatting).
extension StringExtensions on String {
  bool get isBlank => trim().isEmpty;
}

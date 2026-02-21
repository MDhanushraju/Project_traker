/// List extensions (safe access, helpers).
extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

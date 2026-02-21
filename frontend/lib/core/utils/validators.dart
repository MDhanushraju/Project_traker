/// Input validators. Use with form fields.
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final pattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    return pattern.hasMatch(value) ? null : 'Invalid email';
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }
}

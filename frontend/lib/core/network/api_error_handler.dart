/// Central API error handling. Map status codes to user messages.
class ApiErrorHandler {
  static String message(dynamic error) =>
      error?.toString() ?? 'Something went wrong';
}

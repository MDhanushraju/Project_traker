/// Request/response interceptor (e.g. add auth header). Use with [ApiClient].
class ApiInterceptor {
  void onRequest(Map<String, String> headers) {}
  void onResponse(int statusCode, dynamic body) {}
}

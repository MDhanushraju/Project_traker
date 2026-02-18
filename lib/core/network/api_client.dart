/// HTTP API client. Replace with dio/http when wiring real API.
class ApiClient {
  ApiClient({this.baseUrl});

  final String? baseUrl;

  Future<Map<String, dynamic>> get(String path) async => {};
  Future<Map<String, dynamic>> post(String path, [Object? body]) async => {};
}

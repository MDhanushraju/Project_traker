/// API base URL. For web: use localhost. For Android emulator: http://10.0.2.2:8080
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

/// API base URL: localhost only. No Render — use only your system's local backend.
const String kApiBaseUrlLocal = 'http://localhost:8080';

/// Disconnected: frontend does not call the real backend (connection will fail). Use to run UI without backend.
const String kApiBaseUrlDisconnected = 'http://127.0.0.1:0';

/// Current base URL. Set to [kApiBaseUrlDisconnected] to disconnect; set to [kApiBaseUrlLocal] to connect to backend.
String get currentApiBaseUrl => kApiBaseUrlLocal;

/// When true, no real API calls are made: [ApiClient] and auth/forgot/reset flows return mock/empty and never hit the network.
/// Set to false to use the backend again. Code is kept; APIs are just handicapped.
bool get apisHandicapped => false;

/// Legacy getter.
String get kApiBaseUrl => currentApiBaseUrl;

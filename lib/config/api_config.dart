class ApiConfig {
  // Base URL for all API requests (change this for different environments)
  static const String baseUrl = "https://findcamp.saragih.com";

  // API Endpoints (include /api here for compatibility)
  static const String loginEndpoint = "/api/login";
  static const String googleAuthEndpoint = "/api/auth/google/redirect";
  static const String googleCallbackEndpoint = "/api/auth/google/token";

  static const String regionsEndpoint = '$baseUrl/api/regions';
  static const String countriesEndpoint = '$baseUrl/api/countries';
  static const String requirementsEndpoint = '$baseUrl/api/requirements';
  // Default headers
  static Map<String, String> getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}

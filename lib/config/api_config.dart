class ApiConfig {
  // Base URL for all API requests (change this for different environments)
  static const String baseUrl = "https://findcamp.saragih.com";

  // API Endpoints (include baseUrl for all)
  static const String loginEndpoint = "$baseUrl/api/login";
  static const String googleAuthEndpoint = "$baseUrl/api/auth/google/redirect";
  static const String googleCallbackEndpoint = "$baseUrl/api/auth/google/token";
  static const String deviceManagementEndpoint = "$baseUrl/api/auth/devices";
  static const String regionsEndpoint = "$baseUrl/api/regions";
  static const String countriesEndpoint = "$baseUrl/api/countries";
  static const String requirementsEndpoint = "$baseUrl/api/requirements";

  // Default headers
  static Map<String, String> getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Platform': 'flutter',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}

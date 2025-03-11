class ApiConfig {
  // Base URL for all API requests (change this for different environments)
  static const String baseUrl = "https://findcamp.my-saragih.com";
  
  // API Endpoints
  static const String loginEndpoint = "/api/login";
  static const String googleAuthEndpoint = "/api/auth/google/redirect";
  static const String googleCallbackEndpoint = "/api/auth/google/token";

  static const String regionsEndpoint = '${baseUrl}/api/regions';
  static const String countriesEndpoint = '${baseUrl}/api/countries';
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

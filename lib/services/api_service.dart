import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static const String baseUrl = 'http://localhost:8000/api'; // TODO: Change to production URL
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  String? _token;

  ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  static ApiService get instance => _instance;

  /// Initialize the API service with stored token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(tokenKey);
  }

  /// Set the authentication token
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  /// Get the current auth token
  String? getToken() => _token;

  /// Clear the authentication token (logout)
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(refreshTokenKey);
  }

  /// Common headers for all requests
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  /// Perform a GET request
  Future<http.Response> get(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Perform a POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Perform a PUT request
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Perform a DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Handle response and throw errors for non-2xx status codes
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized: Token expired or invalid');
    } else if (response.statusCode == 403) {
      throw ApiException('Forbidden: Access denied');
    } else if (response.statusCode == 404) {
      throw ApiException('Not found');
    } else if (response.statusCode == 500) {
      throw ApiException('Server error');
    } else {
      throw ApiException('Request failed with status ${response.statusCode}');
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

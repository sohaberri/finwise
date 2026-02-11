import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

class AuthUser {
  final String userId;
  final String email;
  final String fullName;

  const AuthUser({
    required this.userId,
    required this.email,
    required this.fullName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['id'] ?? json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': userId,
    'email': email,
    'full_name': fullName,
  };
}

class AuthService extends ChangeNotifier {
  static const _kTokenKey = 'auth.token';
  static const _kRefreshTokenKey = 'auth.refresh_token';
  static const _kUserKey = 'auth.user';
  
  // Demo account credentials
  static const String demoEmail = '1234@gmail.com';
  static const String demoPassword = '1234';
  static const String demoFullName = 'soha';

  late SharedPreferences _prefs;
  late ApiService _apiService;
  bool _initialized = false;
  AuthUser? _currentUser;

  bool get isInitialized => _initialized;
  bool get isLoggedIn => _currentUser != null;
  AuthUser? get currentUser => _currentUser;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _apiService = ApiService();
    await _apiService.init();
    await _restoreSession();
    _initialized = true;
    notifyListeners();
  }

  /// Restore session from stored token and user data
  Future<void> _restoreSession() async {
    final token = _prefs.getString(_kTokenKey);
    final userJson = _prefs.getString(_kUserKey);

    if (token != null && userJson != null) {
      try {
        _apiService.setToken(token);
        _currentUser = AuthUser.fromJson(jsonDecode(userJson));
      } catch (e) {
        // Token or user data corrupted, clear session
        await logout();
      }
    }
  }

  /// Login with email and password
  /// Uses backend for production, demo account for testing
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // For demo/testing purposes, check if this is the demo account
      if (email == demoEmail && password == demoPassword) {
        // Create a demo token (in production, this would come from backend)
        final demoToken = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
        
        _currentUser = const AuthUser(
          userId: 'demo_user_001',
          email: demoEmail,
          fullName: demoFullName,
        );

        await _apiService.setToken(demoToken);
        await _prefs.setString(_kTokenKey, demoToken);
        await _prefs.setString(_kUserKey, jsonEncode(_currentUser!.toJson()));
        
        notifyListeners();
        return true;
      }

      // TODO: Replace with real backend call when available
      // const url = '/auth/login/';
      // final response = await _apiService.post(url, {
      //   'email': email,
      //   'password': password,
      // }, includeAuth: false);
      // 
      // final data = jsonDecode(response.body);
      // final token = data['access'] ?? data['token'];
      // final user = AuthUser.fromJson(data['user']);
      // 
      // await _apiService.setToken(token);
      // await _prefs.setString(_kTokenKey, token);
      // await _prefs.setString(_kUserKey, jsonEncode(user.toJson()));
      // _currentUser = user;
      // notifyListeners();
      // return true;

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Sign up with new account details
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with real backend call when available
      // const url = '/auth/signup/';
      // final response = await _apiService.post(url, {
      //   'full_name': fullName,
      //   'email': email,
      //   'password': password,
      // }, includeAuth: false);
      // 
      // final data = jsonDecode(response.body);
      // final token = data['access'] ?? data['token'];
      // final user = AuthUser.fromJson(data['user']);
      // 
      // await _apiService.setToken(token);
      // await _prefs.setString(_kTokenKey, token);
      // await _prefs.setString(_kUserKey, jsonEncode(user.toJson()));
      // _currentUser = user;
      // notifyListeners();
      // return true;

      // For now, demo signup (in real version, auto-login after signup)
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      // TODO: Replace with real backend call when available
      // const url = '/auth/logout/';
      // await _apiService.post(url, {});
    } catch (e) {
      // Continue logout even if backend call fails
    }

    await _apiService.clearToken();
    await _prefs.remove(_kTokenKey);
    await _prefs.remove(_kRefreshTokenKey);
    await _prefs.remove(_kUserKey);
    
    _currentUser = null;
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with real backend call when available
      // const url = '/api/user/profile/';
      // final response = await _apiService.put(url, {
      //   'full_name': fullName,
      //   'email': email,
      //   'password': password,
      // });
      // 
      // final data = jsonDecode(response.body);
      // final newToken = data['access'] ?? data['token'];
      // final updatedUser = AuthUser.fromJson(data['user']);
      // 
      // await _apiService.setToken(newToken);
      // await _prefs.setString(_kTokenKey, newToken);
      // await _prefs.setString(_kUserKey, jsonEncode(updatedUser.toJson()));
      // _currentUser = updatedUser;
      // notifyListeners();
      // return true;

      // Demo version: update locally
      if (_currentUser != null) {
        _currentUser = AuthUser(
          userId: _currentUser!.userId,
          email: email,
          fullName: fullName,
        );
        await _prefs.setString(_kUserKey, jsonEncode(_currentUser!.toJson()));
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get current auth token
  String? getToken() => _apiService.getToken();
}

class AuthScope extends InheritedNotifier<AuthService> {
  const AuthScope({
    super.key,
    required AuthService auth,
    required Widget child,
  }) : super(notifier: auth, child: child);

  static AuthService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in widget tree.');
    return scope!.notifier!;
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String email;
  final String fullName;

  const AuthUser({
    required this.email,
    required this.fullName,
  });
}

class AuthService extends ChangeNotifier {
  static const _kPasswordKey = 'auth.password';
  static const _kEmailKey = 'auth.email';
  static const _kFullNameKey = 'auth.full_name';
  static const _kCurrentUserKey = 'auth.current_user_email';

  late SharedPreferences _prefs;
  bool _initialized = false;
  AuthUser? _currentUser;

  bool get isInitialized => _initialized;
  bool get isLoggedIn => _currentUser != null;
  AuthUser? get currentUser => _currentUser;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _seedDemoAccountIfNeeded();
    await _restoreSession();
    _initialized = true;
  }

  Future<void> _seedDemoAccountIfNeeded() async {
    if (_prefs.containsKey(_kEmailKey)) {
      return;
    }

    // TODO: Replace with backend seed or remove when real auth is added.
    await _prefs.setString(_kPasswordKey, '1234');
    await _prefs.setString(_kEmailKey, '1234@gmail.com');
    await _prefs.setString(_kFullNameKey, 'soha');
  }

  Future<void> _restoreSession() async {
    final activeUser = _prefs.getString(_kCurrentUserKey);
    if (activeUser == null) {
      _currentUser = null;
      return;
    }

    final storedEmail = _prefs.getString(_kEmailKey);
    if (storedEmail != activeUser) {
      await _prefs.remove(_kCurrentUserKey);
      _currentUser = null;
      return;
    }

    _currentUser = AuthUser(
      email: storedEmail ?? '',
      fullName: _prefs.getString(_kFullNameKey) ?? '',
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // TODO: Replace with backend auth call.
    final storedEmail = _prefs.getString(_kEmailKey);
    final storedPassword = _prefs.getString(_kPasswordKey);

    final isMatch = password == storedPassword && email == storedEmail;

    if (!isMatch) {
      return false;
    }

    await _prefs.setString(_kCurrentUserKey, storedEmail ?? '');
    _currentUser = AuthUser(
      email: storedEmail ?? '',
      fullName: _prefs.getString(_kFullNameKey) ?? '',
    );
    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // TODO: Replace with backend signup call and validation.
    await _prefs.setString(_kPasswordKey, password);
    await _prefs.setString(_kEmailKey, email);
    await _prefs.setString(_kFullNameKey, fullName);

    await _prefs.remove(_kCurrentUserKey);
    _currentUser = null;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    // TODO: Replace with backend session revoke.
    await _prefs.remove(_kCurrentUserKey);
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // TODO: Replace with backend update call.
    // Backend should:
    // 1. Validate email format and ensure it's unique
    // 2. Securely hash and store the new password
    // 3. Update user's fullName, email, and password
    // 4. Invalidate old tokens and return new auth tokens
    // 5. Handle any validation errors and return appropriate error messages

    // Local update for demo
    await _prefs.setString(_kFullNameKey, fullName);
    await _prefs.setString(_kEmailKey, email);
    await _prefs.setString(_kPasswordKey, password);

    // Update current user
    _currentUser = AuthUser(
      email: email,
      fullName: fullName,
    );
    notifyListeners();
  }
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

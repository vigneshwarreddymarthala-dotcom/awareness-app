import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local auth for development/testing.
/// Users are stored as a JSON map in localStorage (SharedPreferences on web).
/// Passwords are kept in plain text — this is intentional for a testing tool.
class LocalAuthService {
  static const _usersKey = 'local_auth_users';
  static const _sessionKey = 'local_auth_session';

  static Map<String, String> _users = {}; // email → password
  static String? _sessionEmail;

  static bool get isLoggedIn => _sessionEmail != null;
  static String? get currentEmail => _sessionEmail;

  // ── Init ─────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_usersKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _users = decoded.cast<String, String>();
    }

    _sessionEmail = prefs.getString(_sessionKey);

    // Pre-seed a test account if none exist
    if (!_users.containsKey('test@test.com')) {
      _users['test@test.com'] = '1234';
      await _persistUsers(prefs);
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  /// Returns an error string on failure, or null on success.
  /// Automatically logs the new user in on success.
  static Future<String?> signUp(String email, String password) async {
    email = email.trim().toLowerCase();

    if (!_validEmailShape(email)) return 'Enter a valid email address.';
    if (password.length < 4) return 'Password must be at least 4 characters.';
    if (_users.containsKey(email)) return 'An account with this email already exists.';

    final prefs = await SharedPreferences.getInstance();
    _users[email] = password;
    await _persistUsers(prefs);

    _sessionEmail = email;
    await prefs.setString(_sessionKey, email);
    return null;
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  /// Returns an error string on failure, or null on success.
  static Future<String?> signIn(String email, String password) async {
    email = email.trim().toLowerCase();

    if (!_users.containsKey(email)) {
      return 'No account found for this email.';
    }
    if (_users[email] != password) {
      return 'Incorrect password.';
    }

    final prefs = await SharedPreferences.getInstance();
    _sessionEmail = email;
    await prefs.setString(_sessionKey, email);
    return null;
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    _sessionEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Future<void> _persistUsers(SharedPreferences prefs) async {
    await prefs.setString(_usersKey, jsonEncode(_users));
  }

  static bool _validEmailShape(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
}

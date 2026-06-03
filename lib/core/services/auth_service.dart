import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  static bool get isLoggedIn => _client.auth.currentUser != null;

  static Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      if (response.user == null) return 'Sign up failed. Please try again.';
      return null;
    } on AuthException catch (e) {
      return _friendlyError(e.message);
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }

  static Future<String?> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', rememberMe);
      return null;
    } on AuthException catch (e) {
      return _friendlyError(e.message);
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
  }

  // On cold start: sign out if user previously logged in without "Remember Me"
  static Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('rememberMe') ?? true)) {
      await _client.auth.signOut();
    }
  }

  // Attempt to pre-create the test account; silently ignores if it already exists
  static Future<void> seedTestAccount() async {
    try {
      await _client.auth.signUp(
        email: 'test@gmail.com',
        password: 'Password123!',
        data: {'full_name': 'Test User'},
      );
    } catch (_) {}
  }

  static String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login') ||
        lower.contains('invalid credentials') ||
        lower.contains('invalid email or password')) {
      return 'Invalid email or password.';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists') ||
        lower.contains('email address is already used') ||
        lower.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email before logging in.';
    }
    if (lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lower.contains('weak password') || lower.contains('password')) {
      return 'Password must be at least 8 characters with uppercase and numbers.';
    }
    return raw;
  }
}

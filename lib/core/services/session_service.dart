import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static String? currentUserEmail;

  static Future<void> login(String email) async {
    currentUserEmail = email;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('currentUserEmail', email);
  }

  static Future<void> logout() async {
    currentUserEmail = null;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('currentUserEmail');
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    currentUserEmail = prefs.getString('currentUserEmail');
  }

  static bool isLoggedIn() {
    return currentUserEmail != null;
  }
}

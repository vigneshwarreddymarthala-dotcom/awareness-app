import 'local_auth_service.dart';

class SessionService {
  static String? get currentUserEmail => LocalAuthService.currentEmail;

  // Full name not stored in local auth — fall back to email
  static String? get currentUserFullName => LocalAuthService.currentEmail;

  static bool isLoggedIn() => LocalAuthService.isLoggedIn;

  // No-ops kept for call-site compatibility
  static Future<void> loadSession() async {}
  static Future<void> login(String email) async {}
  static Future<void> logout() async {}
}

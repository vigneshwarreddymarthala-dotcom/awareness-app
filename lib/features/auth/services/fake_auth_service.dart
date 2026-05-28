class FakeAuthService {
  static final List<Map<String, String>> users = [
    {'email': 'test@gmail.com', 'password': '123456', 'username': 'Test User'},
  ];

  static Map<String, String>? currentUser;

  static bool login(String email, String password) {
    try {
      final user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
      );

      currentUser = user;

      return true;
    } catch (e) {
      return false;
    }
  }

  static bool signup(String username, String email, String password) {
    final exists = users.any((user) => user['email'] == email);

    if (exists) {
      return false;
    }

    users.add({'username': username, 'email': email, 'password': password});

    return true;
  }
}

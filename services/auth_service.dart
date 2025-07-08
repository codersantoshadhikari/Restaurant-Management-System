import '../models/user.dart';
import '../utils/file_handler.dart';

class AuthService {
  static const String _usersFile = 'data/users.json';

  static Future<User> login(String username, String password) async {
    final data = await FileHandler.readJson(_usersFile);
    final userMap = (data['users'] as List).firstWhere(
      (u) => u['username'] == username && u['password'] == password,
      orElse: () => throw Exception('Invalid credentials'),
    );
    return User(
      username: userMap['username'] as String,
      password: userMap['password'] as String,
      role: userMap['role'] as String,
    );
  }
}

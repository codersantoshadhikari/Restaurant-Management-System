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
    return User.fromJson(
      userMap,
    ); //SIMPLE JSON SERIALIZATION CONCEPT DEFINED IN models/user.dart
  }

  static Future<void> verifyAdmin(User user) async {
    if (user.role != 'admin') {
      throw Exception('Only admins can perform this action');
    }
  }
}

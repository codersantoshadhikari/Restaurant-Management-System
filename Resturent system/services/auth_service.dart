import 'dart:async';

import '../models/user.dart';
import '../utils/file_handler.dart';

class AuthService {
  List<User> _users = [];

  List<User> get users => _users;

  Future<void> loadUsers() async {
    final data = await FileHandler.loadJsonFile(FileHandler.usersFile);
    _users = data.map((user) => User.fromJson(user)).toList();
  }

  Future<void> saveUsers() async {
    await FileHandler.saveJsonFile(
      FileHandler.usersFile,
      _users.map((user) => user.toJson()).toList(),
    );
  }

  User? authenticate(String email, String password) {
    return _users.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => User(
        id: '',
        name: '',
        email: '',
        password: '',
        role: 'guest',
      ),  

    );  
  }

  Future<void> addUser(User user) async {
    _users.add(user);
    await saveUsers();
  }

  Future<void> updateUser(String id, User updatedUser) async {
    final index = _users.indexWhere((user) => user.id == id);
    if (index != -1) {
      _users[index] = updatedUser;
      await saveUsers();
    }
  }

  Future<void> deleteUser(String id) async {
    _users.removeWhere((user) => user.id == id);
    await saveUsers();
  }

  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }
}
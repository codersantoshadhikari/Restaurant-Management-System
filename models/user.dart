class User {
  final String username;
  final String password;
  final String role;

  User({required this.username, required this.password, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password, 'role': role};
  }
}

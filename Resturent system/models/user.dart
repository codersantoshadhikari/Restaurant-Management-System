class User {
  final String id;
  final String name;
  final String email;
  final String password; // In a real app, store hashed passwords
  final String role; // 'admin', 'manager', 'staff'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
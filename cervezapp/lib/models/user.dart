// v1.6 - models/user.dart
class User {
  final int id;
  final String username;
  final String email;
  final String password; // En producción debería estar hasheada
  final String fullName;
  final String role; // 'admin' o 'worker'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  // Getters para verificar roles
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isWorker => role.toLowerCase() == 'worker';

  // Método para crear una copia con cambios
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? fullName,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  // Método para convertir a Map (útil para persistencia)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Método para crear desde Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'worker',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      lastLogin: map['lastLogin'] != null ? DateTime.tryParse(map['lastLogin']) : null,
      isActive: map['isActive'] ?? true,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, fullName: $fullName, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


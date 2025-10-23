// v1.6 - models/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id; // Cambiado a String? para Firestore
  final String username;
  final String email;
  final String password; // En producción debería estar hasheada
  final String fullName;
  final String role; // 'admin' o 'worker'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final DateTime? updatedAt; // Agregado para Firestore

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.updatedAt,
  });

  // Getters para verificar roles
  bool get isAdmin => role.toLowerCase() == 'admin';

  // Método para crear una copia con cambios
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? fullName,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método para convertir a Map (útil para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  // Método para crear desde Map (desde Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'worker',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, fullName: $fullName, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


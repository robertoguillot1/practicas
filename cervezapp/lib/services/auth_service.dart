// v1.6 - services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  final List<User> _users = [];

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isWorker => _currentUser?.isWorker ?? false;

  // Inicializar con usuario admin por defecto
  AuthService() {
    _initializeDefaultUsers();
  }

  void _initializeDefaultUsers() {
    // Usuario administrador por defecto
    final adminUser = User(
      id: 1,
      username: 'admin',
      email: 'admin@cervezapp.com',
      password: 'admin123', // En producción debería estar hasheada
      fullName: 'Administrador',
      role: 'admin',
      createdAt: DateTime.now(),
    );

    _users.add(adminUser);
  }

  // Método para cargar usuarios desde SharedPreferences
  Future<void> loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users');
      
      if (usersJson != null) {
        final List<dynamic> usersList = json.decode(usersJson);
        _users.clear();
        _users.addAll(usersList.map((userMap) => User.fromMap(userMap)));
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  // Método para guardar usuarios en SharedPreferences
  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = json.encode(_users.map((user) => user.toMap()).toList());
      await prefs.setString('users', usersJson);
    } catch (e) {
      debugPrint('Error saving users: $e');
    }
  }

  // Método para cargar usuario actual desde SharedPreferences
  Future<void> loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');
      
      if (userJson != null) {
        final userMap = json.decode(userJson);
        _currentUser = User.fromMap(userMap);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  // Método para guardar usuario actual en SharedPreferences
  Future<void> _saveCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        final userJson = json.encode(_currentUser!.toMap());
        await prefs.setString('currentUser', userJson);
      }
    } catch (e) {
      debugPrint('Error saving current user: $e');
    }
  }

  // Método para limpiar usuario actual
  Future<void> _clearCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');
    } catch (e) {
      debugPrint('Error clearing current user: $e');
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Buscar usuario por username o email
      final user = _users.firstWhere(
        (user) => (user.username.toLowerCase() == username.toLowerCase() ||
                  user.email.toLowerCase() == username.toLowerCase()) &&
                  user.password == password &&
                  user.isActive,
        orElse: () => throw Exception('Usuario no encontrado'),
      );

      _currentUser = user.copyWith(lastLogin: DateTime.now());
      await _saveCurrentUser();
      
      _isLoading = false;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "✅ Bienvenido, ${user.fullName}",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "❌ Usuario o contraseña incorrectos",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      return false;
    }
  }

  // Registro
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validar que el username no exista
      if (_users.any((user) => user.username.toLowerCase() == username.toLowerCase())) {
        throw Exception('El nombre de usuario ya existe');
      }

      // Validar que el email no exista
      if (_users.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
        throw Exception('El email ya está registrado');
      }

      // Crear nuevo usuario
      final newUser = User(
        id: _users.isEmpty ? 1 : _users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1,
        username: username,
        email: email,
        password: password, // En producción debería estar hasheada
        fullName: fullName,
        role: role,
        createdAt: DateTime.now(),
      );

      _users.add(newUser);
      await _saveUsers();

      _isLoading = false;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "✅ Usuario registrado correctamente",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "❌ ${e.toString().replaceFirst('Exception: ', '')}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    await _clearCurrentUser();
    notifyListeners();

    Fluttertoast.showToast(
      msg: "👋 Sesión cerrada",
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  // Cambiar contraseña
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;

    if (_currentUser!.password != currentPassword) {
      Fluttertoast.showToast(
        msg: "❌ Contraseña actual incorrecta",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }

    try {
      final userIndex = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (userIndex >= 0) {
        _users[userIndex] = _users[userIndex].copyWith(password: newPassword);
        _currentUser = _users[userIndex];
        await _saveUsers();
        await _saveCurrentUser();
        notifyListeners();

        Fluttertoast.showToast(
          msg: "✅ Contraseña actualizada",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        return true;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "❌ Error al cambiar contraseña",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    return false;
  }

  // Actualizar perfil
  Future<bool> updateProfile({
    String? username,
    String? email,
    String? fullName,
  }) async {
    if (_currentUser == null) return false;

    try {
      final userIndex = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (userIndex >= 0) {
        _users[userIndex] = _users[userIndex].copyWith(
          username: username,
          email: email,
          fullName: fullName,
        );
        _currentUser = _users[userIndex];
        await _saveUsers();
        await _saveCurrentUser();
        notifyListeners();

        Fluttertoast.showToast(
          msg: "✅ Perfil actualizado",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        return true;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "❌ Error al actualizar perfil",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    return false;
  }

  // Obtener todos los usuarios (solo para admin)
  List<User> getAllUsers() {
    return List.unmodifiable(_users);
  }

  // Activar/Desactivar usuario (solo para admin)
  Future<bool> toggleUserStatus(int userId) async {
    if (!isAdmin) return false;

    try {
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex >= 0) {
        _users[userIndex] = _users[userIndex].copyWith(
          isActive: !_users[userIndex].isActive,
        );
        await _saveUsers();
        notifyListeners();

        Fluttertoast.showToast(
          msg: "✅ Estado de usuario actualizado",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        return true;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "❌ Error al actualizar usuario",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    return false;
  }
}


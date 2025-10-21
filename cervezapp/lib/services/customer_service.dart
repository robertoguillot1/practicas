// v1.6 - services/customer_service.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/customer.dart';

class CustomerService extends ChangeNotifier {
  final List<Customer> _customers = [
    Customer(id: 1, name: 'Juan Pérez', email: 'juanperez@mail.com', phone: '3011234567'),
    Customer(id: 2, name: 'María Gómez', email: 'mariagomez@mail.com', phone: '3027654321'),
    Customer(id: 3, name: 'Andrés López', email: 'andreslopez@mail.com', phone: '3009988776'),
  ];

  int _nextId = 4;

  List<Customer> get customers => List.unmodifiable(_customers);

  void addCustomer(String name, {String? email, String? phone}) {
    if (name.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "El nombre del cliente no puede estar vacío",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return;
    }

    // Validar email si se proporciona
    if (email != null && email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        Fluttertoast.showToast(
          msg: "El formato del email no es válido",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
        return;
      }
    }

    // Validar teléfono si se proporciona
    if (phone != null && phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^[0-9]{10}$');
      if (!phoneRegex.hasMatch(phone)) {
        Fluttertoast.showToast(
          msg: "El teléfono debe tener 10 dígitos",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
        return;
      }
    }

    final c = Customer(id: _nextId++, name: name.trim(), email: email?.trim(), phone: phone?.trim());
    _customers.add(c);
    notifyListeners();

    Fluttertoast.showToast(
      msg: "✅ Cliente agregado: $name",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void updateCustomer(Customer updated) {
    final i = _customers.indexWhere((c) => c.id == updated.id);
    if (i >= 0) {
      _customers[i] = updated;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "📝 Cliente actualizado: ${updated.name}",
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
      );
    }
  }

  void deleteCustomer(int id) {
    final removed = _customers.firstWhere(
          (c) => c.id == id,
      orElse: () => Customer.empty(),
    );

    if (removed.id != 0) {
      _customers.removeWhere((c) => c.id == id);
      notifyListeners();

      Fluttertoast.showToast(
        msg: "🗑️ Cliente eliminado: ${removed.name}",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
    }
  }

  Customer getById(int id) =>
      _customers.firstWhere((c) => c.id == id, orElse: () => Customer.empty());
}

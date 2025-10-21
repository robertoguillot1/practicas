// v1.6 - models/customer.dart
class Customer {
  final int id;
  String name;
  String? email;
  String? phone;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });

  factory Customer.empty() => Customer(id: 0, name: '', email: null, phone: null);
}

// v1.6 - models/sale.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String? id; // Cambiar a String para Firestore
  final DateTime date;
  final String? customerId; // Cambiar a String para Firestore
  final String? productId; // Cambiar a String para Firestore
  final int quantity;
  final double total;
  String paymentType; // 'Cash', 'Nequi', 'Pending'
  String? paymentReceipt; // Path to receipt image for Nequi payments
  final DateTime createdAt;
  final DateTime updatedAt;
  
  bool get isPending => paymentType.toLowerCase() == 'pending';
  bool get hasReceipt => paymentReceipt != null && paymentReceipt!.isNotEmpty;

  Sale({
    this.id,
    required this.date,
    this.customerId,
    required this.productId,
    required this.quantity,
    required this.total,
    this.paymentType = 'Cash',
    this.paymentReceipt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Método para convertir a Map (útil para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'customerId': customerId,
      'productId': productId,
      'quantity': quantity,
      'total': total,
      'paymentType': paymentType,
      'paymentReceipt': paymentReceipt,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Método para crear desde Map
  factory Sale.fromMap(Map<String, dynamic> map, String id) {
    return Sale(
      id: id,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      customerId: map['customerId'],
      productId: map['productId'],
      quantity: map['quantity'] ?? 0,
      total: (map['total'] ?? 0.0).toDouble(),
      paymentType: map['paymentType'] ?? 'Cash',
      paymentReceipt: map['paymentReceipt'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Método para crear una copia con cambios
  Sale copyWith({
    String? id,
    DateTime? date,
    String? customerId,
    String? productId,
    int? quantity,
    double? total,
    String? paymentType,
    String? paymentReceipt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sale(
      id: id ?? this.id,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      paymentType: paymentType ?? this.paymentType,
      paymentReceipt: paymentReceipt ?? this.paymentReceipt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Sale(id: $id, date: $date, customerId: $customerId, productId: $productId, quantity: $quantity, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sale && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

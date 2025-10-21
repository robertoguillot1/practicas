// v1.6 - models/sale.dart
import 'customer.dart';

class Sale {
  final int id;
  final DateTime date;
  final int customerId;
  final int productId;
  final int quantity;
  final double total;
  String paymentType; // 'Cash', 'Nequi', 'Pending'
  String? paymentReceipt; // Path to receipt image for Nequi payments
  
  bool get isPending => paymentType.toLowerCase() == 'pending';
  bool get hasReceipt => paymentReceipt != null && paymentReceipt!.isNotEmpty;

  Sale({
    required this.id,
    required this.date,
    required this.customerId,
    required this.productId,
    required this.quantity,
    required this.total,
    this.paymentType = 'Cash',
    this.paymentReceipt,
  });
}

import 'package:flutter/material.dart';
import '../models/venta.dart';
import '../utils/formatters.dart';

class VentaCard extends StatelessWidget {
  final Venta venta;

  const VentaCard({required this.venta});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: const Icon(Icons.local_drink, color: Colors.amber),
        title: Text('${venta.cerveza} x${venta.cantidad}'),
        subtitle: Text(
            '${venta.metodoPago} - ${formatCurrency(venta.total)}\n${formatDate(venta.fecha)}'),
      ),
    );
  }
}

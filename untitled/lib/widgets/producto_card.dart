import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../utils/formatters.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({required this.producto});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_drink, color: Colors.amber[700], size: 50),
          const SizedBox(height: 10),
          Text(producto.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(formatCurrency(producto.precio)),
        ],
      ),
    );
  }
}

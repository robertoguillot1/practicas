import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../widgets/producto_card.dart';
import '../utils/constants.dart';

class ProductosScreen extends StatelessWidget {
  final List<Producto> productos = preciosCerveza.entries
      .map((entry) => Producto(nombre: entry.key, precio: entry.value))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cervezas disponibles')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 3 / 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: productos.length,
        itemBuilder: (context, i) => ProductoCard(producto: productos[i]),
      ),
    );
  }
}

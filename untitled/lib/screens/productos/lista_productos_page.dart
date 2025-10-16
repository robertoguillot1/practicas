import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '../../widgets/producto_card.dart';
import 'agregar_producto_page.dart';
import 'editar_producto_page.dart';

class ListaProductosPage extends StatefulWidget {
  const ListaProductosPage({super.key});

  @override
  State<ListaProductosPage> createState() => _ListaProductosPageState();
}

class _ListaProductosPageState extends State<ListaProductosPage> {
  List<Producto> productos = [
    Producto(nombre: 'Poker', precio: 3500, cantidad: 12),
    Producto(nombre: 'Águila', precio: 3300, cantidad: 8),
    Producto(nombre: 'Coronita', precio: 5000, cantidad: 15),
  ];

  void agregarProducto(Producto nuevo) {
    setState(() {
      productos.add(nuevo);
    });
  }

  void editarProducto(int index, Producto actualizado) {
    setState(() {
      productos[index] = actualizado;
    });
  }

  void eliminarProducto(int index) {
    setState(() {
      productos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Cervezas')),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return ProductoCard(
            producto: producto,
            onEdit: () async {
              final actualizado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditarProductoPage(producto: producto),
                ),
              );
              if (actualizado != null) editarProducto(index, actualizado);
            },
            onDelete: () => eliminarProducto(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final nuevo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgregarProductoPage()),
          );
          if (nuevo != null) agregarProducto(nuevo);
        },
      ),
    );
  }
}

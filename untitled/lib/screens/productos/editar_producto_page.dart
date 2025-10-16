import 'package:flutter/material.dart';
import '../../models/producto.dart';

class EditarProductoPage extends StatefulWidget {
  final Producto producto;
  const EditarProductoPage({super.key, required this.producto});

  @override
  State<EditarProductoPage> createState() => _EditarProductoPageState();
}

class _EditarProductoPageState extends State<EditarProductoPage> {
  late TextEditingController nombreController;
  late TextEditingController precioController;
  late TextEditingController cantidadController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.producto.nombre);
    precioController = TextEditingController(text: widget.producto.precio.toString());
    cantidadController = TextEditingController(text: widget.producto.cantidad.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cerveza')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final actualizado = Producto(
                  nombre: nombreController.text,
                  precio: double.tryParse(precioController.text) ?? 0,
                  cantidad: int.tryParse(cantidadController.text) ?? 0,
                );
                Navigator.pop(context, actualizado);
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}

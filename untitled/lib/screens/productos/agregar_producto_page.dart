import 'package:flutter/material.dart';
import '../../models/producto.dart';

class AgregarProductoPage extends StatefulWidget {
  const AgregarProductoPage({super.key});

  @override
  State<AgregarProductoPage> createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AgregarProductoPage> {
  final nombreController = TextEditingController();
  final precioController = TextEditingController();
  final cantidadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Cerveza')),
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
                final nuevo = Producto(
                  nombre: nombreController.text,
                  precio: double.tryParse(precioController.text) ?? 0,
                  cantidad: int.tryParse(cantidadController.text) ?? 0,
                );
                Navigator.pop(context, nuevo);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/venta.dart';
import '../widgets/venta_card.dart';
import '../utils/constants.dart';

class VentasScreen extends StatefulWidget {
  @override
  _VentasScreenState createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final List<Venta> _ventas = [];

  final List<String> cervezas = ['Poker', 'Águila', 'Coronita'];
  final List<String> metodos = ['Efectivo', 'Nequi'];
  String? cervezaSeleccionada;
  String? metodoSeleccionado;
  int cantidad = 1;

  final _formKey = GlobalKey<FormState>();

  void _registrarVenta() {
    if (cervezaSeleccionada != null && metodoSeleccionado != null) {
      final nuevaVenta = Venta(
        cerveza: cervezaSeleccionada!,
        cantidad: cantidad,
        metodoPago: metodoSeleccionado!,
        total: cantidad * preciosCerveza[cervezaSeleccionada]!,
        fecha: DateTime.now(),
      );

      setState(() {
        _ventas.add(nuevaVenta);
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Venta registrada correctamente')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Venta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Cerveza'),
                    items: cervezas
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) => setState(() => cervezaSeleccionada = value),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => cantidad = int.tryParse(val) ?? 1,
                  ),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Método de pago'),
                    items: metodos
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (value) => setState(() => metodoSeleccionado = value),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _registrarVenta,
                    child: const Text('Guardar Venta'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _ventas.length,
                itemBuilder: (context, index) =>
                    VentaCard(venta: _ventas[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

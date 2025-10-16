import 'package:flutter/material.dart';

class EstadisticasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas de ventas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Total vendido: \$500.000', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Efectivo: \$300.000', style: TextStyle(fontSize: 18)),
            Text('Nequi: \$200.000', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CervezApp 🍺')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.local_drink, size: 90, color: Colors.amber),
            SizedBox(height: 20),
            Text(
              'Bienvenido a CervezApp',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Administra tus ventas y ganancias fácilmente',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

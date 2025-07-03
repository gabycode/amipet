import 'package:flutter/material.dart';
import 'mascotas_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AmiPet'), centerTitle: true),
      body: Center(
        child: ElevatedButton(
          child: const Text('Explorar Mascotas'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MascotasPage()),
            );
          },
        ),
      ),
    );
  }
}

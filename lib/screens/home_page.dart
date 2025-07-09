import 'package:amipet/screens/registro_mascotas.dart';
import 'package:flutter/material.dart';
import 'mascotas_page.dart';
import 'pet_detail_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AmiPet'), centerTitle: true),
      body: Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ElevatedButton(
        child: const Text('Explorar Mascotas'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MascotasPage()),
          );
        },
      ),
      const SizedBox(height: 16), // Espacio entre botones
      ElevatedButton(
        child: const Text('Datos de Mascotas'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PetDetailScreen()),
          );
        },
      ),
      const SizedBox(height: 16), // Espacio entre botones
      ElevatedButton(
        child: const Text('Registrar Mascotas'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegistroMascotaScreen()),
          );
        },
      ),
    ],
  ),
),
    );
  }
}

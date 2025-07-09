import 'package:flutter/material.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: Color(0xff355f2e),
                ),
              ),
              const Text(
                'Detalles',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff355f2e),
                ),
              ),
              const Icon(Icons.pets, size: 28, color: Color(0xff355f2e)),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage(
                'assets/coco.jpeg',
              ), // Asegúrate de tener esta imagen
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Coco',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff355f2e),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3D5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Perro mariposa',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4C45),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Coco es un perrito de raza Papillón, pequeño, lleno de energía y con un corazón enorme. Tiene unos ojos vivaces y curiosos, y sus orejitas en forma de mariposa lo hacen simplemente adorable. Con su pelaje blanco y manchas color canela, Coco no solo es hermoso, sino también muy inteligente y cariñoso.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6F4C45),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconInfo(
                      icon: Icons.fastfood,
                      label: 'Comida',
                      value: 'Purina',
                    ),
                    IconInfo(
                      icon: Icons.female,
                      label: 'Género',
                      value: 'Hembra',
                    ),
                    IconInfo(
                      icon: Icons.calendar_today,
                      label: 'Edad',
                      value: '9 meses',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IconInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const IconInfo({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.brown),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.brown)),
      ],
    );
  }
}

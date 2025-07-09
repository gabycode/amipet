import 'package:flutter/material.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

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
                'Perfil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff355f2e),
                ),
              ),
              const Icon(Icons.person, size: 28, color: Color(0xff355f2e)),
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage(
                'assets/user_avatar.png', // Coloca una imagen de usuario
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Zuhaila Liscano',
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
                  'Desarrolladora de apps móviles',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4C45),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Zuhaila es una estudiante apasionada por la tecnología, especializada en desarrollo multiplataforma. Le encanta crear interfaces amigables, resolver problemas técnicos y seguir aprendiendo cada día.',
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
                      icon: Icons.email,
                      label: 'Correo',
                      value: 'zuhaila@email.com',
                    ),
                    IconInfo(
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: '809-123-4567',
                    ),
                    IconInfo(
                      icon: Icons.badge,
                      label: 'Rol',
                      value: 'Estudiante',
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

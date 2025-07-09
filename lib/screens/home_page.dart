import 'package:amipet/screens/registro_mascotas.dart';
import 'package:amipet/screens/user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mascotas_page.dart';
import 'pet_detail_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final TextStyle titleStyle = GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF2E5E2B),
    );

    final TextStyle subtitleStyle = GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFA8CD89),
    );

    return Scaffold(
  backgroundColor: const Color(0xFFF4FFE8),
  appBar: AppBar(title: const Text('AmiPet'), centerTitle: true), 
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            ...
          ),

          const SizedBox(height: 30),
          Text(...),
          ...

          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Datos de Mascotas'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PetDetailScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Registrar Mascotas'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegistroMascotaScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Datos de Usuario'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserDetailScreen()),
              );
            },
          ),
        ],
      ),
    ),
  ),

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
      const SizedBox(height: 16), // Espacio entre botones
      ElevatedButton(
        child: const Text('Datos de Usuario'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserDetailScreen()),
          );
        },
      ),
    ],
  ),
),
    );
  }
}

class ResponsivePetAlign extends StatelessWidget {
  final Alignment alignment;
  final String nombre;
  final String image;
  final Color color;

  const ResponsivePetAlign({
    super.key,
    required this.alignment,
    required this.nombre,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 350.0;

    final horizontalPadding =
        screenWidth > maxContentWidth
            ? (screenWidth - maxContentWidth) / 2
            : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Align(
        alignment: alignment,
        child: PetCard(nombre: nombre, image: image, color: color),
      ),
    );
  }
}

class PetCard extends StatelessWidget {
  final String nombre;
  final String image;
  final Color color;

  const PetCard({
    super.key,
    required this.nombre,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double boxSize = 160;
    const double imageSize = 120;

    return Column(
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ClipOval(
              child: Image.asset(
                image,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(nombre, style: const TextStyle(color: Color(0xFF355F2E))),
      ],
    );
  }
}

class InfoItem extends StatelessWidget {
  final String texto;
  final String subtexto;

  const InfoItem({super.key, required this.texto, required this.subtexto});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF355F2E),
          ),
        ),
        Text(
          subtexto,
          style: const TextStyle(fontSize: 12, color: Color(0xFF355F2E)),
        ),
      ],
    );
  }
}

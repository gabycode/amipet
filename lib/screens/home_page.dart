import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'register_screen.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              const SizedBox(height: 20),

              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.85,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _getMascotasEjemplo().length,
                itemBuilder: (context, index) {
                  final mascota = _getMascotasEjemplo()[index];
                  final isEven = index % 2 == 0;
                  return Padding(
                    padding: EdgeInsets.only(top: isEven ? 0 : 20),
                    child: PetCard(mascota: mascota),
                  );
                },
              ),

              const SizedBox(height: 30),
              Text(
                "Encuentra a tu",
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
              Text(
                "animal favorito",
                style: subtitleStyle,
                textAlign: TextAlign.center,
              ),
              Text(
                "cerca de ti",
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.location_on_outlined, color: Colors.green),
                  SizedBox(width: 5),
                  Text(
                    "Mascotas disponibles en tu área",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: screenWidth * 0.8,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF355F2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Iniciar Sesión",
                    style: TextStyle(fontSize: 18, color: Color(0xFFF4FFE8)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: screenWidth * 0.8,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF355F2E), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Crear Cuenta",
                    style: TextStyle(fontSize: 18, color: Color(0xFF355F2E)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMascotasEjemplo() {
    return [
      {
        'name': 'Max',
        'type': 'Gato',
        'age': '2 años',
        'image': 'assets/max.jpg',
        'color': const Color(0xFFFFB6C1),
      },
      {
        'name': 'Luna',
        'type': 'Perro',
        'age': '1 año',
        'image': 'assets/luna.jpg',
        'color': const Color(0xFFB0E0E6),
      },
      {
        'name': 'Coco',
        'type': 'Perro',
        'age': '3 años',
        'image': 'assets/coco.jpg',
        'color': const Color(0xFFFFA07A),
      },
      {
        'name': 'Misu',
        'type': 'Gato',
        'age': '2 años',
        'image': 'assets/misu.jpg',
        'color': const Color(0xFF98FB98),
      },
    ];
  }
}

class PetCard extends StatelessWidget {
  final Map<String, dynamic> mascota;

  const PetCard({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    const double boxSize = 130;

    return Column(
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: mascota['color'] as Color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipOval(
              child: Image.asset(
                mascota['image'] as String,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.pets, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          mascota['name'] as String,
          style: const TextStyle(
            color: Color(0xFF355F2E),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (mascota['type'] != null)
          Text(
            '${mascota['type']} • ${mascota['age'] ?? 'N/A'}',
            style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 10),
          ),
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

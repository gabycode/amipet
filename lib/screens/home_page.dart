import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mascotas_page.dart';

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

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  PetCard(
                    nombre: 'Misu',
                    image: 'assets/misu.jpg',
                    color: Color(0xFFF9C0AB),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: PetCard(
                      nombre: 'Coco',
                      image: 'assets/coco.jpg',
                      color: Color(0xFFA8CD89),
                    ),
                  ),

                  PetCard(
                    nombre: 'Luna',
                    image: 'assets/luna.jpg',
                    color: Color(0xFFF4E0AF),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: PetCard(
                      nombre: 'Max',
                      image: 'assets/max.jpg',
                      color: Color(0xFF355F2E),
                    ),
                  ),
                ],
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExplorarMascotasPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF355F2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.15,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  "Explorar mascotas",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFF4FFE8), // verde claro
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  InfoItem(texto: '150+', subtexto: 'Mascotas'),
                  InfoItem(texto: '98%', subtexto: 'Adopciones exitosas'),
                  InfoItem(texto: '24h', subtexto: 'Respuestas'),
                ],
              ),
            ],
          ),
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

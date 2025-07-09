import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'mascotas_page.dart';
import '../providers/mascota_provider.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<MascotaProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.cantidadFavoritas}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF355F2E),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4FFE8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Consumer<MascotaProvider>(
                builder: (context, provider, child) {
                  final mascotas = provider.mascotasHome;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 0.85,
                        ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mascotas.length,
                    itemBuilder: (context, index) {
                      final mascota = mascotas[index];
                      final isEven = index % 2 == 0;
                      return Padding(
                        padding: EdgeInsets.only(top: isEven ? 0 : 20),
                        child: PetCard(mascota: mascota),
                      );
                    },
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
                  style: TextStyle(fontSize: 18, color: Color(0xFFF4FFE8)),
                ),
              ),

              const SizedBox(height: 30),
              Consumer<MascotaProvider>(
                builder: (context, provider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InfoItem(
                        texto: '${provider.mascotasHome.length}',
                        subtexto: 'Mascotas disponibles',
                      ),
                      InfoItem(
                        texto: '${provider.cantidadFavoritas}',
                        subtexto: 'Tus favoritas',
                      ),
                      const InfoItem(texto: '24h', subtexto: 'Respuestas'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
        Stack(
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
                        child: const Icon(
                          Icons.pets,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: Consumer<MascotaProvider>(
                builder: (context, provider, child) {
                  final isFavorita = provider.isFavorita(mascota);
                  return GestureDetector(
                    onTap: () {
                      provider.toggleFavorito(mascota);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorita
                                ? '${mascota['name']} removido de favoritos'
                                : '${mascota['name']} agregado a favoritos',
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor:
                              isFavorita ? Colors.red : Colors.green,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorita ? Icons.favorite : Icons.favorite_border,
                        color: isFavorita ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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

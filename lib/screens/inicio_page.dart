import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mascotas_page.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  final Color verdeOscuro = const Color(0xFF355f2e);
  final Color verdeClaro = const Color(0xFFa8cd89);
  final Color amarillo = const Color(0xFFf4e0af);
  final Color rosa = const Color(0xFFf9c0ab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenid@!',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: verdeOscuro,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Encuentra a tu nuevo mejor amigo hoy',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),

              // Banner
              Container(
                decoration: BoxDecoration(
                  color: amarillo,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adopta con el corazón',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: verdeOscuro,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dale una segunda oportunidad a un animalito que lo necesita.',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset('assets/images/pet_banner.png', height: 80), // Asegúrate de tener esta imagen
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Categorías
              Text(
                'Categorías',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  categoriaItem('assets/icons/dog.png', 'Perros'),
                  categoriaItem('assets/icons/cat.png', 'Gatos'),
                  categoriaItem('assets/icons/rabbit.png', 'Conejos'),
                  categoriaItem('assets/icons/bird.png', 'Aves'),
                ],
              ),

              const SizedBox(height: 32),

              // Consejos
              Text(
                'Consejos para adoptar',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  tipItem('Sé responsable y comprometido.'),
                  tipItem('Considera el espacio y el tiempo disponible.'),
                  tipItem('Visita al animal antes de adoptar.'),
                ],
              ),

              const SizedBox(height: 32),

              // Botón de explorar
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdeOscuro,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExplorarMascotasPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Explorar mascotas',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget categoriaItem(String iconPath, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: verdeClaro,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset(iconPath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    );
  }

  Widget tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

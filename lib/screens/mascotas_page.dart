// explorar_mascotas_page.dart

import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'inicio_page.dart';
import 'favoritos_page.dart';
import 'package:amipet/screens/registro_mascotas.dart';
import 'package:amipet/screens/user_detail_screen.dart';
import 'pet_detail_screen.dart';

class ExplorarMascotasPage extends StatefulWidget {
  const ExplorarMascotasPage({super.key});

  @override
  State<ExplorarMascotasPage> createState() => _ExplorarMascotasPageState();
}

class _ExplorarMascotasPageState extends State<ExplorarMascotasPage> {
  List<dynamic> mascotasDestacadas = [];
  List<dynamic> otrasMascotas = [];
  bool loading = true;
  String error = '';
  late final String backendUrl;
  int selectedTab = 0;

  final verdeOscuro = const Color(0xFF355f2e);
  final verdeClaro = const Color(0xFFa8cd89);
  final grisTexto = const Color(0xFF444444);
  final grisClaro = const Color(0xFFDDDDDD);

  final List<String> chips = [
    'Popular',
    'Recomendado',
    'Lo nuevo',
    'Más adoptado',
  ];

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      backendUrl = 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      backendUrl = 'http://10.0.2.2:3000';
    } else {
      backendUrl = 'http://localhost:3000';
    }
    cargarMascotas();
  }

  Future<void> cargarMascotas() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/animals'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final all = data['animals'] as List<dynamic>;
        setState(() {
          mascotasDestacadas = all.take(5).toList();
          otrasMascotas = all.skip(5).take(5).toList();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Error al obtener mascotas (${response.statusCode})';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                ? Center(child: Text(error))
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola Zuhaila!',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bienvenida',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[700],
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: chips.length,
                          itemBuilder: (context, index) {
                            final selected = index == selectedTab;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text(
                                  chips[index],
                                  style: GoogleFonts.poppins(
                                    color: selected ? Colors.white : grisTexto,
                                  ),
                                ),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    selectedTab = index;
                                  });
                                },
                                selectedColor: verdeOscuro,
                                backgroundColor: Colors.transparent,
                                side: BorderSide(color: grisClaro),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 250, // Aumentamos la altura
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: mascotasDestacadas.length,
                          itemBuilder: (context, index) {
                            final mascota = mascotasDestacadas[index];
                            final foto =
                                (mascota['photos'] != null &&
                                        mascota['photos'].isNotEmpty)
                                    ? mascota['photos'][0]['medium']
                                    : null;
                            final nombre = mascota['name'] ?? 'Sin nombre';
                            final edad = mascota['age'] ?? '';
                            final raza = mascota['breeds']?['primary'] ?? '';

                            return Container(
                              width: ancho * 0.65,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: SizedBox(
                                      height: 140,
                                      width: double.infinity,
                                      child:
                                          foto != null
                                              ? Image.network(
                                                foto,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.pets,
                                                      size: 60,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  );
                                                },
                                              )
                                              : Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.pets,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          edad,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: verdeClaro,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            raza,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Más animalitos',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 170, // Aumentamos la altura
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: otrasMascotas.length,
                          itemBuilder: (context, index) {
                            final mascota = otrasMascotas[index];
                            final foto =
                                (mascota['photos'] != null &&
                                        mascota['photos'].isNotEmpty)
                                    ? mascota['photos'][0]['medium']
                                    : null;
                            final nombre = mascota['name'] ?? 'Sin nombre';
                            final edad = mascota['age'] ?? '';
                            final raza = mascota['breeds']?['primary'] ?? '';

                            return Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: SizedBox(
                                      height: 80,
                                      width: double.infinity,
                                      child:
                                          foto != null
                                              ? Image.network(
                                                foto,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.pets,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              )
                                              : Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.pets,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          edad,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: verdeClaro,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            raza,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const PetDetailScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA8CD89),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text(
                                  'Datos de Mascotas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const RegistroMascotaScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF9C0AB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text(
                                  'Registrar Mascotas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: verdeOscuro,
        unselectedItemColor: grisTexto,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const InicioPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritosPage()),
            );
          } else if (index == 3) {
            // Navegar a Datos de Usuario desde el ícono de Perfil
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserDetailScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Adoptar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

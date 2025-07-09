import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class MascotasPage extends StatefulWidget {
  const MascotasPage({super.key});

  @override
  State<MascotasPage> createState() => _MascotasPageState();
}

class _MascotasPageState extends State<MascotasPage> {
  List<dynamic> mascotas = [];
  bool loading = true;
  String error = '';
  late final String backendUrl;
  int chipSeleccionado = 0;

  final List<String> categorias = ['Popular', 'Recomendado', 'Lo nuevo', 'Más adoptado'];

  final Color verdeOscuro = const Color(0xFF355f2e);
  final Color verdeClaro = const Color(0xFFa8cd89);
  final Color rosa = const Color(0xFFf9c0ab);
  final Color amarillo = const Color(0xFFf4e0af);

  Future<void> cargarMascotas() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final response = await http.get(Uri.parse('$backendUrl/animals'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mascotas = data['animals'];
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

  Widget buildChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final selected = chipSeleccionado == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(
                categorias[index],
                style: GoogleFonts.poppins(
                  color: selected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: selected,
              selectedColor: verdeOscuro,
              backgroundColor: Colors.transparent,
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected ? verdeOscuro : Colors.grey.shade300,
                ),
              ),
              onSelected: (_) {
                setState(() => chipSeleccionado = index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildTarjetaMascotaGrande(dynamic mascota) {
    final nombre = mascota['name'] ?? 'Sin nombre';
    final edad = mascota['age'] ?? 'Edad desconocida';
    final raza = mascota['breeds']?['primary'] ?? 'Raza desconocida';
    final fotos = mascota['photos'] as List?;
    final foto = (fotos != null && fotos.isNotEmpty) ? fotos[0]['medium'] : null;

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: foto != null
                ? Image.network(foto, height: 150, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.pets, size: 50),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre,
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(edad, style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rosa,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    raza,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTarjetaPequena(String nombre, String edad, String raza) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.pets, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(nombre,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            Text(edad, style: GoogleFonts.poppins(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: amarillo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                raza,
                style: GoogleFonts.poppins(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(child: Text(error))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("¡Hola Lina!",
                            style: GoogleFonts.poppins(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Bienvenida",
                            style: GoogleFonts.poppins(fontSize: 16)),
                        const SizedBox(height: 20),
                        buildChips(),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: mascotas.length,
                            itemBuilder: (context, index) =>
                                buildTarjetaMascotaGrande(mascotas[index]),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text("Más animalitos",
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              buildTarjetaPequena("Milo", "2 años", "Mestizo"),
                              buildTarjetaPequena("Rocky", "3 años", "Labrador"),
                              buildTarjetaPequena("Bella", "1 año", "Caniche"),
                              buildTarjetaPequena("Charlie", "4 años", "Beagle"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: verdeOscuro,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(),
        unselectedLabelStyle: GoogleFonts.poppins(),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Adoptar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

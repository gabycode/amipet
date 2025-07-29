// explorar_mascotas_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../providers/mascota_provider.dart';
import 'package:amipet/screens/registro_mascotas.dart';
import 'pet_detail_screen.dart';

class ExplorarMascotasPage extends StatefulWidget {
  const ExplorarMascotasPage({super.key});

  @override
  State<ExplorarMascotasPage> createState() => _ExplorarMascotasPageState();
}

class _ExplorarMascotasPageState extends State<ExplorarMascotasPage> {
  List<Map<String, dynamic>> mascotas = [];
  List<Map<String, dynamic>> todasLasMascotas =
      []; // Lista completa para filtrar
  bool loading = true;
  String error = '';
  int selectedTab = 0;
  String userName = 'Usuario'; // Nombre por defecto

  final verdeOscuro = const Color(0xFF355f2e);
  final verdeClaro = const Color(0xFFa8cd89);
  final grisTexto = const Color(0xFF444444);
  final grisClaro = const Color(0xFFDDDDDD);

  final List<Map<String, dynamic>> categorias = [
    {'nombre': 'Todos', 'icono': Icons.grid_view, 'especie': 'Todos'},
    {'nombre': 'Perros', 'icono': Icons.pets, 'especie': 'Perro'},
    {'nombre': 'Gatos', 'icono': Icons.pets, 'especie': 'Gato'},
  ];

  @override
  void initState() {
    super.initState();
    _obtenerNombreUsuario();
    cargarMascotas();
  }

  void _obtenerNombreUsuario() {
    final userInfo = AuthService.getUserInfo();
    setState(() {
      userName = userInfo['firstName']!; // Solo el primer nombre
    });
  }

  Future<void> cargarMascotas() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      // Obtener todas las mascotas
      final todasMascotas = await FirestoreService.obtenerMascotasDestacadas(
        limite: 50, // Obtener hasta 50 mascotas
      );

      setState(() {
        todasLasMascotas = todasMascotas; // Guardar la lista completa
        mascotas = todasMascotas; // Mostrar todas inicialmente
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar mascotas: $e';
        loading = false;
      });
    }
  }

  void filtrarPorCategoria(String especie) {
    setState(() {
      if (especie == 'Todos') {
        mascotas = todasLasMascotas;
      } else {
        mascotas =
            todasLasMascotas
                .where((mascota) => mascota['especie'] == especie)
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        // Prevenir navegación hacia atrás que cause problemas de sesión
        // En su lugar, mantener al usuario en la aplicación
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 253, 238, 238),
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
                          '¡Hola $userName!',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bienvenid@ de vuelta',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[700],
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Explorar por categoría',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: grisTexto,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categorias.length,
                            itemBuilder: (context, index) {
                              final categoria = categorias[index];
                              final selected = index == selectedTab;
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTab = index;
                                    });
                                    filtrarPorCategoria(categoria['especie']);
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color:
                                              selected
                                                  ? verdeOscuro
                                                  : verdeClaro,
                                          shape: BoxShape.circle,
                                          boxShadow:
                                              selected
                                                  ? [
                                                    BoxShadow(
                                                      color: verdeOscuro
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                  : null,
                                        ),
                                        child: Icon(
                                          categoria['icono'],
                                          size: 24,
                                          color:
                                              selected
                                                  ? Colors.white
                                                  : verdeOscuro,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        categoria['nombre'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight:
                                              selected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                          color:
                                              selected
                                                  ? verdeOscuro
                                                  : grisTexto,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mascotas disponibles',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: cargarMascotas,
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Actualizar lista',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 250, // Aumentamos la altura
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: mascotas.length,
                            itemBuilder: (context, index) {
                              final mascota = mascotas[index];
                              final foto = mascota['fotoURL'];
                              final nombre = mascota['nombre'] ?? 'Sin nombre';
                              final edad = mascota['edad'];
                              final raza =
                                  mascota['especie'] ?? 'Sin especificar';

                              // Formatear la edad
                              String edadTexto = '';
                              if (edad != null) {
                                final unidadEdad =
                                    mascota['unidadEdad'] ?? 'años';
                                edadTexto = '$edad $unidadEdad';
                              }

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              PetDetailScreen(mascota: mascota),
                                    ),
                                  );
                                },
                                child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
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
                                                            color:
                                                                Colors
                                                                    .grey[200],
                                                            child: const Icon(
                                                              Icons.pets,
                                                              size: 60,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                        loadingBuilder: (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Container(
                                                            color:
                                                                Colors
                                                                    .grey[200],
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
                                          // Botón de favorito
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Consumer<MascotaProvider>(
                                              builder: (
                                                context,
                                                provider,
                                                child,
                                              ) {
                                                final isFavorita = provider
                                                    .isFavorita(mascota);
                                                return GestureDetector(
                                                  onTap: () {
                                                    provider.toggleFavorito(
                                                      mascota,
                                                    );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          isFavorita
                                                              ? '${nombre} removido de favoritos'
                                                              : '${nombre} agregado a favoritos',
                                                        ),
                                                        duration:
                                                            const Duration(
                                                              seconds: 1,
                                                            ),
                                                        backgroundColor:
                                                            isFavorita
                                                                ? Colors.red
                                                                : Colors.green,
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Icon(
                                                      isFavorita
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color:
                                                          isFavorita
                                                              ? Colors.red
                                                              : Colors.grey,
                                                      size: 20,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
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
                                              edadTexto,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: verdeClaro,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                raza,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ), // Cierra el Container
                              ); // Cierra el GestureDetector
                            }, // Cierra el itemBuilder
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Navegar y esperar a que regrese
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const RegistroMascotaScreen(),
                                      ),
                                    );

                                    // Si se registró una mascota, recargar la lista
                                    if (result == true) {
                                      cargarMascotas();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF355F2E),
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
      ),
    );
  }
}

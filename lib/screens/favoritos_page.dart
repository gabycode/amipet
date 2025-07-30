import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mascota_provider.dart';
import 'pet_detail_screen.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  @override
  void initState() {
    super.initState();
    // Validar favoritos cuando se carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MascotaProvider>(context, listen: false);
      provider.validarYLimpiarFavoritos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevenir navegación hacia atrás que cause problemas de sesión
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: SafeArea(
          child: Consumer<MascotaProvider>(
            builder: (context, provider, child) {
              final favoritas = provider.mascotasFavoritas;

              if (favoritas.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Color(0xFF355F2E),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Tus mascotas favoritas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF355F2E),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Ve a Explorar y marca las mascotas\nque más te gusten como favoritas',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Título de la página
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: Text(
                        'Tus Mascotas Favoritas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF355F2E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Tienes ${favoritas.length} mascota${favoritas.length == 1 ? '' : 's'} favorita${favoritas.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF355F2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: favoritas.length,
                        itemBuilder: (context, index) {
                          final mascota = favoritas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PetDetailScreen(
                                          mascotaId: mascota['id'],
                                        ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    mascota['fotoURL'] != null &&
                                            mascota['fotoURL']
                                                .toString()
                                                .isNotEmpty
                                        ? NetworkImage(
                                          mascota['fotoURL'] as String,
                                        )
                                        : null,
                                child:
                                    mascota['fotoURL'] == null ||
                                            mascota['fotoURL']
                                                .toString()
                                                .isEmpty
                                        ? const Icon(
                                          Icons.pets,
                                          size: 20,
                                          color: Colors.grey,
                                        )
                                        : null,
                              ),
                              title: Text(
                                mascota['nombre'] ??
                                    mascota['name'] ??
                                    'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF355F2E),
                                ),
                              ),
                              subtitle: Text(
                                '${mascota['especie'] ?? mascota['type'] ?? 'Mascota'} • ${mascota['edad'] != null ? "${mascota['edad']} años" : mascota['age'] ?? 'Edad no especificada'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  provider.removerDeFavoritos(mascota);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${mascota['nombre'] ?? mascota['name'] ?? 'Mascota'} removido de favoritos',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

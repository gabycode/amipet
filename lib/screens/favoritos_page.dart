import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mascota_provider.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: const Color(0xFF355F2E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFFF4FFE8),
      body: Consumer<MascotaProvider>(
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
                    'Aquí aparecerán las mascotas que marques como favoritas',
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
                          leading: CircleAvatar(
                            backgroundColor: mascota['color'] as Color,
                            backgroundImage: AssetImage(
                              mascota['image'] as String,
                            ),
                            onBackgroundImageError: (exception, stackTrace) {},
                            child:
                                mascota['image'] == null
                                    ? const Icon(
                                      Icons.pets,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          title: Text(
                            mascota['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF355F2E),
                            ),
                          ),
                          subtitle: Text(
                            '${mascota['type'] ?? 'Mascota'} • ${mascota['age'] ?? 'Edad no especificada'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () {
                              provider.removerDeFavoritos(mascota);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${mascota['name']} removido de favoritos',
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mascota_provider.dart';

class UsuarioConfigPage extends StatefulWidget {
  const UsuarioConfigPage({super.key});

  @override
  State<UsuarioConfigPage> createState() => _UsuarioConfigPageState();
}

class _UsuarioConfigPageState extends State<UsuarioConfigPage> {
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MascotaProvider>(context, listen: false);
    _nombreController.text = provider.usuarioActual;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Usuario'),
        backgroundColor: const Color(0xFF355F2E),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF4FFE8),
      body: Consumer<MascotaProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF355F2E),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de nombre
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    labelStyle: TextStyle(color: Color(0xFF355F2E)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF355F2E)),
                    ),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF355F2E)),
                  ),
                ),
                const SizedBox(height: 20),

                // Botón para guardar
                ElevatedButton(
                  onPressed: () {
                    final nuevoNombre = _nombreController.text.trim();
                    if (nuevoNombre.isNotEmpty) {
                      provider.setUsuario(nuevoNombre);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nombre actualizado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor ingrese un nombre válido'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF355F2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Guardar Cambios',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Información del estado actual
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estado actual con Provider:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF355F2E),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Color(0xFF355F2E)),
                            const SizedBox(width: 8),
                            Text('Usuario: ${provider.usuarioActual}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Favoritas: ${provider.cantidadFavoritas}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.pets, color: Color(0xFF355F2E)),
                            const SizedBox(width: 8),
                            Text(
                              'Disponibles: ${provider.mascotasHome.length}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón para demostrar Provider
                OutlinedButton(
                  onPressed: () {
                    provider.limpiarFavoritos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favoritos limpiados - Demo de Provider'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF355F2E)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Limpiar Favoritos (Demo Provider)',
                      style: TextStyle(fontSize: 16, color: Color(0xFF355F2E)),
                    ),
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

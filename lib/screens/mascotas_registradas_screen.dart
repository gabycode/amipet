import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/form_notifier.dart';
import '../providers/mascota_provider.dart';
import 'registro_mascotas.dart';
import 'pet_detail_screen.dart';

class MascotasRegistradasScreen extends StatefulWidget {
  const MascotasRegistradasScreen({super.key});

  @override
  State<MascotasRegistradasScreen> createState() =>
      _MascotasRegistradasScreenState();
}

class _MascotasRegistradasScreenState extends State<MascotasRegistradasScreen> {
  List<Map<String, dynamic>> _mascotas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMascotasRegistradas();
  }

  Future<void> _cargarMascotasRegistradas() async {
    setState(() {
      _cargando = true;
    });

    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final mascotas = await FirestoreService.obtenerMascotasPorUsuario(
          user.uid,
        );
        setState(() {
          _mascotas = mascotas;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar mascotas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mascotas Registradas',
          style: TextStyle(
            color: Color(0xff355f2e),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff355f2e)),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _mascotas.isEmpty
                    ? _buildEmptyState()
                    : _buildMascotasList(),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistroMascotaScreen(),
                  ),
                ).then((_) {
                  _cargarMascotasRegistradas();
                });
              },
              label: const Text(
                'Registrar Mascotas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff355f2e),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No has registrado mascotas aún',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registra tu primera mascota para\ncomenzar a ayudar en las adopciones',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMascotasList() {
    return RefreshIndicator(
      onRefresh: _cargarMascotasRegistradas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mascotas.length,
        itemBuilder: (context, index) {
          final mascota = _mascotas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    mascota['fotoURL'] != null &&
                            mascota['fotoURL'].toString().isNotEmpty
                        ? NetworkImage(mascota['fotoURL'])
                        : null,
                child:
                    mascota['fotoURL'] == null ||
                            mascota['fotoURL'].toString().isEmpty
                        ? const Icon(Icons.pets, color: Colors.grey)
                        : null,
              ),
              title: Text(
                mascota['nombre'] ?? 'Sin nombre',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${mascota['especie'] ?? mascota['type'] ?? 'Mascota'} • ${mascota['edad'] != null ? "${mascota['edad']} años" : mascota['age'] ?? 'Edad no especificada'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'editar':
                      _editarMascota(mascota);
                      break;
                    case 'eliminar':
                      _confirmarEliminarMascota(mascota);
                      break;
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            PetDetailScreen(mascotaId: mascota['id'] ?? ''),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _editarMascota(Map<String, dynamic> mascota) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar ${mascota['nombre']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmarEliminarMascota(Map<String, dynamic> mascota) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Mascota'),
            content: Text(
              '¿Estás seguro de que quieres eliminar a ${mascota['nombre']}? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _eliminarMascota(mascota['id']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  Future<void> _eliminarMascota(String mascotaId) async {
    try {
      final success = await FirestoreService.eliminarMascota(mascotaId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mascota eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        final provider = Provider.of<MascotaProvider>(context, listen: false);
        provider.removerDeFavoritosPorId(mascotaId);

        FormNotifier().notifyMascotaEliminada();

        _cargarMascotasRegistradas();
      } else {
        throw Exception('No se pudo eliminar la mascota');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar mascota: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

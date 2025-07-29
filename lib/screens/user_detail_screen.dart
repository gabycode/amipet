import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'home_page.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  String userName = 'Usuario';
  String userEmail = 'usuario@email.com';
  int formularios = 0; // Contador de formularios de adopción

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarFormulariosAdopcion();
  }

  void _cargarDatosUsuario() {
    final userInfo = AuthService.getUserInfo();
    setState(() {
      userName = userInfo['name']!;
      userEmail = userInfo['email']!;
    });
  }

  void _cargarFormulariosAdopcion() async {
    final user = AuthService.currentUser;
    if (user != null) {
      try {
        // Primero asegurarse de que el perfil del usuario existe
        await FirestoreService.crearPerfilUsuario(
          user.uid,
          user.email ?? '',
          user.displayName ?? 'Usuario',
        );

        // Contar directamente desde formularios_adopcion para mayor precisión
        final cantidad = await FirestoreService.contarFormulariosDirecto(
          user.uid,
        );

        setState(() {
          formularios = cantidad;
        });
      } catch (e) {
        setState(() {
          formularios = 0; // Valor por defecto en caso de error
        });
      }
    }
  }

  Future<void> _cerrarSesion() async {
    await AuthService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _mostrarModalCerrarSesion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff355f2e),
            ),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el modal
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el modal
                _cerrarSesion(); // Ejecutar cerrar sesión
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff355f2e),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModalFormularios() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Handle del modal
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Título
                  Text(
                    'Formularios de Adopción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff355f2e),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lista de formularios
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: FirestoreService.obtenerFormulariosConMascota(
                        AuthService.currentUser?.uid ?? '',
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final formularios = snapshot.data ?? [];

                        if (formularios.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No has enviado formularios aún',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: formularios.length,
                          itemBuilder: (context, index) {
                            final formulario = formularios[index];
                            final mascota = formulario['mascota'];
                            final estado = formulario['estado'] ?? 'pendiente';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Foto de la mascota
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage:
                                          mascota['fotoURL'] != null &&
                                                  mascota['fotoURL']
                                                      .toString()
                                                      .isNotEmpty
                                              ? NetworkImage(mascota['fotoURL'])
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
                                    const SizedBox(width: 12),
                                    // Información
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mascota['nombre'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            mascota['especie'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Estado
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getEstadoColor(estado),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _getEstadoTexto(estado),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Botón eliminar
                                    IconButton(
                                      onPressed:
                                          () => _confirmarEliminarFormulario(
                                            formulario['id'],
                                            mascota['nombre'],
                                          ),
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red,
                                      tooltip: 'Eliminar solicitud',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      case 'en_revision':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobado':
        return 'Aprobado';
      case 'rechazado':
        return 'Rechazado';
      case 'en_revision':
        return 'En Revisión';
      default:
        return 'Pendiente';
    }
  }

  void _confirmarEliminarFormulario(String formularioId, String nombreMascota) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Eliminar Solicitud',
            style: TextStyle(
              color: Color(0xff355f2e),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar tu solicitud de adopción para $nombreMascota?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar dialog
                await _eliminarFormulario(formularioId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarFormulario(String formularioId) async {
    final user = AuthService.currentUser;
    if (user != null) {
      final success = await FirestoreService.eliminarFormularioAdopcion(
        formularioId,
        user.uid,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Recargar contador
        _cargarFormulariosAdopcion();
        // Cerrar modal si está abierto
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar la solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editarPerfil() {
    // TODO: Implementar edición de perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de editar perfil próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevenir navegación hacia atrás que cause problemas de sesión
        return false;
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icono de formularios a la izquierda
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xff355f2e).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (formularios > 0) {
                        _mostrarModalFormularios();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No tienes formularios enviados'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.assignment,
                          size: 24,
                          color: Color(0xff355f2e),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$formularios',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff355f2e),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff355f2e),
                  ),
                ),
                IconButton(
                  onPressed: _mostrarModalCerrarSesion,
                  icon: const Icon(
                    Icons.logout,
                    size: 28,
                    color: Color(0xff355f2e),
                  ),
                  tooltip: 'Cerrar sesión',
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundImage:
                    AuthService.currentUser?.photoURL != null &&
                            AuthService.currentUser!.photoURL!.isNotEmpty
                        ? NetworkImage(AuthService.currentUser!.photoURL!)
                        : const AssetImage('assets/user_avatar.png')
                            as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                userName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff355f2e),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Botón de editar perfil
            Center(
              child: ElevatedButton.icon(
                onPressed: _editarPerfil,
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('Editar Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff355f2e),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE3D5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usuario de AmiPet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F4C45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bienvenido a AmiPet, la aplicación donde puedes encontrar a tu compañero perfecto. Explora mascotas disponibles para adopción y encuentra tu nueva familia peluda.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6F4C45),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconInfo(
                        icon: Icons.email,
                        label: 'Correo',
                        value: userEmail,
                      ),
                      const IconInfo(
                        icon: Icons.pets,
                        label: 'App',
                        value: 'AmiPet',
                      ),
                      const IconInfo(
                        icon: Icons.badge,
                        label: 'Rol',
                        value: 'Usuario',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const IconInfo({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Colors.brown;

    return Column(
      children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: iconColor,
            fontWeight:
                label == 'Formularios' ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

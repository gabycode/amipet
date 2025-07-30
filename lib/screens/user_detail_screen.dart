import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/form_notifier.dart';
import 'home_page.dart';
import 'editar_perfil_screen.dart';
import 'mascotas_registradas_screen.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  String userName = 'Usuario';
  String userEmail = 'usuario@email.com';
  int formularios = 0; // Contador de formularios de adopción
  final ValueNotifier<int> _refreshNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarFormulariosAdopcion();

    FormNotifier().addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _refreshNotifier.dispose();
    FormNotifier().removeListener(_onFormChanged);
    super.dispose();
  }

  void _onFormChanged() {
    _refreshFormularios();
  }

  void _refreshFormularios() {
    _refreshNotifier.value++;
    _cargarFormulariosAdopcion();
  }

  void _cargarDatosUsuario() async {
    final user = AuthService.currentUser;
    if (user != null) {
      await user.reload();
    }

    final userInfo = AuthService.getUserInfo();
    setState(() {
      userName = userInfo['name']!;
      userEmail = userInfo['email']!;
    });
  }

  ImageProvider? _getProfileImage() {
    final user = AuthService.currentUser;
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      return NetworkImage(user.photoURL!);
    }
    try {
      return const AssetImage('assets/placeholder.png');
    } catch (e) {
      return null;
    }
  }

  void _cargarFormulariosAdopcion() async {
    final user = AuthService.currentUser;
    if (user != null) {
      try {
        await FirestoreService.crearPerfilUsuario(
          user.uid,
          user.email ?? '',
          user.displayName ?? 'Usuario',
        );

        final cantidad = await FirestoreService.contarFormulariosDirecto(
          user.uid,
        );

        setState(() {
          formularios = cantidad;
        });
      } catch (e) {
        setState(() {
          formularios = 0;
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
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cerrarSesion();
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
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _refreshNotifier,
                      builder: (context, value, child) {
                        return FutureBuilder<List<Map<String, dynamic>>>(
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error al cargar formularios',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${snapshot.error}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _refreshFormularios,
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
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
                                    const SizedBox(height: 8),
                                    Text(
                                      'Una vez que envíes un formulario de adopción,\naparecerá aquí.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
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
                                final estado =
                                    formulario['estado'] ?? 'pendiente';

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
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage:
                                              mascota['fotoURL'] != null &&
                                                      mascota['fotoURL']
                                                          .toString()
                                                          .isNotEmpty
                                                  ? NetworkImage(
                                                    mascota['fotoURL'],
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
                                        const SizedBox(width: 12),
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
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getEstadoColor(
                                                    estado,
                                                  ),
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
                                        IconButton(
                                          onPressed:
                                              () =>
                                                  _confirmarEliminarFormulario(
                                                    formulario['id'],
                                                    mascota['nombre'],
                                                  ),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
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
                Navigator.of(context).pop();
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
        _refreshFormularios();
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

  void _navegarAEditarPerfil() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditarPerfilScreen()),
    );

    _cargarDatosUsuario();
  }

  void _navegarAMascotasRegistradas() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MascotasRegistradasScreen(),
      ),
    );
  }

  void _cambiarImagenPerfil() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Cambiar Foto de Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff355f2e),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Opción Cámara
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _tomarFotoCamera();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xff355f2e).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: Color(0xff355f2e),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cámara',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Opción Galería
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _seleccionarDeGaleria();
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xff355f2e).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            size: 32,
                            color: Color(0xff355f2e),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Galería',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _tomarFotoCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _subirImagenPerfil(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar la foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _seleccionarDeGaleria() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _subirImagenPerfil(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar la imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _subirImagenPerfil(File imageFile) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Subiendo imagen...'),
                ],
              ),
            ),
      );

      final user = AuthService.currentUser;
      if (user == null) {
        Navigator.pop(context);
        throw Exception('Usuario no autenticado');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}_$timestamp.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = await storageRef.putFile(imageFile, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await user.reload();

      try {
        await FirestoreService.actualizarFotoPerfilUsuario(
          user.uid,
          downloadUrl,
        );
      } catch (e) {
        return;
      }

      Navigator.pop(context);

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      String errorMessage = 'Error al actualizar la foto';

      // Mensajes de error más específicos
      if (e.toString().contains('not authorized')) {
        errorMessage =
            'Error de permisos. Configura las reglas de Firebase Storage';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet';
      } else if (e.toString().contains('storage/object-not-found')) {
        errorMessage = 'Archivo no encontrado';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 56),
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
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _getProfileImage(),
                    child:
                        _getProfileImage() == null
                            ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _cambiarImagenPerfil,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xff355f2e),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
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
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: _navegarAEditarPerfil,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xff355f2e).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xff355f2e),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Editar Perfil',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Separador
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.grey.withOpacity(0.2),
                  ),

                  // Opción Mascotas Registradas
                  InkWell(
                    onTap: _navegarAMascotasRegistradas,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xff355f2e).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Color(0xff355f2e),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Mascotas Registradas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Separador
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.grey.withOpacity(0.2),
                  ),

                  // Opción Formularios de Adopción
                  InkWell(
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
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xff355f2e).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.assignment,
                              color: Color(0xff355f2e),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Formularios de Adopción',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Mostrar el contador de formularios
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff355f2e),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$formularios',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
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

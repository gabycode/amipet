import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/form_notifier.dart';

class AdoptPetScreen extends StatefulWidget {
  final Map<String, dynamic> mascota;

  const AdoptPetScreen({super.key, required this.mascota});

  @override
  State<AdoptPetScreen> createState() => _AdoptPetScreenState();
}

class _AdoptPetScreenState extends State<AdoptPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _motivoController = TextEditingController();

  bool _experiencia = false;
  bool _viviendaPropia = false;
  String _tipoVivienda = 'Casa';

  final verdeOscuro = const Color(0xFF355f2e);
  final verdeClaro = const Color(0xFFa8cd89);

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() async {
    final user = AuthService.currentUser;
    if (user != null) {
      final userInfo = AuthService.getUserInfo();

      final perfilUsuario = await FirestoreService.obtenerPerfilUsuario(
        user.uid,
      );

      setState(() {
        _nombreController.text = userInfo['name'] ?? '';
        _emailController.text = userInfo['email'] ?? '';

        if (perfilUsuario != null) {
          _telefonoController.text = perfilUsuario['telefono'] ?? '';
          _direccionController.text = perfilUsuario['direccion'] ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  void _enviarSolicitud() async {
    if (_formKey.currentState!.validate()) {
      final user = AuthService.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para enviar una solicitud'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final datosFormulario = {
          'datosPersonales': {
            'nombre': _nombreController.text.trim(),
            'telefono': _telefonoController.text.trim(),
            'email': _emailController.text.trim(),
            'direccion': _direccionController.text.trim(),
          },
          'vivienda': {'tipo': _tipoVivienda, 'propia': _viviendaPropia},
          'experiencia': _experiencia,
          'motivacion': _motivoController.text.trim(),
        };

        final formularioId = await FirestoreService.enviarFormularioAdopcion(
          usuarioId: user.uid,
          mascotaId: widget.mascota['id'] ?? 'unknown',
          datosFormulario: datosFormulario,
        );

        Navigator.of(context).pop();

        if (formularioId != null) {
          FormNotifier().notifyFormSubmitted();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Solicitud Enviada',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: verdeOscuro,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'Tu solicitud para adoptar a ${widget.mascota['nombre'] ?? 'esta mascota'} ha sido enviada exitosamente. Te contactaremos pronto.\n\nNúmero de seguimiento: ${formularioId.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Entendido',
                      style: GoogleFonts.poppins(
                        color: verdeOscuro,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al enviar la solicitud. Intenta de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, size: 28, color: verdeOscuro),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Solicitud de Adopción',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: verdeOscuro,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: verdeClaro.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: verdeClaro),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        widget.mascota['fotoURL'] != null &&
                                widget.mascota['fotoURL'].toString().isNotEmpty
                            ? NetworkImage(widget.mascota['fotoURL'])
                            : null,
                    child:
                        widget.mascota['fotoURL'] == null ||
                                widget.mascota['fotoURL'].toString().isEmpty
                            ? const Icon(
                              Icons.pets,
                              size: 30,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mascota['nombre'] ?? 'Mascota',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: verdeOscuro,
                          ),
                        ),
                        Text(
                          '${widget.mascota['especie'] ?? 'Mascota'} • ${widget.mascota['edad'] != null ? "${widget.mascota['edad']} años" : "Edad no especificada"}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Personal',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: verdeOscuro,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _nombreController,
                        label: 'Nombre completo',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: _telefonoController,
                        label: 'Teléfono',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu teléfono';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Correo electrónico',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          if (!value.contains('@')) {
                            return 'Por favor ingresa un correo válido';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: _direccionController,
                        label: 'Dirección',
                        icon: Icons.home,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu dirección';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Información de Vivienda',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: verdeOscuro,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _tipoVivienda,
                            isExpanded: true,
                            items:
                                ['Casa', 'Apartamento', 'Finca'].map((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _tipoVivienda = newValue!;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      CheckboxListTile(
                        title: Text(
                          'Vivienda propia',
                          style: GoogleFonts.poppins(),
                        ),
                        value: _viviendaPropia,
                        onChanged: (bool? value) {
                          setState(() {
                            _viviendaPropia = value ?? false;
                          });
                        },
                        activeColor: verdeOscuro,
                      ),

                      CheckboxListTile(
                        title: Text(
                          'Tengo experiencia con mascotas',
                          style: GoogleFonts.poppins(),
                        ),
                        value: _experiencia,
                        onChanged: (bool? value) {
                          setState(() {
                            _experiencia = value ?? false;
                          });
                        },
                        activeColor: verdeOscuro,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _motivoController,
                        label: '¿Por qué quieres adoptar esta mascota?',
                        icon: Icons.favorite,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor explica tu motivación';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _enviarSolicitud,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: verdeOscuro,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Enviar Solicitud',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: verdeOscuro),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: verdeOscuro, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}

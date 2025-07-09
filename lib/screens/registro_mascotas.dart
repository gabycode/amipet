import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistroMascotaScreen extends StatefulWidget {
  const RegistroMascotaScreen({super.key});

  @override
  State<RegistroMascotaScreen> createState() => _RegistroMascotaScreenState();
}

class _RegistroMascotaScreenState extends State<RegistroMascotaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  List<Map<String, String>> mascotas = [];

  void _registrarMascota() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        mascotas.add({
          'nombre': _nombreController.text,
          'especie': _especieController.text,
          'edad': _edadController.text,
          'descripcion': _descripcionController.text,
        });
        _nombreController.clear();
        _especieController.clear();
        _edadController.clear();
        _descripcionController.clear();
        _formKey.currentState!.reset();
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🐾 Mascota registrada exitosamente')),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _especieController.dispose();
    _edadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color verdeOscuro = const Color(0xFF2E4C1F);
    final Color fondoClaro = const Color(0xFFFDF6ED);
    final Color campoColor = const Color(0xFFFFF3DD);
    final Color botonVerde = const Color(0xFF1E4A19);

    return Scaffold(
      backgroundColor: fondoClaro,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                label: const Text(
                  'Volver',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              Text(
                '¡Hola!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: verdeOscuro,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '¡Bienvenid@! Aquí podrás registrar a tu mascota',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro de mascotas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: verdeOscuro,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ayúdanos a encontrarle un hogar lleno de amor.\nCompleta los datos de la mascota que deseas poner en adopción.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      // Campo Nombre
                      _buildTextField(
                        controller: _nombreController,
                        label: 'Nombre',
                        color: campoColor,
                        validator:
                            (value) => _validarSoloLetras(value, 'nombre'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                          ),
                        ],
                      ),

                      // Campo Especie
                      _buildTextField(
                        controller: _especieController,
                        label: 'Especie',
                        color: campoColor,
                        validator:
                            (value) => _validarSoloLetras(value, 'especie'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
                          ),
                        ],
                      ),

                      // Campo Edad
                      _buildTextField(
                        controller: _edadController,
                        label: 'Edad',
                        keyboardType: TextInputType.number,
                        color: campoColor,
                        validator: _validarEdad,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                      ),

                      // Campo Descripción
                      _buildTextField(
                        controller: _descripcionController,
                        label: 'Descripción',
                        maxLines: 3,
                        color: campoColor,
                        validator: _validarDescripcion,
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: botonVerde,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _registrarMascota,
                          child: const Text(
                            'Agregar mascota',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (mascotas.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mascotas registradas:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...mascotas.map(
                      (mascota) => Card(
                        child: ListTile(
                          title: Text(mascota['nombre'] ?? ''),
                          subtitle: Text(
                            '${mascota['especie']} • ${mascota['edad']} años',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: botonVerde,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Adoptar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color color,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        filled: true,
        fillColor: color,
        hintText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  // Validaciones de los campos del formulario
  String? _validarSoloLetras(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo $campo es obligatorio';
    }
    final letrasRegExp = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!letrasRegExp.hasMatch(value.trim())) {
      return 'El campo $campo solo debe contener letras';
    }
    return null;
  }

  String? _validarEdad(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La edad es obligatoria';
    }
    final edadRegExp = RegExp(r'^\d{1,2}$');
    if (!edadRegExp.hasMatch(value.trim())) {
      return 'La edad debe ser un número de 1 o 2 dígitos';
    }
    return null;
  }

  String? _validarDescripcion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción es obligatoria';
    }
    return null;
  }
}

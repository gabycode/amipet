import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/mascota_provider.dart';
import '../services/firestore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class RegistroMascotaScreen extends StatefulWidget {
  const RegistroMascotaScreen({super.key});

  @override
  State<RegistroMascotaScreen> createState() => _RegistroMascotaScreenState();
}

class _RegistroMascotaScreenState extends State<RegistroMascotaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fotoURLController = TextEditingController();

  String _generoSeleccionado = 'macho';
  String _especieSeleccionada = 'Perro';
  String _unidadEdadSeleccionada = 'años';
  String _comidaSeleccionada = 'Purina';
  dynamic _imagenSeleccionada; // Cambia de File? a dynamic
  final ImagePicker _picker = ImagePicker();

  List<Map<String, String>> mascotas = [];

  Future<String?> _subirImagenAFirebase(dynamic imagen) async {
    try {
      String nombreArchivo =
          'mascotas/${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (kIsWeb) {
        // Para web
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref()
            .child(nombreArchivo)
            .putData(imagen);
        return await snapshot.ref.getDownloadURL();
      } else {
        // Para móvil
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref()
            .child(nombreArchivo)
            .putFile(imagen);
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagenSeleccionada = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (imagenSeleccionada != null) {
        if (kIsWeb) {
          final bytes = await imagenSeleccionada.readAsBytes();
          setState(() {
            _imagenSeleccionada = bytes;
          });
        } else {
          setState(() {
            _imagenSeleccionada = File(imagenSeleccionada.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: ${e.toString()}'),
          backgroundColor: Colors.red,
              ),
            
          );
    }
  }

  void _registrarMascota() async {
    if (_formKey.currentState!.validate()) {
      // Validar que se haya seleccionado una imagen
      if (_imagenSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📸 Debes seleccionar una foto de la mascota'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // 1. Primero subir la imagen a Firebase Storage
        String? imagenUrl = await _subirImagenAFirebase(_imagenSeleccionada!);

        if (imagenUrl == null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al subir la imagen. Intenta de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // 2. Crear el mapa de datos para Firestore con la URL de Firebase Storage
        final mascotaData = {
          'nombre': _nombreController.text.trim(),
          'especie': _especieSeleccionada,
          'edad': int.parse(_edadController.text.trim()),
          'unidadEdad': _unidadEdadSeleccionada,
          'descripcion': _descripcionController.text.trim(),
          'comida': _comidaSeleccionada,
          'fotoURL': imagenUrl, // Usamos la URL de Firebase Storage
          'genero': _generoSeleccionado,
          'fechaRegistro':
              FieldValue.serverTimestamp(), // Fecha exacta del servidor
        };

        // 3. Guardar en Firestore
        String? mascotaId = await FirestoreService.registrarMascota(
          mascotaData,
        );

        // Cerrar el indicador de carga
        Navigator.of(context).pop();

        if (mascotaId != null) {
          // Agregar a la lista local para mostrar
          setState(() {
            mascotas.add({
              'nombre': _nombreController.text,
              'especie': _especieSeleccionada,
              'edad': '${_edadController.text} $_unidadEdadSeleccionada',
              'descripcion': _descripcionController.text,
              'imagenUrl': imagenUrl, // Agregamos la URL de la imagen
            });

            // Limpiar los campos
            _nombreController.clear();
            _edadController.clear();
            _descripcionController.clear();
            _especieSeleccionada = 'Perro';
            _generoSeleccionado = 'macho';
            _unidadEdadSeleccionada = 'años';
            _comidaSeleccionada = 'Purina';
            _imagenSeleccionada = null;
            _formKey.currentState!.reset();
          });

          // Opcionalmente agregar a favoritos usando Provider
          final provider = Provider.of<MascotaProvider>(context, listen: false);
          final nuevaMascota = {
            'id': mascotaId, // Usamos el ID real de Firestore
            'name': mascotaData['nombre'],
            'type': mascotaData['especie'],
            'age': '${mascotaData['edad']} ${mascotaData['unidadEdad']}',
            'image': imagenUrl, // Usamos la URL de Firebase Storage
            'color': const Color(0xFFA8CD89),
          };

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🐾 ${mascotaData['nombre']} registrada exitosamente',
              ),
              backgroundColor: const Color(0xFF355F2E),
              action: SnackBarAction(
                label: 'Agregar a favoritos',
                textColor: Colors.white,
                onPressed: () {
                  provider.agregarAFavoritos(nuevaMascota);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '❤️ ${mascotaData['nombre']} agregada a favoritos',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
          );

          // Regresar true para indicar que se registró exitosamente
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ Error al registrar la mascota. Intenta de nuevo.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Cerrar el indicador de carga si hay error
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _descripcionController.dispose();
    _fotoURLController.dispose();
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
                      const SizedBox(height: 16),

                      // Fila con Especie y Género
                      Row(
                        children: [
                          // Dropdown de Especie
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: campoColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _especieSeleccionada,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  hintText: 'Especie',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Perro',
                                    child: Text('Perro'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Gato',
                                    child: Text('Gato'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _especieSeleccionada = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Dropdown de Género
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: campoColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _generoSeleccionado,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  hintText: 'Género',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'macho',
                                    child: Text('Macho'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'hembra',
                                    child: Text('Hembra'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _generoSeleccionado = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Fila con Edad y Unidad
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
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
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: campoColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _unidadEdadSeleccionada,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  hintText: 'Unidad',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'años',
                                    child: Text('Años'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'meses',
                                    child: Text('Meses'),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _unidadEdadSeleccionada = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _descripcionController,
                        label: 'Descripción',
                        maxLines: 3,
                        color: campoColor,
                        validator: _validarDescripcion,
                      ),
                      const SizedBox(height: 16),

                      // Dropdown de Comida
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: campoColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _comidaSeleccionada,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                            hintText: 'Tipo de comida',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Purina',
                              child: Text('Purina'),
                            ),
                            DropdownMenuItem(
                              value: 'Royal Canin',
                              child: Text('Royal Canin'),
                            ),
                            DropdownMenuItem(
                              value: 'Hills',
                              child: Text('Hills'),
                            ),
                            DropdownMenuItem(
                              value: 'Pedigree',
                              child: Text('Pedigree'),
                            ),
                            DropdownMenuItem(
                              value: 'Whiskas',
                              child: Text('Whiskas'),
                            ),
                            DropdownMenuItem(
                              value: 'Eukanuba',
                              child: Text('Eukanuba'),
                            ),
                            DropdownMenuItem(
                              value: 'Pro Plan',
                              child: Text('Pro Plan'),
                            ),
                            DropdownMenuItem(
                              value: 'Comida casera',
                              child: Text('Comida casera'),
                            ),
                            DropdownMenuItem(
                              value: 'Otra marca',
                              child: Text('Otra marca'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _comidaSeleccionada = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selector de foto
GestureDetector(
  onTap: _seleccionarImagen,
  child: Container(
    width: double.infinity,
    height: _imagenSeleccionada != null ? 200 : 120,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: campoColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _imagenSeleccionada == null 
          ? Colors.red.shade300 
          : Colors.grey.shade300,
        width: _imagenSeleccionada == null ? 2 : 1,
      ),
    ),
    child: _imagenSeleccionada != null
      ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                ? Image.memory(
                    _imagenSeleccionada,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    _imagenSeleccionada,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _imagenSeleccionada = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        )
      : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para seleccionar una foto del dispositivo',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
  ),
),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Aquí puedes agregar un botón para registrar la mascota
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: botonVerde,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                  ),
                  onPressed: _registrarMascota,
                  child: const Text(
                    'Registrar Mascota',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

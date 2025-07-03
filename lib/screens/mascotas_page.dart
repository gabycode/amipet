import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class MascotasPage extends StatefulWidget {
  const MascotasPage({super.key});

  @override
  State<MascotasPage> createState() => _MascotasPageState();
}

class _MascotasPageState extends State<MascotasPage> {
  List<dynamic> mascotas = [];
  bool loading = true;
  String error = '';

  late final String backendUrl;

  Future<void> cargarMascotas() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final response = await http.get(Uri.parse('$backendUrl/animals'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mascotas = data['animals'];
          loading = false;
        });
      } else {
        setState(() {
          error = 'Error al obtener mascotas (${response.statusCode})';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Detecta plataforma
    if (kIsWeb) {
      backendUrl = 'http://localhost:3000'; // o tu IP local real
    } else if (Platform.isAndroid) {
      backendUrl = 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      backendUrl = 'http://localhost:3000';
    } else {
      backendUrl = 'http://localhost:3000'; // fallback para desktop
    }

    cargarMascotas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mascotas disponibles')),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : error.isNotEmpty
              ? Center(child: Text(error))
              : ListView.builder(
                itemCount: mascotas.length,
                itemBuilder: (context, index) {
                  final mascota = mascotas[index];
                  final nombre = mascota['name'] ?? 'Sin nombre';
                  final tipo = mascota['type'] ?? '';
                  final fotos = mascota['photos'] as List?;
                  final foto =
                      (fotos != null && fotos.isNotEmpty)
                          ? fotos[0]['medium']
                          : null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen
                        Container(
                          width: 120,
                          height: 150,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child:
                              foto != null
                                  ? Image.network(
                                    foto,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                            ),
                                  )
                                  : const Icon(Icons.pets, size: 50),
                        ),
                        const SizedBox(width: 16),
                        // Texto
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(tipo, style: const TextStyle(fontSize: 16)),
                            ],
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

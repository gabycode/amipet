import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'adopt_pet_screen.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../providers/mascota_provider.dart';
import 'main_navigation_page.dart';

class PetDetailScreen extends StatefulWidget {
  final Map<String, dynamic> mascota;

  const PetDetailScreen({super.key, required this.mascota});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  bool _yaEnvioFormulario = false;
  bool _verificandoFormulario = true;

  @override
  void initState() {
    super.initState();
    _verificarFormularioExistente();
  }

  void _verificarFormularioExistente() async {
    final user = AuthService.currentUser;
    if (user != null && widget.mascota['id'] != null) {
      try {
        final yaEnvio = await FirestoreService.usuarioYaEnvioFormulario(
          user.uid,
          widget.mascota['id'],
        );
        setState(() {
          _yaEnvioFormulario = yaEnvio;
          _verificandoFormulario = false;
        });
      } catch (e) {
        setState(() {
          _verificandoFormulario = false;
        });
      }
    } else {
      setState(() {
        _verificandoFormulario = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: Color(0xff355f2e),
                ),
              ),
              const Text(
                'Detalles',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff355f2e),
                ),
              ),
              Consumer<MascotaProvider>(
                builder: (context, provider, child) {
                  final isFavorita = provider.isFavorita(widget.mascota);
                  return GestureDetector(
                    onTap: () {
                      provider.toggleFavorito(widget.mascota);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorita
                                ? '${widget.mascota['nombre'] ?? 'Mascota'} removido de favoritos'
                                : '${widget.mascota['nombre'] ?? 'Mascota'} agregado a favoritos',
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor:
                              isFavorita ? Colors.red : Colors.green,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorita ? Icons.favorite : Icons.favorite_border,
                        color:
                            isFavorita ? Colors.red : const Color(0xff355f2e),
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  widget.mascota['fotoURL'] != null &&
                          widget.mascota['fotoURL'].toString().isNotEmpty
                      ? NetworkImage(widget.mascota['fotoURL'])
                      : null,
              child:
                  widget.mascota['fotoURL'] == null ||
                          widget.mascota['fotoURL'].toString().isEmpty
                      ? const Icon(Icons.pets, size: 60, color: Colors.grey)
                      : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.mascota['nombre'] ?? 'Sin nombre',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff355f2e),
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
                Text(
                  widget.mascota['especie'] ?? 'Especie no especificada',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F4C45),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.mascota['descripcion'] ??
                      'Sin descripción disponible.',
                  style: const TextStyle(
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
                      icon: Icons.fastfood,
                      label: 'Comida',
                      value: widget.mascota['comida'] ?? 'No especificada',
                    ),
                    IconInfo(
                      icon:
                          widget.mascota['genero'] == 'macho'
                              ? Icons.male
                              : Icons.female,
                      label: 'Género',
                      value: widget.mascota['genero'] ?? 'No especificado',
                    ),
                    IconInfo(
                      icon: Icons.calendar_today,
                      label: 'Edad',
                      value:
                          widget.mascota['edad'] != null
                              ? '${widget.mascota['edad']} ${widget.mascota['unidadEdad'] ?? 'años'}'
                              : 'No especificada',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Indicador si ya envió formulario
          if (_yaEnvioFormulario)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade800,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Ya has enviado una solicitud de adopción para esta mascota. Puedes revisar el estado en tu ',
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const MainNavigationPage(
                                            initialIndex: 3,
                                          ),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  'perfil',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Botón de adoptar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child:
                  _verificandoFormulario
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed:
                            _yaEnvioFormulario
                                ? null
                                : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AdoptPetScreen(
                                            mascota: widget.mascota,
                                          ),
                                    ),
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _yaEnvioFormulario
                                  ? Colors.grey
                                  : const Color(0xFF355f2e),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _yaEnvioFormulario
                                  ? Icons.check_circle
                                  : Icons.favorite,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _yaEnvioFormulario
                                  ? 'Ya solicitaste la adopción'
                                  : 'Quiero Adoptar',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class IconInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const IconInfo({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.brown),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.brown)),
      ],
    );
  }
}

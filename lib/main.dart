import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mascota_provider.dart';
import 'screens/home_page.dart';
import 'screens/favoritos_page.dart';
import 'screens/perfil_page.dart';
import 'screens/mascotas_page.dart';
import 'screens/usuario_config_page.dart';

void main() {
  runApp(const AmiPetApp());
}

class AmiPetApp extends StatelessWidget {
  const AmiPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MascotaProvider(),
      child: MaterialApp(
        title: 'AmiPet',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          fontFamily: 'Agrandir',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        home: const HomePage(),
        routes: {
          '/home': (context) => const HomePage(),
          '/favoritos': (context) => const FavoritosPage(),
          '/perfil': (context) => const PerfilPage(),
          '/mascotas': (context) => const ExplorarMascotasPage(),
          '/config-usuario': (context) => const UsuarioConfigPage(),
        },
      ),
    );
  }
}

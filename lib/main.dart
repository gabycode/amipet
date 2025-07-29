import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/mascota_provider.dart';
import 'screens/home_page.dart';
import 'screens/favoritos_page.dart';
import 'screens/perfil_page.dart';
import 'screens/mascotas_page.dart';
import 'screens/usuario_config_page.dart';
import 'screens/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar las variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
          '/main': (context) => const MainNavigationPage(),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/mascota_provider.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

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
        home: HomePage(),
      ),
    );
  }
}

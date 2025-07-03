import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const AmiPetApp());
}

class AmiPetApp extends StatelessWidget {
  const AmiPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmiPet',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Agrandir',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      home: const HomePage(),
    );
  }
}

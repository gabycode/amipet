import 'package:flutter/material.dart';

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF355f2e),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Adoptar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¡Hola Lina!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF355f2e),
                  fontFamily: 'Sans',
                )),
            const SizedBox(height: 8),
            Text('Bienvenida',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                  fontFamily: 'Sans',
                )),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/pet-welcome.png', // asegúrate de tener esta imagen
                    height: 220,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Encuentra a tu animal favorito\ncerca de ti',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF355f2e),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sans',
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

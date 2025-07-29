import 'package:flutter/material.dart';

class MascotaProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _mascotasFavoritas = [];
  bool _isLoading = false;
  String _usuarioActual = 'Usuario Invitado';

  List<Map<String, dynamic>> get mascotasFavoritas => _mascotasFavoritas;
  bool get isLoading => _isLoading;
  String get usuarioActual => _usuarioActual;
  int get cantidadFavoritas => _mascotasFavoritas.length;

  void agregarAFavoritos(Map<String, dynamic> mascota) {
    if (!_esFavorita(mascota)) {
      _mascotasFavoritas.add(mascota);
      notifyListeners();
    }
  }

  void removerDeFavoritos(Map<String, dynamic> mascota) {
    _mascotasFavoritas.removeWhere((m) => _sonLaMismaMascota(m, mascota));
    notifyListeners();
  }

  bool _esFavorita(Map<String, dynamic> mascota) {
    return _mascotasFavoritas.any((m) => _sonLaMismaMascota(m, mascota));
  }

  bool _sonLaMismaMascota(
    Map<String, dynamic> mascota1,
    Map<String, dynamic> mascota2,
  ) {
    // Comparar por id si ambas lo tienen
    if (mascota1['id'] != null && mascota2['id'] != null) {
      return mascota1['id'] == mascota2['id'];
    }

    // Comparar por nombre si no tienen id
    final nombre1 = mascota1['nombre'] ?? mascota1['name'];
    final nombre2 = mascota2['nombre'] ?? mascota2['name'];

    if (nombre1 != null && nombre2 != null) {
      return nombre1 == nombre2;
    }

    // Fallback: comparar por referencia
    return mascota1 == mascota2;
  }

  bool isFavorita(Map<String, dynamic> mascota) {
    return _esFavorita(mascota);
  }

  void toggleFavorito(Map<String, dynamic> mascota) {
    if (_esFavorita(mascota)) {
      removerDeFavoritos(mascota);
    } else {
      agregarAFavoritos(mascota);
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setUsuario(String usuario) {
    _usuarioActual = usuario;
    notifyListeners();
  }

  void limpiarFavoritos() {
    _mascotasFavoritas.clear();
    _usuarioActual = 'Usuario Invitado';
    notifyListeners();
  }

  List<Map<String, dynamic>> get mascotasHome => [
    {
      'id': 'misu',
      'name': 'Misu',
      'image': 'assets/misu.jpg',
      'color': const Color(0xFFF9C0AB),
      'type': 'Gato',
      'age': '2 años',
    },
    {
      'id': 'coco',
      'name': 'Coco',
      'image': 'assets/coco.jpg',
      'color': const Color(0xFFA8CD89),
      'type': 'Perro',
      'age': '3 años',
    },
    {
      'id': 'luna',
      'name': 'Luna',
      'image': 'assets/luna.jpg',
      'color': const Color(0xFFF4E0AF),
      'type': 'Gato',
      'age': '1 año',
    },
    {
      'id': 'max',
      'name': 'Max',
      'image': 'assets/max.jpg',
      'color': const Color(0xFF355F2E),
      'type': 'Perro',
      'age': '4 años',
    },
  ];
}

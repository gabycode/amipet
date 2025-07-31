import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_notifier.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _mascotasCollection = 'mascotas';
  static Future<List<Map<String, dynamic>>> obtenerMascotasDestacadas({
    int limite = 10,
  }) async {
    try {
      final querySnapshot =
          await _firestore.collection(_mascotasCollection).limit(limite).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerTodasLasMascotas() async {
    try {
      final querySnapshot =
          await _firestore.collection(_mascotasCollection).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerMascotasPorUsuario(
    String usuarioId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_mascotasCollection)
              .where('usuarioId', isEqualTo: usuarioId)
              .get();

      List<Map<String, dynamic>> mascotas =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      mascotas.sort((a, b) {
        try {
          if (a['fechaRegistro'] != null && b['fechaRegistro'] != null) {
            final fechaA = a['fechaRegistro'] as Timestamp;
            final fechaB = b['fechaRegistro'] as Timestamp;
            return fechaB.compareTo(fechaA);
          }
        } catch (e) {}
        return 0;
      });

      return mascotas;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerMascotasPorEspecie(
    String especie, {
    int limite = 20,
  }) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_mascotasCollection)
              .where('especie', isEqualTo: especie)
              .limit(limite)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String?> registrarMascota(
    Map<String, dynamic> mascotaData,
  ) async {
    try {
      mascotaData['fechaCreacion'] = FieldValue.serverTimestamp();
      mascotaData['fechaActualizacion'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(_mascotasCollection)
          .add(mascotaData);

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> actualizarMascota(
    String mascotaId,
    Map<String, dynamic> nuevosdatos,
  ) async {
    try {
      nuevosdatos['fechaActualizacion'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_mascotasCollection)
          .doc(mascotaId)
          .update(nuevosdatos);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> eliminarMascota(String mascotaId) async {
    try {
      await _firestore.collection(_mascotasCollection).doc(mascotaId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> obtenerMascotaPorId(
    String mascotaId,
  ) async {
    try {
      final docSnapshot =
          await _firestore.collection(_mascotasCollection).doc(mascotaId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id;
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> buscarMascotasPorNombre(
    String nombre, {
    int limite = 10,
  }) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_mascotasCollection)
              .where('nombre', isGreaterThanOrEqualTo: nombre)
              .where('nombre', isLessThan: nombre + 'z')
              .limit(limite)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerMascotasPorUbicacion(
    double latitud,
    double longitud,
    double radioKm, {
    int limite = 20,
  }) async {
    try {
      return await obtenerMascotasDestacadas(limite: limite);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, int>> obtenerEstadisticasMascotas() async {
    try {
      final querySnapshot =
          await _firestore.collection(_mascotasCollection).get();

      int totalMascotas = querySnapshot.docs.length;
      int perros = 0;
      int gatos = 0;
      int otros = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final especie = data['especie'] as String?;

        if (especie == 'Perro') {
          perros++;
        } else if (especie == 'Gato') {
          gatos++;
        } else {
          otros++;
        }
      }

      return {
        'total': totalMascotas,
        'perros': perros,
        'gatos': gatos,
        'otros': otros,
      };
    } catch (e) {
      return {'total': 0, 'perros': 0, 'gatos': 0, 'otros': 0};
    }
  }

  static Stream<List<Map<String, dynamic>>> streamMascotas({int limite = 20}) {
    return _firestore
        .collection(_mascotasCollection)
        .limit(limite)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  static Future<bool> agregarAFavoritos(
    String usuarioId,
    String mascotaId,
  ) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('favoritos')
          .doc(mascotaId)
          .set({
            'mascotaId': mascotaId,
            'fechaAgregado': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removerDeFavoritos(
    String usuarioId,
    String mascotaId,
  ) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('favoritos')
          .doc(mascotaId)
          .delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> obtenerFavoritosUsuario(String usuarioId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('usuarios')
              .doc(usuarioId)
              .collection('favoritos')
              .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String?> enviarFormularioAdopcion({
    required String usuarioId,
    required String mascotaId,
    required Map<String, dynamic> datosFormulario,
  }) async {
    try {
      final formularioData = {
        'usuarioId': usuarioId,
        'mascotaId': mascotaId,
        'datosPersonales': datosFormulario['datosPersonales'],
        'motivacion': datosFormulario['motivacion'],
        'experiencia': datosFormulario['experiencia'],
        'vivienda': datosFormulario['vivienda'],
        'estado': 'pendiente',
        'fechaEnvio': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('formularios_adopcion')
          .add(formularioData);

      await _actualizarContadorFormularios(usuarioId, incremento: 1);

      FormNotifier().notifyFormSubmitted();

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  static Future<void> _actualizarContadorFormularios(
    String usuarioId, {
    int incremento = 1,
  }) async {
    try {
      final userDocRef = _firestore.collection('usuarios').doc(usuarioId);

      await userDocRef.set({
        'estadisticas': {
          'formularios_enviados': FieldValue.increment(incremento),
          'ultima_actividad': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {}
  }

  static Future<int> obtenerCantidadFormulariosUsuario(String usuarioId) async {
    try {
      final userDoc =
          await _firestore.collection('usuarios').doc(usuarioId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final estadisticas = data?['estadisticas'] as Map<String, dynamic>?;
        return estadisticas?['formularios_enviados'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<int> contarFormulariosDirecto(String usuarioId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('formularios_adopcion')
              .where('usuarioId', isEqualTo: usuarioId)
              .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerFormulariosUsuario(
    String usuarioId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('formularios_adopcion')
              .where('usuarioId', isEqualTo: usuarioId)
              .get();

      List<Map<String, dynamic>> formularios =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      formularios.sort((a, b) {
        final fechaA = a['fechaEnvio'] as Timestamp?;
        final fechaB = b['fechaEnvio'] as Timestamp?;

        if (fechaA == null && fechaB == null) return 0;
        if (fechaA == null) return 1;
        if (fechaB == null) return -1;

        return fechaB.compareTo(fechaA);
      });

      return formularios;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> usuarioYaEnvioFormulario(
    String usuarioId,
    String mascotaId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('formularios_adopcion')
              .where('usuarioId', isEqualTo: usuarioId)
              .where('mascotaId', isEqualTo: mascotaId)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> eliminarFormularioAdopcion(
    String formularioId,
    String usuarioId,
  ) async {
    try {
      await _firestore
          .collection('formularios_adopcion')
          .doc(formularioId)
          .delete();

      await _actualizarContadorFormularios(usuarioId, incremento: -1);

      FormNotifier().notifyFormDeleted();

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerFormulariosConMascota(
    String usuarioId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('formularios_adopcion')
              .where('usuarioId', isEqualTo: usuarioId)
              .get();

      List<Map<String, dynamic>> formulariosConMascota = [];

      for (var doc in querySnapshot.docs) {
        final formularioData = doc.data();
        formularioData['id'] = doc.id;

        final mascotaId = formularioData['mascotaId'];
        final mascotaDoc =
            await _firestore.collection('mascotas').doc(mascotaId).get();

        if (mascotaDoc.exists) {
          final mascotaData = mascotaDoc.data()!;
          formularioData['mascota'] = {
            'nombre': mascotaData['nombre'] ?? 'Mascota sin nombre',
            'especie': mascotaData['especie'] ?? 'Especie desconocida',
            'fotoURL': mascotaData['fotoURL'],
            'edad': mascotaData['edad'],
            'unidadEdad': mascotaData['unidadEdad'],
          };
        } else {
          formularioData['mascota'] = {
            'nombre': 'Mascota no encontrada',
            'especie': 'N/A',
            'fotoURL': null,
          };
        }

        formulariosConMascota.add(formularioData);
      }

      formulariosConMascota.sort((a, b) {
        final fechaA = a['fechaEnvio'] as Timestamp?;
        final fechaB = b['fechaEnvio'] as Timestamp?;

        if (fechaA == null && fechaB == null) return 0;
        if (fechaA == null) return 1;
        if (fechaB == null) return -1;

        return fechaB.compareTo(fechaA);
      });

      return formulariosConMascota;
    } catch (e) {
      return [];
    }
  }

  static Future<void> crearPerfilUsuario(
    String usuarioId,
    String email,
    String nombre,
  ) async {
    try {
      await _firestore.collection('usuarios').doc(usuarioId).set({
        'email': email,
        'nombre': nombre,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'estadisticas': {
          'formularios_enviados': 0,
          'mascotas_registradas': 0,
          'ultima_actividad': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {}
  }

  static Future<void> actualizarFotoPerfilUsuario(
    String usuarioId,
    String fotoURL,
  ) async {
    try {
      await _firestore.collection('usuarios').doc(usuarioId).update({
        'fotoURL': fotoURL,
        'ultima_actualizacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e;
    }
  }

  static Future<void> actualizarPerfilUsuario(
    String usuarioId,
    Map<String, dynamic> datosActualizados,
  ) async {
    try {
      datosActualizados['ultima_actualizacion'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .update(datosActualizados);
    } catch (e) {
      throw e;
    }
  }

  static Future<Map<String, dynamic>?> obtenerPerfilUsuario(
    String usuarioId,
  ) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(usuarioId).get();

      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

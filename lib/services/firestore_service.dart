import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colección de mascotas
  static const String _mascotasCollection = 'mascotas';

  // Obtener mascotas destacadas
  static Future<List<Map<String, dynamic>>> obtenerMascotasDestacadas({
    int limite = 10,
  }) async {
    try {
      final querySnapshot =
          await _firestore.collection(_mascotasCollection).limit(limite).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Agregar el ID del documento
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener mascotas destacadas: $e');
      return [];
    }
  }

  // Obtener todas las mascotas
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
      print('Error al obtener todas las mascotas: $e');
      return [];
    }
  }

  // Obtener mascotas por especie
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
      print('Error al obtener mascotas por especie: $e');
      return [];
    }
  }

  // Registrar una nueva mascota
  static Future<String?> registrarMascota(
    Map<String, dynamic> mascotaData,
  ) async {
    try {
      // Agregar timestamp de creación
      mascotaData['fechaCreacion'] = FieldValue.serverTimestamp();
      mascotaData['fechaActualizacion'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection(_mascotasCollection)
          .add(mascotaData);

      print('Mascota registrada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al registrar mascota: $e');
      return null;
    }
  }

  // Actualizar información de una mascota
  static Future<bool> actualizarMascota(
    String mascotaId,
    Map<String, dynamic> nuevosdatos,
  ) async {
    try {
      // Agregar timestamp de actualización
      nuevosdatos['fechaActualizacion'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_mascotasCollection)
          .doc(mascotaId)
          .update(nuevosdatos);

      print('Mascota actualizada: $mascotaId');
      return true;
    } catch (e) {
      print('Error al actualizar mascota: $e');
      return false;
    }
  }

  // Eliminar una mascota
  static Future<bool> eliminarMascota(String mascotaId) async {
    try {
      await _firestore.collection(_mascotasCollection).doc(mascotaId).delete();

      print('Mascota eliminada: $mascotaId');
      return true;
    } catch (e) {
      print('Error al eliminar mascota: $e');
      return false;
    }
  }

  // Obtener una mascota específica por ID
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
      print('Error al obtener mascota por ID: $e');
      return null;
    }
  }

  // Buscar mascotas por nombre
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
      print('Error al buscar mascotas por nombre: $e');
      return [];
    }
  }

  // Obtener mascotas por ubicación (si tienes coordenadas)
  static Future<List<Map<String, dynamic>>> obtenerMascotasPorUbicacion(
    double latitud,
    double longitud,
    double radioKm, {
    int limite = 20,
  }) async {
    try {
      // Para implementar búsqueda por ubicación necesitarías usar GeoFlutterFire
      // Por ahora devolvemos todas las mascotas
      return await obtenerMascotasDestacadas(limite: limite);
    } catch (e) {
      print('Error al obtener mascotas por ubicación: $e');
      return [];
    }
  }

  // Obtener estadísticas de mascotas
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
      print('Error al obtener estadísticas: $e');
      return {'total': 0, 'perros': 0, 'gatos': 0, 'otros': 0};
    }
  }

  // Stream para escuchar cambios en tiempo real
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

  // Agregar mascota a favoritos del usuario (si tienes sistema de usuarios)
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
      print('Error al agregar a favoritos: $e');
      return false;
    }
  }

  // Remover mascota de favoritos
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
      print('Error al remover de favoritos: $e');
      return false;
    }
  }

  // Obtener favoritos del usuario
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
      print('Error al obtener favoritos: $e');
      return [];
    }
  }

  // FUNCIONES PARA FORMULARIOS DE ADOPCIÓN

  // Registrar un formulario de adopción
  static Future<String?> enviarFormularioAdopcion({
    required String usuarioId,
    required String mascotaId,
    required Map<String, dynamic> datosFormulario,
  }) async {
    try {
      // Crear el documento del formulario
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

      // Guardar formulario
      final docRef = await _firestore
          .collection('formularios_adopcion')
          .add(formularioData);

      // Actualizar contador del usuario
      await _actualizarContadorFormularios(usuarioId, incremento: 1);

      print('Formulario de adopción enviado con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error al enviar formulario de adopción: $e');
      return null;
    }
  }

  // Actualizar contador de formularios del usuario
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

      print('Contador de formularios actualizado para usuario: $usuarioId');
    } catch (e) {
      print('Error al actualizar contador de formularios: $e');
    }
  }

  // Obtener cantidad de formularios enviados por un usuario
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
      print('Error al obtener cantidad de formularios: $e');
      return 0;
    }
  }

  // Contar formularios directamente desde la colección (más preciso)
  static Future<int> contarFormulariosDirecto(String usuarioId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('formularios_adopcion')
              .where('usuarioId', isEqualTo: usuarioId)
              .get();

      print(
        'Documentos encontrados en formularios_adopcion: ${querySnapshot.docs.length}',
      );
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error al contar formularios directamente: $e');
      return 0;
    }
  }

  // Obtener historial de formularios del usuario
  static Future<List<Map<String, dynamic>>> obtenerFormulariosUsuario(
    String usuarioId,
  ) async {
    try {
      // Remover orderBy para evitar necesidad de índice compuesto
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

      // Ordenar por fecha en el código (más recientes primero)
      formularios.sort((a, b) {
        final fechaA = a['fechaEnvio'] as Timestamp?;
        final fechaB = b['fechaEnvio'] as Timestamp?;

        if (fechaA == null && fechaB == null) return 0;
        if (fechaA == null) return 1;
        if (fechaB == null) return -1;

        return fechaB.compareTo(fechaA); // Más recientes primero
      });

      return formularios;
    } catch (e) {
      print('Error al obtener formularios del usuario: $e');
      return [];
    }
  }

  // Verificar si un usuario ya envió formulario para una mascota específica
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
      print('Error al verificar formulario existente: $e');
      return false;
    }
  }

  // Eliminar formulario de adopción
  static Future<bool> eliminarFormularioAdopcion(
    String formularioId,
    String usuarioId,
  ) async {
    try {
      // Eliminar el documento del formulario
      await _firestore
          .collection('formularios_adopcion')
          .doc(formularioId)
          .delete();

      // Actualizar contador del usuario (decrementar)
      await _actualizarContadorFormularios(usuarioId, incremento: -1);

      print('Formulario eliminado: $formularioId');
      return true;
    } catch (e) {
      print('Error al eliminar formulario: $e');
      return false;
    }
  }

  // Obtener formularios con información de mascotas
  static Future<List<Map<String, dynamic>>> obtenerFormulariosConMascota(
    String usuarioId,
  ) async {
    try {
      // Remover orderBy para evitar necesidad de índice compuesto
      final querySnapshot =
          await _firestore
              .collection('formularios_adopcion')
              .where('usuarioId', isEqualTo: usuarioId)
              .get();

      List<Map<String, dynamic>> formulariosConMascota = [];

      for (var doc in querySnapshot.docs) {
        final formularioData = doc.data();
        formularioData['id'] = doc.id;

        // Obtener información de la mascota
        final mascotaId = formularioData['mascotaId'];
        final mascotaDoc =
            await _firestore.collection('mascotas').doc(mascotaId).get();

        if (mascotaDoc.exists) {
          final mascotaData = mascotaDoc.data()!;
          formularioData['mascota'] = {
            'nombre': mascotaData['nombre'] ?? 'Mascota sin nombre',
            'especie': mascotaData['especie'] ?? 'Especie desconocida',
            'fotoURL': mascotaData['fotoURL'],
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

      // Ordenar por fecha en el código (más recientes primero)
      formulariosConMascota.sort((a, b) {
        final fechaA = a['fechaEnvio'] as Timestamp?;
        final fechaB = b['fechaEnvio'] as Timestamp?;

        if (fechaA == null && fechaB == null) return 0;
        if (fechaA == null) return 1;
        if (fechaB == null) return -1;

        return fechaB.compareTo(fechaA); // Más recientes primero
      });

      return formulariosConMascota;
    } catch (e) {
      print('Error al obtener formularios con mascota: $e');
      return [];
    }
  }

  // Crear perfil de usuario si no existe
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

      print('Perfil de usuario creado/actualizado: $usuarioId');
    } catch (e) {
      print('Error al crear perfil de usuario: $e');
    }
  }
}

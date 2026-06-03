import 'package:cloud_firestore/cloud_firestore.dart';

class PermisosDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get permisos =>
      _firestore.collection('permisos');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamByUsuario(String userId) {
    return permisos.where('usuarioId', isEqualTo: userId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAll() =>
      permisos.snapshots();

  Future<void> addPermiso(Map<String, dynamic> data) => permisos.add(data);

  Future<void> updatePermiso(String id, Map<String, dynamic> data) =>
      permisos.doc(id).update(data);

  Future<QuerySnapshot<Map<String, dynamic>>> countAusenciasAprobadas(
    String userId,
  ) {
    return permisos
        .where('usuarioId', isEqualTo: userId)
        .where('tipo', isEqualTo: 'ausencia')
        .where('estado', isEqualTo: 'aprobado')
        .get();
  }
}

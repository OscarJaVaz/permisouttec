import 'package:firebase_database/firebase_database.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_date_helper.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_paths.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';

class PermisosDatasource {
  PermisosDatasource(this._database);

  final FirebaseDatabase _database;

  DatabaseReference get _permisos => _database.ref(RtdbPaths.permisos);

  Stream<List<RtdbRecord>> streamByUsuario(String userId) {
    return _permisos
        .orderByChild('usuarioId')
        .equalTo(userId)
        .onValue
        .map(_snapshotToRecords);
  }

  Stream<List<RtdbRecord>> streamAll() =>
      _permisos.onValue.map(_snapshotToRecords);

  Future<String> addPermiso(Map<String, dynamic> data) async {
    final ref = _permisos.push();
    await ref.set(data);
    return ref.key!;
  }

  Future<void> updatePermiso(String id, Map<String, dynamic> data) =>
      _permisos.child(id).update(data);

  Future<List<RtdbRecord>> findByUsuarioAndFecha(
    String userId,
    DateTime fecha,
  ) async {
    final records = await getByUsuario(userId);
    return records
        .where((r) => RtdbDateHelper.isSameDay(r.data['fecha'], fecha))
        .toList();
  }

  Future<List<RtdbRecord>> getByUsuario(String userId) async {
    final snapshot =
        await _permisos.orderByChild('usuarioId').equalTo(userId).get();
    return _snapshotDataToRecords(snapshot);
  }

  Future<int> countAusenciasAprobadas(String userId) async {
    final records = await getByUsuario(userId);
    return records
        .where(
          (r) =>
              r.string('tipo') == 'ausencia' && r.string('estado') == 'aprobado',
        )
        .length;
  }

  List<RtdbRecord> _snapshotToRecords(DatabaseEvent event) =>
      _snapshotDataToRecords(event.snapshot);

  List<RtdbRecord> _snapshotDataToRecords(DataSnapshot snapshot) {
    final value = snapshot.value;
    if (value == null) return [];
    final map = Map<dynamic, dynamic>.from(value as Map);
    return map.entries
        .map(
          (e) => RtdbRecord(
            id: e.key.toString(),
            data: Map<dynamic, dynamic>.from(e.value as Map),
          ),
        )
        .toList();
  }
}

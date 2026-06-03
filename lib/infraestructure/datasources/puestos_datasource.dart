import 'package:firebase_database/firebase_database.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_paths.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';

class PuestosDatasource {
  PuestosDatasource(this._database);

  final FirebaseDatabase _database;

  DatabaseReference get _puestos => _database.ref(RtdbPaths.puestos);

  Stream<List<RtdbRecord>> streamAll() =>
      _puestos.onValue.map(_snapshotToRecords);

  Future<Map<dynamic, dynamic>?> getById(String id) async {
    final snapshot = await _puestos.child(id).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return Map<dynamic, dynamic>.from(snapshot.value as Map);
  }

  Future<List<String>> listNombres() async {
    final snapshot = await _puestos.get();
    if (!snapshot.exists || snapshot.value == null) return [];
    final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
    return map.values
        .map((v) => (v as Map)['nombre'] as String?)
        .where((n) => n != null)
        .cast<String>()
        .toList();
  }

  Future<String> create(Map<String, dynamic> data) async {
    final ref = _puestos.push();
    await ref.set(data);
    return ref.key!;
  }

  Future<void> update(String id, Map<String, dynamic> data) =>
      _puestos.child(id).update(data);

  Future<void> delete(String id) => _puestos.child(id).remove();

  List<RtdbRecord> _snapshotToRecords(DatabaseEvent event) {
    final value = event.snapshot.value;
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

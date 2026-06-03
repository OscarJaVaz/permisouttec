import 'package:firebase_database/firebase_database.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_paths.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';

class ProfesoresDatasource {
  ProfesoresDatasource(this._database);

  final FirebaseDatabase _database;

  DatabaseReference get _profesores => _database.ref(RtdbPaths.profesores);

  Stream<List<RtdbRecord>> streamAll() =>
      _profesores.onValue.map(_snapshotToRecords);

  Future<Map<dynamic, dynamic>?> getById(String id) async {
    final snapshot = await _profesores.child(id).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return Map<dynamic, dynamic>.from(snapshot.value as Map);
  }

  Future<String> create(Map<String, dynamic> data) async {
    final ref = _profesores.push();
    await ref.set(data);
    return ref.key!;
  }

  Future<void> update(String id, Map<String, dynamic> data) =>
      _profesores.child(id).update(data);

  Future<void> delete(String id) => _profesores.child(id).remove();

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

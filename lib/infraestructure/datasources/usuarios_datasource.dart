import 'package:firebase_database/firebase_database.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_paths.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';

class UsuariosDatasource {
  UsuariosDatasource(this._database);

  final FirebaseDatabase _database;

  DatabaseReference get _usuarios => _database.ref(RtdbPaths.usuarios);

  Future<Map<dynamic, dynamic>?> getUsuarioData(String uid) async {
    final snapshot = await _usuarios.child(uid).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return Map<dynamic, dynamic>.from(snapshot.value as Map);
  }

  Future<void> setUsuario(String uid, Map<String, dynamic> data) =>
      _usuarios.child(uid).set(data);

  Future<void> updateUsuario(String uid, Map<String, dynamic> data) =>
      _usuarios.child(uid).update(data);

  Stream<List<RtdbRecord>> streamSolicitudesDirectivo() {
    return _usuarios
        .orderByChild('solicitud_directivo')
        .equalTo(true)
        .onValue
        .map(_snapshotToRecords);
  }

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

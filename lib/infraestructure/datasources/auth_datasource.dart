import 'package:firebase_auth/firebase_auth.dart';
import 'package:permisouttec/domain/entities/usuario_entity.dart';
import 'package:permisouttec/infraestructure/datasources/usuarios_datasource.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_date_helper.dart';
import 'package:permisouttec/services/rtdb_auth_sync.dart';
import 'package:permisouttec/services/rtdb_connection.dart';

class AuthDatasource {
  AuthDatasource(this._usuariosDatasource);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UsuariosDatasource _usuariosDatasource;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UsuarioEntity?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;
    await syncAuthTokenForRtdb();
    await connectRtdb();
    return fetchUsuario(user.uid);
  }

  Future<UsuarioEntity?> fetchUsuario(String uid) async {
    final data = await _usuariosDatasource.getUsuarioData(uid);
    if (data == null) return null;
    return UsuarioEntity(
      uid: uid,
      email: data['email'] as String?,
      puesto: data['puesto'] as String?,
      solicitudDirectivo: data['solicitud_directivo'] as bool? ?? false,
      aprobadoDirectivo: data['aprobado_directivo'] as bool? ?? false,
      nombre: data['nombre'] as String?,
      apellido: data['apellido'] as String?,
      telefono: data['telefono'] as String?,
      fechaNacimiento: RtdbDateHelper.fromValue(data['fecha_nacimiento']),
    );
  }

  Future<void> signOut() => _auth.signOut();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permisouttec/domain/entities/usuario_entity.dart';

class AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    return fetchUsuario(user.uid);
  }

  Future<UsuarioEntity?> fetchUsuario(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UsuarioEntity(
      uid: uid,
      email: data['email'] as String?,
      puesto: data['puesto'] as String?,
      solicitudDirectivo: data['solicitud_directivo'] as bool? ?? false,
      aprobadoDirectivo: data['aprobado_directivo'] as bool? ?? false,
    );
  }

  Future<void> signOut() => _auth.signOut();
}

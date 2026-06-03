import 'package:permisouttec/domain/entities/usuario_entity.dart';
import 'package:permisouttec/domain/repositories/auth_repository.dart';
import 'package:permisouttec/infraestructure/datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final AuthDatasource _datasource;

  @override
  Future<UsuarioEntity?> signIn(String email, String password) =>
      _datasource.signInWithEmailAndPassword(email, password);

  @override
  Future<void> signOut() => _datasource.signOut();
}

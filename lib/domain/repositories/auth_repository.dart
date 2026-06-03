import 'package:permisouttec/domain/entities/usuario_entity.dart';

abstract class AuthRepository {
  Future<UsuarioEntity?> signIn(String email, String password);
  Future<void> signOut();
}

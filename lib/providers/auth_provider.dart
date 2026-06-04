import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/domain/entities/usuario_entity.dart';
import 'package:permisouttec/infraestructure/datasources/auth_datasource.dart';
import 'package:permisouttec/infraestructure/repositories/auth_repository_impl.dart';
import 'package:permisouttec/providers/permisos_provider.dart';

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return AuthDatasource(ref.watch(usuariosDatasourceProvider));
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authDatasourceProvider).authStateChanges();
});

final currentUsuarioProvider = FutureProvider<UsuarioEntity?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(authDatasourceProvider).fetchUsuario(user.uid);
});

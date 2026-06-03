import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

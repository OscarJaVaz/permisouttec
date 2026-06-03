import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/infraestructure/datasources/divisiones_datasource.dart';
import 'package:permisouttec/infraestructure/datasources/permisos_datasource.dart';
import 'package:permisouttec/infraestructure/datasources/profesores_datasource.dart';
import 'package:permisouttec/infraestructure/datasources/puestos_datasource.dart';
import 'package:permisouttec/infraestructure/datasources/usuarios_datasource.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';
import 'package:permisouttec/providers/rtdb_provider.dart';

final usuariosDatasourceProvider = Provider<UsuariosDatasource>((ref) {
  return UsuariosDatasource(ref.watch(firebaseDatabaseProvider));
});

final permisosDatasourceProvider = Provider<PermisosDatasource>((ref) {
  return PermisosDatasource(ref.watch(firebaseDatabaseProvider));
});

/// Stream estable por usuario; evita recrear la suscripción en cada rebuild.
final permisosByUsuarioStreamProvider =
    StreamProvider.autoDispose.family<List<RtdbRecord>, String>((ref, userId) {
  return ref.watch(permisosDatasourceProvider).streamByUsuario(userId);
});

final profesoresDatasourceProvider = Provider<ProfesoresDatasource>((ref) {
  return ProfesoresDatasource(ref.watch(firebaseDatabaseProvider));
});

final puestosDatasourceProvider = Provider<PuestosDatasource>((ref) {
  return PuestosDatasource(ref.watch(firebaseDatabaseProvider));
});

final divisionesDatasourceProvider = Provider<DivisionesDatasource>((ref) {
  return DivisionesDatasource(ref.watch(firebaseDatabaseProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/infraestructure/datasources/permisos_datasource.dart';

final permisosDatasourceProvider = Provider<PermisosDatasource>((ref) {
  return PermisosDatasource();
});

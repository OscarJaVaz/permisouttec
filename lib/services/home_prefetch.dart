import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/domain/entities/usuario_entity.dart';
import 'package:permisouttec/providers/permisos_provider.dart';

String homeRouteForUsuario(UsuarioEntity usuario) {
  if (usuario.solicitudDirectivo && !usuario.aprobadoDirectivo) {
    return AppRoutes.homeProfesor;
  }
  if (usuario.puesto == 'Directivo') return AppRoutes.home;
  if (usuario.puesto == 'Profesor') return AppRoutes.homeProfesor;
  return AppRoutes.homeProfesor;
}

/// Precarga datos de home antes de navegar para evitar spinner al llegar.
Future<void> prefetchHomeData(WidgetRef ref, UsuarioEntity usuario) async {
  if (homeRouteForUsuario(usuario) != AppRoutes.homeProfesor) return;
  await ref.read(permisosByUsuarioStreamProvider(usuario.uid).future);
}

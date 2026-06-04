import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/domain/entities/usuario_entity.dart';
import 'package:permisouttec/providers/permisos_provider.dart';
import 'package:permisouttec/services/rtdb_auth_sync.dart';

String homeRouteForUsuario(UsuarioEntity usuario) {
  if (usuario.solicitudDirectivo && !usuario.aprobadoDirectivo) {
    return AppRoutes.homeProfesor;
  }
  if (usuario.puesto == 'Directivo') return AppRoutes.home;
  if (usuario.puesto == 'Profesor') return AppRoutes.homeProfesor;
  return AppRoutes.homeProfesor;
}

/// Precarga datos de home antes de navegar para evitar spinner al llegar.
Future<void> prefetchHomeData(
  ProviderContainer container,
  UsuarioEntity usuario,
) async {
  if (homeRouteForUsuario(usuario) != AppRoutes.homeProfesor) return;

  await syncAuthTokenForRtdb();

  try {
    await container.read(permisosByUsuarioStreamProvider(usuario.uid).future);
  } on FirebaseException catch (e) {
    if (e.code != 'permission-denied') rethrow;
    await syncAuthTokenForRtdb();
    await container.read(permisosByUsuarioStreamProvider(usuario.uid).future);
  }
}

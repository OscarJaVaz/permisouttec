import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/providers/auth_provider.dart';
import 'package:permisouttec/providers/permisos_provider.dart';
import 'package:permisouttec/services/rtdb_connection.dart';

/// Cierra sesión, cancela streams RTDB en caché y corta la conexión temporalmente.
Future<void> signOutAndClearRtdb(WidgetRef ref) async {
  ref.invalidate(permisosByUsuarioStreamProvider);
  ref.invalidate(currentUsuarioProvider);
  ref.invalidate(profesoresStreamProvider);
  ref.invalidate(puestosStreamProvider);
  ref.invalidate(divisionesStreamProvider);
  ref.invalidate(permisosAllStreamProvider);
  ref.invalidate(solicitudesDirectivoStreamProvider);

  await disconnectRtdb();
  await ref.read(authRepositoryProvider).signOut();
}

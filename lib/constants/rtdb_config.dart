/// URL de Realtime Database (proyecto uttec-permisos-2f8b3).
/// Debe coincidir el proyecto de Firebase Auth con el de RTDB para que
/// `auth != null` en las reglas funcione; alinear google-services.json si aplica.
abstract final class RtdbConfig {
  static const databaseUrl =
      'https://uttec-permisos-2f8b3-default-rtdb.firebaseio.com';
}

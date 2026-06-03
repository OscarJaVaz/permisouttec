import 'package:firebase_auth/firebase_auth.dart';

/// Refresca el ID token de Auth antes de operaciones en Realtime Database.
/// Evita el error "authentication credentials are invalid" al conectar justo
/// después de crear cuenta o iniciar sesión.
Future<void> syncAuthTokenForRtdb() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  await user.getIdToken(true);
}

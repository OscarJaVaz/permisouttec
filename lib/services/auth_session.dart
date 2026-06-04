import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/domain/entities/usuario_entity.dart';
import 'package:permisouttec/providers/auth_provider.dart';
import 'package:permisouttec/providers/biometric_login_provider.dart';
import 'package:permisouttec/services/home_prefetch.dart';

class AuthSessionResult {
  const AuthSessionResult({
    this.usuario,
    this.firebaseErrorCode,
  });

  final UsuarioEntity? usuario;
  final String? firebaseErrorCode;

  bool get isSuccess => usuario != null;
}

Future<AuthSessionResult> signInAndPrefetchSession(
  ProviderContainer container, {
  required String email,
  required String password,
  bool persistForBiometric = false,
}) async {
  try {
    final usuario = await container
        .read(authRepositoryProvider)
        .signIn(email, password);
    if (usuario == null) {
      return const AuthSessionResult();
    }

    if (persistForBiometric) {
      await container.read(secureCredentialStorageProvider).saveCredentials(
            email: email,
            password: password,
            displayName: usuario.displayName,
          );
      refreshStoredCredentials(container);
    }

    await prefetchHomeData(container, usuario);
    return AuthSessionResult(usuario: usuario);
  } on FirebaseAuthException catch (e) {
    return AuthSessionResult(firebaseErrorCode: e.code);
  }
}

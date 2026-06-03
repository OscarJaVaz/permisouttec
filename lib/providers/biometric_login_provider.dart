import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/domain/entities/stored_credential_profile.dart';
import 'package:permisouttec/services/biometric_auth_service.dart';
import 'package:permisouttec/services/secure_credential_storage.dart';

final secureCredentialStorageProvider = Provider<SecureCredentialStorage>((ref) {
  return SecureCredentialStorage();
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

/// Incrementar para recargar [storedCredentialProfileProvider] tras guardar o borrar.
final storedCredentialsRevisionProvider = StateProvider<int>((ref) => 0);

final storedCredentialProfileProvider =
    FutureProvider<StoredCredentialProfile?>((ref) async {
  ref.watch(storedCredentialsRevisionProvider);
  final storage = ref.watch(secureCredentialStorageProvider);
  if (!await storage.hasStoredCredentials()) return null;
  return storage.readProfile();
});

void refreshStoredCredentials(WidgetRef ref) {
  ref.read(storedCredentialsRevisionProvider.notifier).state++;
}

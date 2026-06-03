import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permisouttec/domain/entities/stored_credential_profile.dart';

class SecureCredentialStorage {
  SecureCredentialStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage();

  static const _keyEmail = 'auth_email';
  static const _keyPassword = 'auth_password';
  static const _keyDisplayName = 'auth_display_name';

  final FlutterSecureStorage _storage;

  Future<bool> hasStoredCredentials() async {
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    return email != null &&
        email.isNotEmpty &&
        password != null &&
        password.isNotEmpty;
  }

  Future<StoredCredentialProfile?> readProfile() async {
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    final displayName = await _storage.read(key: _keyDisplayName);
    if (email == null || password == null || email.isEmpty || password.isEmpty) {
      return null;
    }
    return StoredCredentialProfile(
      email: email,
      password: password,
      displayName: displayName?.isNotEmpty == true
          ? displayName!
          : _displayNameFromEmail(email),
    );
  }

  Future<void> saveCredentials({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(
      key: _keyDisplayName,
      value: displayName ?? _displayNameFromEmail(email),
    );
  }

  Future<void> clearCredentials() => _storage.deleteAll();

  static String _displayNameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return 'Usuario';
    return local
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}

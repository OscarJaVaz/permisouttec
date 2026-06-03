import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAvailability {
  const BiometricAvailability({
    required this.isAvailable,
    this.message,
  });

  final bool isAvailable;
  final String? message;
}

class BiometricAuthResult {
  const BiometricAuthResult({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;
}

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<BiometricAvailability> checkAvailability() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) {
        return const BiometricAvailability(
          isAvailable: false,
          message:
              'Este dispositivo no admite bloqueo de pantalla ni biometría.',
        );
      }

      final enrolled = await _localAuth.getAvailableBiometrics();
      if (enrolled.isEmpty) {
        return const BiometricAvailability(
          isAvailable: false,
          message:
              'Configure huella, rostro o PIN en Ajustes del teléfono para usar acceso biométrico.',
        );
      }

      return const BiometricAvailability(isAvailable: true);
    } on PlatformException catch (e) {
      return BiometricAvailability(
        isAvailable: false,
        message: e.message ?? 'No se pudo comprobar la biometría.',
      );
    } catch (_) {
      return const BiometricAvailability(
        isAvailable: false,
        message: 'No se pudo comprobar la biometría.',
      );
    }
  }

  Future<BiometricAuthResult> authenticate({
    String reason = 'Confirme su identidad para entrar',
  }) async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (ok) {
        return const BiometricAuthResult(success: true);
      }
      return const BiometricAuthResult(
        success: false,
        message: 'Autenticación cancelada.',
      );
    } on PlatformException catch (e) {
      return BiometricAuthResult(
        success: false,
        message: _messageForPlatformException(e),
      );
    } catch (_) {
      return const BiometricAuthResult(
        success: false,
        message: 'No se pudo abrir el lector biométrico.',
      );
    }
  }

  String _messageForPlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
      case 'notAvailable':
        return 'Biometría no disponible. Revise la configuración de seguridad del dispositivo.';
      case 'NotEnrolled':
      case 'notEnrolled':
        return 'No hay huella ni rostro registrados en el dispositivo.';
      case 'LockedOut':
      case 'lockedOut':
        return 'Demasiados intentos fallidos. Espere un momento e intente de nuevo.';
      case 'PermanentlyLockedOut':
      case 'permanentlyLockedOut':
        return 'Biometría bloqueada. Use el bloqueo de pantalla del teléfono e intente más tarde.';
      default:
        return e.message ?? 'Error al verificar la biometría (${e.code}).';
    }
  }
}

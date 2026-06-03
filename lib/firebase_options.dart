import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones del cliente Android `com.davdolhergodjanavi.permisouttec`
/// (proyecto uttec-permisos-2f8b3). Debe coincidir con google-services.json.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase web no está configurado.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Plataforma no soportada: $defaultTargetPlatform. '
          'Ejecuta flutterfire configure para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAewDVrwuRSe26WwlBT2P2pjplBpAR-vs4',
    appId: '1:436192795067:android:4807a9c88df9ca6c064c9e',
    messagingSenderId: '436192795067',
    projectId: 'uttec-permisos-2f8b3',
    databaseURL: 'https://uttec-permisos-2f8b3-default-rtdb.firebaseio.com',
    storageBucket: 'uttec-permisos-2f8b3.firebasestorage.app',
  );
}

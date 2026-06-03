import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:permisouttec/firebase_options.dart';

class FirebaseService {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

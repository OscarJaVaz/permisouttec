import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permisouttec/firebase_options.dart';

FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.android.databaseURL,
    );

Future<void> disconnectRtdb() => _database.goOffline();

Future<void> connectRtdb() => _database.goOnline();

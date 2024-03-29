import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permisouttec/pages/NuevaDivision.dart';
import 'package:permisouttec/pages/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const LoginPageWithBackground(),
    );
  }
}

class LoginPageWithBackground extends StatelessWidget {
  const LoginPageWithBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://wallpapercave.com/wp/wp2721266.jpg"), // URL de la imagen de fondo
            fit: BoxFit.cover,
          ),
        ),
        child: const Login(),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permisouttec/pages/HomePage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Login App',
      home: login(),
    );
  }
}

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  var txtUserController = TextEditingController();
  var txtPassController = TextEditingController();

  Future<void> fnLogin() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      print('Validando Usuario');
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: txtUserController.text,
        password: txtPassController.text,
      );
      user = userCredential.user;
      print('user found');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      print('error: ${e.code} ${e.message}');
      if (e.code == 'user-not-found') {
        print('no user found for that email');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided');
        showIncorrectCredentialsAlert();
      }
    }
  }

  void showIncorrectCredentialsAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Credenciales incorrectas'),
          content: Text('El correo electrónico o la contraseña son incorrectos.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.white54,
      appBar: AppBar(
        title: Text('Permisos Uttec'),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/5509/5509636.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),

            TextField(
              controller: txtUserController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: txtPassController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fnLogin,
              child: Text('Iniciar sesión'),
            ),
          ],
        ),
      ),


    );


  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permisouttec/pages/HomePage.dart';
import 'package:permisouttec/pages/HomePageProfesor.dart';
import 'package:permisouttec/pages/RegistroPage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> fnLogin() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      print('Validating User');
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      user = userCredential.user;
      print('User found');

      // Get user role from Firestore
      DocumentSnapshot userInfo =
      await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).get();
      String? rol = userInfo['puesto'];

      // Redirect based on user role
      if (rol == 'Directivo') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false, // Remove all routes from the stack
        );
      } else if (rol == 'Profesor') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePageProfesor()),
              (route) => false, // Remove all routes from the stack
        );
      }
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
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              obscureText: _obscureText,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fnLogin,
              child: Text('Iniciar sesión'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("¿Usuario nuevo?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistroPage()),
                    );
                  },
                  child: Text("Regístrate aquí"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

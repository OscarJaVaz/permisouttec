import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permisouttec/pages/HomePage.dart';
import 'package:permisouttec/pages/HomePageProfesor.dart';
import 'package:permisouttec/pages/login.dart'; // Importa la página de inicio de sesión

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedPuesto;
  final List<String> _puestos = ['Directivo', 'Profesor'];

  void _register() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Agregar el usuario a Firestore con el puesto seleccionado
      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'email': _emailController.text,
        'puesto': _selectedPuesto,
      });

      // Mostrar alerta de registro exitoso
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registro exitoso'),
            content: Text('Te has registrado correctamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar la alerta
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()), // Redirigir a la pantalla de inicio de sesión
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error al registrar: $e');
      // Manejar errores de registro aquí
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comienza tu registro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: _selectedPuesto,
              onChanged: (newValue) {
                setState(() {
                  _selectedPuesto = newValue.toString();
                });
              },
              items: _puestos.map((puesto) {
                return DropdownMenuItem(
                  value: puesto,
                  child: Text(puesto),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Puesto'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}

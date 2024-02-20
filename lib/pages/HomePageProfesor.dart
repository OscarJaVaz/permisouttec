import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permisouttec/pages/NuevoPermiso.dart';
import 'package:permisouttec/pages/login.dart'; // Asegúrate de importar la página de inicio de sesión

class HomePageProfesor extends StatefulWidget {
  @override
  _HomePageProfesorState createState() => _HomePageProfesorState();
}

class _HomePageProfesorState extends State<HomePageProfesor> {
  // Método para cerrar sesión
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Redirigir a la pantalla de inicio de sesión y reemplazar la vista actual
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()), // Redirigir a la página de inicio de sesión
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio - Profesor'),
        actions: [
          IconButton(
            onPressed: _logout, // Llamar al método de cierre de sesión al hacer clic en el botón
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NuevoPermiso()),
            );
          },
          child: Text('Solicitar Permiso'),
        ),
      ),
    );
  }
}

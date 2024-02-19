import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permisouttec/pages/NuevoPermiso.dart';

class HomePageProfesor extends StatefulWidget {
  @override
  _HomePageProfesorState createState() => _HomePageProfesorState();
}

class _HomePageProfesorState extends State<HomePageProfesor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio - Profesor'),
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

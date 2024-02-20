import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permisouttec/pages/VisualizarPermisos.dart';

class HomePageDirectivo extends StatefulWidget {
  @override
  _HomePageDirectivoState createState() => _HomePageDirectivoState();
}

class _HomePageDirectivoState extends State<HomePageDirectivo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio - Directivo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VisualizarPermisos()),
            );
          },
          child: Text('Ver Permisos Solicitados'),
        ),
      ),
    );
  }
}

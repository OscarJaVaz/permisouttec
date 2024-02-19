import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NuevoPermiso extends StatefulWidget {
  @override
  _NuevoPermisoState createState() => _NuevoPermisoState();
}

class _NuevoPermisoState extends State<NuevoPermiso> {
  final _tipoPermisoController = TextEditingController();

  Future<void> _solicitarPermiso() async {
    // Obtener el ID del usuario actualmente autenticado
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Agregar la solicitud de permiso a la colección correspondiente
    await FirebaseFirestore.instance.collection('permisos').add({
      'usuarioId': userId,
      'tipo': _tipoPermisoController.text,
      'estado': 'pendiente',
    });

    // Regresar a la página de inicio del profesor
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Permiso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tipoPermisoController,
              decoration: InputDecoration(labelText: 'Tipo de Permiso'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _solicitarPermiso,
              child: Text('Solicitar Permiso'),
            ),
          ],
        ),
      ),
    );
  }
}

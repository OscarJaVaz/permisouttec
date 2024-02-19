import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisualizarPermisos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permisos Solicitados'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('permisos').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Sin registros'));
          }
          List<DocumentSnapshot> docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot doc = docs[index];
              return ListTile(
                title: Text('Tipo: ${doc['tipo']}'),
                subtitle: Text('Estado: ${doc['estado']}'),
                // Agregar botones de acción para aprobar o rechazar permisos
                // Lógica de aprobación y rechazo se implementará según tu necesidad
              );
            },
          );
        },
      ),
    );
  }
}

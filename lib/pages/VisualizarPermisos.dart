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
              final String estado = doc['estado'];

              // Verificar si el campo 'archivado' existe en el documento
              final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

              // Si el campo 'archivado' existe y es verdadero, se archiva el permiso
              final bool archivado = data != null && data.containsKey('archivado') ? data['archivado'] : false;

              // Mostrar permisos no archivados para el directivo
              if (!archivado) {
                return ListTile(
                  title: Text('Tipo: ${doc['tipo']}'),
                  subtitle: Text('Estado: $estado'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Lógica para archivar permiso
                          _updatePermissionStatus(doc.id, estado, true);
                        },
                        child: Text('Archivar'),
                      ),
                      if (estado == 'pendiente')
                        ElevatedButton(
                          onPressed: () {
                            // Lógica para aprobar permiso
                            _updatePermissionStatus(doc.id, 'aprobado', false);
                          },
                          child: Text('Aprobar'),
                        ),
                      if (estado == 'pendiente')
                        ElevatedButton(
                          onPressed: () {
                            // Lógica para rechazar permiso
                            _updatePermissionStatus(doc.id, 'rechazado', false);
                          },
                          child: Text('Rechazar'),
                        ),
                    ],
                  ),
                );
              } else {
                return SizedBox.shrink(); // Ocultar permisos archivados
              }
            },
          );
        },
      ),
    );
  }

  // Método para actualizar el estado del permiso en Firestore
  void _updatePermissionStatus(String permissionId, String newStatus, bool archive) async {
    if (archive) {
      // Archivar el permiso
      await FirebaseFirestore.instance.collection('permisos').doc(permissionId).update({
        'estado': newStatus,
        'archivado': true,
      });
    } else {
      // Actualizar el estado del permiso a "aprobado" o "rechazado"
      await FirebaseFirestore.instance.collection('permisos').doc(permissionId).update({
        'estado': newStatus,
      });
    }
  }
}

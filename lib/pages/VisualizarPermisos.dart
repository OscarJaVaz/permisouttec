import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisualizarPermisos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text('Permisos Solicitados'),
          ),
        ),
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

              // Mostrar permisos no archivados
              if (!archivado) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ExpansionTile(
                    title: ListTile(
                      title: Text('Tipo: ${doc['tipo']}'),
                      subtitle: Text('Estado: $estado'),
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Lógica para archivar permiso
                              _updatePermissionStatus(doc.id, estado, true);
                            },
                            icon: Icon(Icons.archive),
                            label: Text('Archivar'),
                          ),
                          if (estado == 'pendiente')
                            ElevatedButton.icon(
                              onPressed: () {
                                // Lógica para aprobar permiso
                                _updatePermissionStatus(doc.id, 'aprobado', false);
                              },
                              icon: Icon(Icons.thumb_up),
                              label: Text('Aprobar'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.green), // Cambia el color de fondo
                              ),
                            ),
                          if (estado == 'pendiente')
                            ElevatedButton.icon(
                              onPressed: () {
                                // Lógica para rechazar permiso
                                _updatePermissionStatus(doc.id, 'rechazado', false);
                              },
                              icon: Icon(Icons.thumb_down),
                              label: Text('Rechazar'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Cambia el color de fondo
                              ),
                            ),
                        ],
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

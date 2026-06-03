import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permisouttec/infraestructure/datasources/permisos_datasource.dart';

class VisualizarPermisos extends StatelessWidget {
  const VisualizarPermisos({super.key});

  static final _permisosDs = PermisosDatasource();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: const Text('Permisos Solicitados'),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _permisosDs.streamAll(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Sin registros'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot doc = docs[index];
              final String estado = doc['estado'];
              final Map<String, dynamic>? data =
                  doc.data() as Map<String, dynamic>?;
              final bool archivado = data != null &&
                  data.containsKey('archivado')
                  ? data['archivado']
                  : false;

              if (!archivado) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
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
                              _updatePermissionStatus(doc.id, estado, true);
                            },
                            icon: const Icon(Icons.archive),
                            label: const Text('Archivar'),
                          ),
                          if (estado == 'pendiente')
                            ElevatedButton.icon(
                              onPressed: () {
                                _updatePermissionStatus(
                                  doc.id,
                                  'aprobado',
                                  false,
                                );
                              },
                              icon: const Icon(Icons.thumb_up),
                              label: const Text('Aprobar'),
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(
                                  Colors.green,
                                ),
                              ),
                            ),
                          if (estado == 'pendiente')
                            ElevatedButton.icon(
                              onPressed: () {
                                _updatePermissionStatus(
                                  doc.id,
                                  'rechazado',
                                  false,
                                );
                              },
                              icon: const Icon(Icons.thumb_down),
                              label: const Text('Rechazar'),
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }

  void _updatePermissionStatus(
    String permissionId,
    String newStatus,
    bool archive,
  ) async {
    if (archive) {
      await _permisosDs.updatePermiso(permissionId, {
        'estado': newStatus,
        'archivado': true,
      });
    } else {
      await _permisosDs.updatePermiso(permissionId, {'estado': newStatus});
    }
  }
}

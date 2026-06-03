import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';
import 'package:permisouttec/providers/permisos_provider.dart';

class VisualizarPermisos extends ConsumerWidget {
  const VisualizarPermisos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(permisosDatasourceProvider).streamAll();

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
      body: StreamBuilder<List<RtdbRecord>>(
        stream: stream,
        builder: (context, AsyncSnapshot<List<RtdbRecord>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('Sin registros'));
          }
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final String estado = record.string('estado') ?? '';
              final bool archivado = record.boolValue('archivado');

              if (!archivado) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: ExpansionTile(
                    title: ListTile(
                      title: Text('Tipo: ${record.string('tipo')}'),
                      subtitle: Text('Estado: $estado'),
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _updatePermissionStatus(
                                ref,
                                record.id,
                                estado,
                                true,
                              );
                            },
                            icon: const Icon(Icons.archive),
                            label: const Text('Archivar'),
                          ),
                          if (estado == 'pendiente')
                            ElevatedButton.icon(
                              onPressed: () {
                                _updatePermissionStatus(
                                  ref,
                                  record.id,
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
                                  ref,
                                  record.id,
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
    WidgetRef ref,
    String permissionId,
    String newStatus,
    bool archive,
  ) async {
    final ds = ref.read(permisosDatasourceProvider);
    if (archive) {
      await ds.updatePermiso(permissionId, {
        'estado': newStatus,
        'archivado': true,
      });
    } else {
      await ds.updatePermiso(permissionId, {'estado': newStatus});
    }
  }
}

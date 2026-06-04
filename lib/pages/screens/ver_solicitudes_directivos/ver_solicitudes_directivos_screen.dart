import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';
import 'package:permisouttec/providers/permisos_provider.dart';

class VerSolicitudesDirectivosPage extends ConsumerStatefulWidget {
  const VerSolicitudesDirectivosPage({super.key});

  @override
  ConsumerState<VerSolicitudesDirectivosPage> createState() =>
      _VerSolicitudesDirectivosPageState();
}

class _VerSolicitudesDirectivosPageState
    extends ConsumerState<VerSolicitudesDirectivosPage> {
  Future<void> _aprobarSolicitud(String userId) async {
    try {
      await ref.read(usuariosDatasourceProvider).updateUsuario(userId, {
        'solicitud_directivo': false,
        'aprobado_directivo': true,
        'puesto': 'Directivo',
      });
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Solicitud aprobada'),
            content: const Text(
              'Has aprobado la solicitud para ser directivo.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      debugPrint('Error al aprobar la solicitud: $error');
    }
  }

  Future<void> _rechazarSolicitud(String userId) async {
    try {
      await ref.read(usuariosDatasourceProvider).updateUsuario(userId, {
        'solicitud_directivo': false,
        'aprobado_directivo': false,
        'puesto': 'Profesor',
      });

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Solicitud rechazada'),
            content: const Text(
              'Has rechazado la solicitud para agregar un nuevo directivo.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      debugPrint('Error al rechazar la solicitud: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final solicitudesAsync = ref.watch(solicitudesDirectivoStreamProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: const Text('Solicitudes para ser Directivos'),
          ),
          centerTitle: false,
        ),
      ),
      body: solicitudesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Text('No hay solicitudes de directivos.'),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final RtdbRecord record = records[index];
              final String userId = record.id;
              final String email = record.string('email') ?? '';
              final String puesto = record.string('puesto') ?? '';
              final nombre = record.string('nombre')?.trim() ?? '';
              final apellido = record.string('apellido')?.trim() ?? '';
              final nombreCompleto = '$nombre $apellido'.trim();
              final telefono = record.string('telefono');
              return ListTile(
                title: Text(nombreCompleto.isNotEmpty ? nombreCompleto : email),
                subtitle: Text(
                  [
                    if (nombreCompleto.isNotEmpty) email,
                    'Puesto: $puesto',
                    if (telefono != null && telefono.isNotEmpty)
                      'Tel: $telefono',
                  ].join(' · '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _aprobarSolicitud(userId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _rechazarSolicitud(userId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

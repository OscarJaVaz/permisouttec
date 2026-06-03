import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/providers/navigation_params_provider.dart';
import 'package:permisouttec/providers/permisos_provider.dart';

class Profesores extends ConsumerWidget {
  const Profesores({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profesoresAsync = ref.watch(profesoresStreamProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: const Text('Profesores'),
          ),
          centerTitle: false,
        ),
      ),
      body: profesoresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar los datos')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('Sin registros'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(profesoresStreamProvider),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(record.string('nombre') ?? ''),
                  subtitle: Text(record.string('numero de empleado') ?? ''),
                  onTap: () {
                    ref.read(nuevoProfesorDocIdProvider.notifier).state =
                        record.id;
                    context.push(AppRoutes.nuevoProfesor);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Agregar profesor'),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(nuevoProfesorDocIdProvider.notifier).state =
                          null;
                      context.push(AppRoutes.nuevoProfesor);
                    },
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Opciones',
        child: const Icon(Icons.more_vert),
      ),
    );
  }
}

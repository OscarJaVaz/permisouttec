import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';
import 'package:permisouttec/providers/navigation_params_provider.dart';
import 'package:permisouttec/providers/permisos_provider.dart';

class Puestos extends ConsumerStatefulWidget {
  const Puestos({super.key});

  @override
  ConsumerState<Puestos> createState() => _PuestosState();
}

class _PuestosState extends ConsumerState<Puestos> {
  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(puestosDatasourceProvider).streamAll();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: const Text('Puestos'),
          ),
          centerTitle: false,
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
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return ListTile(
                        leading: const Icon(Icons.work),
                        title: Text(record.string('codigo') ?? ''),
                        subtitle: Text(record.string('nombre') ?? ''),
                        onTap: () {
                          ref.read(nuevoPuestoDocIdProvider.notifier).state =
                              record.id;
                          context.push(AppRoutes.nuevoPuesto);
                        },
                      );
                    },
                  ),
                ],
              ),
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
                    title: const Text('Agregar puesto'),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(nuevoPuestoDocIdProvider.notifier).state = null;
                      context.push(AppRoutes.nuevoPuesto);
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/providers/navigation_params_provider.dart';
import 'package:permisouttec/providers/permisos_provider.dart';

class Divisiones extends ConsumerWidget {
  const Divisiones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final divisionesAsync = ref.watch(divisionesStreamProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: const Text('Divisiones'),
          ),
        ),
      ),
      body: divisionesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar los datos')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('Sin registros'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(divisionesStreamProvider),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  leading: const Icon(Icons.business),
                  title: Text(record.string('codigo') ?? ''),
                  subtitle: Text(record.string('nombre') ?? ''),
                  onTap: () {
                    ref.read(nuevaDivisionDocIdProvider.notifier).state =
                        record.id;
                    context.push(AppRoutes.nuevaDivision);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(nuevaDivisionDocIdProvider.notifier).state = null;
          context.push(AppRoutes.nuevaDivision);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

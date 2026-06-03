import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/providers/navigation_params_provider.dart';

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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('puestos').snapshots(),
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
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot doc = docs[index];
                      return ListTile(
                        leading: const Icon(Icons.work),
                        title: Text(doc['codigo']),
                        subtitle: Text(doc['nombre']),
                        onTap: () {
                          ref.read(nuevoPuestoDocIdProvider.notifier).state =
                              doc.id;
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

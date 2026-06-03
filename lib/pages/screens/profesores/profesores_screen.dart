import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/providers/navigation_params_provider.dart';

class Profesores extends ConsumerStatefulWidget {
  const Profesores({super.key});

  @override
  ConsumerState<Profesores> createState() => _ProfesoresState();
}

class _ProfesoresState extends ConsumerState<Profesores> {
  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('profesores').snapshots(),
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
                        leading: const Icon(Icons.person),
                        title: Text(doc['nombre']),
                        subtitle: Text(doc['numero de empleado']),
                        onTap: () {
                          ref.read(nuevoProfesorDocIdProvider.notifier).state =
                              doc.id;
                          context.push(AppRoutes.nuevoProfesor);
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

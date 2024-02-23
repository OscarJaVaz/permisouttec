import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permisouttec/pages/NuevoPuesto.dart';

class Puestos extends StatefulWidget {
  const Puestos({Key? key});

  @override
  State<Puestos> createState() => _PuestosState();
}

class _PuestosState extends State<Puestos> {
  Future<void> _refreshData() async {
    // Puedes realizar aquí cualquier operación necesaria para actualizar los datos
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // Ajusta la altura del AppBar según tus necesidades
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0), // Ajusta el valor para mover el texto hacia abajo
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
            return const Center(child: Text("Sin registros"));
          }
          List<DocumentSnapshot> docs = snapshot.data!.docs;
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot doc = docs[index];
                      return ListTile(
                        leading: const Icon(Icons.work),
                        title: Text(doc["codigo"]),
                        subtitle: Text(doc["nombre"]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NuevoPuesto(idDoc: doc.id)),
                          );
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
              return Container(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Agregar puesto'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NuevoPuesto(idDoc: "")),
                        );
                      },
                    ),
                  ],
                ),
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

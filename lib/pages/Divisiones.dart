import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permisouttec/pages/NuevaDivision.dart';
import 'package:permisouttec/pages/login.dart';

class Divisiones extends StatelessWidget {
  const Divisiones({Key? key}) : super(key: key);

  // Método para cerrar sesión


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divisiones'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('divisiones').snapshots(),
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
            onRefresh: () async {}, // No estoy seguro de qué debería hacer la actualización aquí
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
                        leading: const Icon(Icons.business),
                        title: Text(doc["codigo"]),
                        subtitle: Text(doc["nombre"]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NuevaDivision(idDoc: doc.id)),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NuevaDivision(idDoc: '')),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

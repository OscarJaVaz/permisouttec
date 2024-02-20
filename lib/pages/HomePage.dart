import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permisouttec/pages/NuevaDivision.dart';
import 'package:permisouttec/pages/Profesores.dart';
import 'package:permisouttec/pages/Puestos.dart';
import 'package:permisouttec/pages/login.dart'; // Asegúrate de importar la página de inicio de sesión

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Método para actualizar los datos
  Future<void> _refreshData() async {
    // Puedes realizar aquí cualquier operación necesaria para actualizar los datos
    setState(() {});
  }

  // Método para cerrar sesión
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Redirigir a la pantalla de inicio de sesión y reemplazar la vista actual
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()), // Redirigir a la página de inicio de sesión
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divisiones'),
        actions: [
          IconButton(
            onPressed: _logout, // Llamar al método de cierre de sesión al hacer clic en el botón
            icon: Icon(Icons.logout),
          ),
        ],
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
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Agregar división'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NuevaDivision(idDoc: "")),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('Ver Puestos'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Puestos()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('Ver Profesores'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Profesores()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout), // Agregar un ícono de cierre de sesión
                      title: const Text('Cerrar sesión'),
                      onTap: _logout, // Llamar al método de cierre de sesión al hacer clic en el ítem
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

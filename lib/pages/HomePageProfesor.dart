import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permisouttec/pages/NuevoPermiso.dart';
import 'package:permisouttec/pages/login.dart';

class HomePageProfesor extends StatefulWidget {
  @override
  _HomePageProfesorState createState() => _HomePageProfesorState();
}

class _HomePageProfesorState extends State<HomePageProfesor> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio - Profesor'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('permisos')
            .where('usuarioId', isEqualTo: _currentUser.uid) // Filtro por usuario actual
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Sin registros'));
          }
          List<DocumentSnapshot> docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot doc = docs[index];
              final String estado = doc['estado'];
              final String tipo = doc['tipo'];

              // Verificar si el campo 'archivado' existe en el documento
              final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

              // Si el campo 'archivado' existe y es verdadero, se archiva el permiso
              final bool archivado = data != null && data.containsKey('archivado') ? data['archivado'] : false;

              // Mostrar solo los permisos que no están archivados
              if (!archivado) {
                return ListTile(
                  title: Text('Tipo: $tipo'), // Mostrar el tipo como motivo de la inasistencia
                  subtitle: Text('Estado: $estado'),
                );
              } else {
                return SizedBox.shrink(); // Ocultar permisos archivados
              }
            },
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
                      title: const Text('Solicitar Permiso'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NuevoPermiso()),
                        ).then((_) {
                          // Actualizar la lista de permisos después de que se solicite uno nuevo
                          setState(() {});
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Cerrar sesión'),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                              (route) => false, // Remove all routes from the stack
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
        child: Icon(Icons.more_vert),
      ),
    );
  }
}

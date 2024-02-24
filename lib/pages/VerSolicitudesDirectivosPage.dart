import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerSolicitudesDirectivosPage extends StatefulWidget {
  const VerSolicitudesDirectivosPage({Key? key}) : super(key: key);

  @override
  State<VerSolicitudesDirectivosPage> createState() =>
      _VerSolicitudesDirectivosPageState();
}

class _VerSolicitudesDirectivosPageState
    extends State<VerSolicitudesDirectivosPage> {
  Future<void> _aprobarSolicitud(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({'solicitud_directivo': false, 'directivo': true});
      // Mostrar una alerta de aprobación
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Solicitud aprobada'),
            content: Text('Has aprobado la solicitud para ser directivo.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error al aprobar la solicitud: $error');
    }
  }

  Future<void> _rechazarSolicitud(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({
        'solicitud_directivo': false,
        'puesto': 'Profesor' // Actualizar el puesto a "Profesor" al rechazar la solicitud
      });

      // Mostrar una alerta de rechazo
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Solicitud rechazada'),
            content: Text('Has rechazado la solicitud para agregar un nuevo directivo.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error al rechazar la solicitud: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: const Text('Solicitudes para ser Directivos'),
          ),
          centerTitle: false,
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .where('solicitud_directivo', isEqualTo: true)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No hay solicitudes de directivos.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;
              String userId = document.id;
              String email = data['email'] ?? '';
              String puesto = data['puesto'] ?? '';
              return ListTile(
                title: Text(email),
                subtitle: Text('Puesto: $puesto'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        _aprobarSolicitud(userId);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        _rechazarSolicitud(userId);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

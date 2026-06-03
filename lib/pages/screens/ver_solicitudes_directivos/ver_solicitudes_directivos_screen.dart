import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerSolicitudesDirectivosPage extends StatefulWidget {
  const VerSolicitudesDirectivosPage({super.key});

  @override
  State<VerSolicitudesDirectivosPage> createState() =>
      _VerSolicitudesDirectivosPageState();
}

class _VerSolicitudesDirectivosPageState
    extends State<VerSolicitudesDirectivosPage> {
  Future<void> _aprobarSolicitud(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(userId).update(
        {'solicitud_directivo': false, 'directivo': true},
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Solicitud aprobada'),
            content: const Text(
              'Has aprobado la solicitud para ser directivo.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      debugPrint('Error al aprobar la solicitud: $error');
    }
  }

  Future<void> _rechazarSolicitud(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(userId).update(
        {
          'solicitud_directivo': false,
          'puesto': 'Profesor',
        },
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Solicitud rechazada'),
            content: const Text(
              'Has rechazado la solicitud para agregar un nuevo directivo.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      debugPrint('Error al rechazar la solicitud: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay solicitudes de directivos.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              final Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final String userId = document.id;
              final String email = data['email'] ?? '';
              final String puesto = data['puesto'] ?? '';
              return ListTile(
                title: Text(email),
                subtitle: Text('Puesto: $puesto'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _aprobarSolicitud(userId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _rechazarSolicitud(userId),
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

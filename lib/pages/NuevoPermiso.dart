import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NuevoPermiso extends StatefulWidget {
  @override
  _NuevoPermisoState createState() => _NuevoPermisoState();
}

class _NuevoPermisoState extends State<NuevoPermiso> {
  final _tipoPermisoController = TextEditingController();

  Future<void> _solicitarPermiso() async {
    try {
      // Verificar si el usuario actual es un profesor
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userInfo = await FirebaseFirestore.instance.collection('usuarios').doc(userId).get();
      String? rol = userInfo['puesto'];

      if (rol == 'Profesor') {
        // Obtener el número de permisos de ausencia ya solicitados por el profesor
        QuerySnapshot permisos = await FirebaseFirestore.instance.collection('permisos')
            .where('usuarioId', isEqualTo: userId)
            .where('tipo', isEqualTo: 'ausencia')
            .where('estado', isEqualTo: 'aprobado')
            .get();

        // Verificar si el profesor ha excedido el límite de 7 permisos de ausencia
        if (permisos.docs.length < 7) {
          // Agregar la solicitud de permiso de ausencia a la colección correspondiente
          await FirebaseFirestore.instance.collection('permisos').add({
            'usuarioId': userId,
            'tipo': _tipoPermisoController.text, // Utilizar el valor del TextField
            'estado': 'pendiente',
          });

          // Mostrar un mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Solicitud de permiso de ausencia enviada correctamente'),
            duration: Duration(seconds: 2),
          ));

          // Regresar a la página de inicio del profesor
          Navigator.pop(context);
        } else {
          // Mostrar un mensaje de error si se ha excedido el límite de permisos de ausencia
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Has alcanzado el límite de 7 permisos de ausencia'),
            duration: Duration(seconds: 2),
          ));
        }
      } else {
        // Si el usuario no es un profesor, mostrar un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No tienes permiso para solicitar este tipo de permiso'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      print('Error al solicitar permiso de ausencia: $e');
      // Manejar errores de solicitud de permiso aquí
    }
  }

  @override
  void initState() {
    super.initState();
    // Aquí puedes inicializar el valor del controlador _tipoPermisoController con el valor actual de 'tipo' de Firebase
    _initializeTipoPermiso();
  }

  Future<void> _initializeTipoPermiso() async {
    try {
      // Obtener el valor actual de 'tipo' de Firebase y establecerlo en el controlador
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userInfo = await FirebaseFirestore.instance.collection('usuarios').doc(userId).get();
      String? tipoPermiso = userInfo['tipo'];
      if (tipoPermiso != null) {
        setState(() {
          _tipoPermisoController.text = tipoPermiso;
        });
      }
    } catch (e) {
      print('Error al inicializar el valor del tipo de permiso: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Permiso de Ausencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tipoPermisoController,
              decoration: InputDecoration(labelText: 'Motivo de la Ausencia'),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _solicitarPermiso,
              child: Text('Solicitar Permiso de Ausencia'),
            ),
          ],
        ),
      ),
    );
  }
}

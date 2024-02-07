import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NuevaDivision extends StatefulWidget {
  final String idDoc;
  const NuevaDivision({Key? key, required this.idDoc}) : super(key: key);

  @override
  State<NuevaDivision> createState() => _NuevaDivisionState();
}

final TextEditingController _codigoController = TextEditingController();
final TextEditingController _nombreController = TextEditingController();

class _NuevaDivisionState extends State<NuevaDivision> {
  Future<void> _guardarDatos() async {
    try {
      if (widget.idDoc.isNotEmpty) {
        await FirebaseFirestore.instance.collection('divisiones').doc(widget.idDoc).update({
          'codigo': _codigoController.text,
          'nombre': _nombreController.text,
        });
      } else {
        await FirebaseFirestore.instance.collection('divisiones').add({
          'codigo': _codigoController.text,
          'nombre': _nombreController.text,
        });
      }
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los datos')),
      );
    }
  }

  Future<void> _eliminarDatos() async {
    try {
      await FirebaseFirestore.instance.collection('divisiones').doc(widget.idDoc).delete();
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar los datos')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.idDoc.isNotEmpty) {
      FirebaseFirestore.instance.collection('divisiones').doc(widget.idDoc).get().then((value) {
        _codigoController.text = value["codigo"];
        _nombreController.text = value["nombre"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Nueva División"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codigoController,
              decoration: const InputDecoration(labelText: 'Código'),
            ),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _guardarDatos,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Cambia el color del botón a azul
                  ),
                  child: const Text('Guardar'),
                ),
                const SizedBox(width: 20), // Agrega un espacio entre los botones
                Visibility(
                  visible: widget.idDoc.isNotEmpty,
                  child: ElevatedButton(
                    onPressed: _eliminarDatos,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Cambia el color del botón a rojo
                    ),
                    child: const Text('Eliminar'),
                  ),
                ),

              ],
            ),


          ],
        ),
      ),
    );
  }
}

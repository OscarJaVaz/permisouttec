import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NuevoPuesto extends StatefulWidget {
  final String idDoc;
  const NuevoPuesto({Key? key, required this.idDoc}) : super(key: key);

  @override
  State<NuevoPuesto> createState() => _NuevoPuestoState();
}

final TextEditingController _codigoController = TextEditingController();
final TextEditingController _nombreController = TextEditingController();

class _NuevoPuestoState extends State<NuevoPuesto> {
  String _appBarTitle = 'Nuevo Puesto'; // Variable para el título del AppBar

  Future<void> _guardarDatos() async {
    try {
      if (widget.idDoc.isNotEmpty) {
        await FirebaseFirestore.instance.collection('puestos').doc(widget.idDoc).update({
          'codigo': _codigoController.text,
          'nombre': _nombreController.text,
        });
      } else {
        await FirebaseFirestore.instance.collection('puestos').add({
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
      await FirebaseFirestore.instance.collection('puestos').doc(widget.idDoc).delete();
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
    _codigoController.text = ''; // Limpiar el campo de código
    _nombreController.text = ''; // Limpiar el campo de nombre
    if (widget.idDoc.isNotEmpty) {
      FirebaseFirestore.instance.collection('puestos').doc(widget.idDoc).get().then((value) {
        _codigoController.text = value["codigo"];
        _nombreController.text = value["nombre"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Ajusta la altura del AppBar según tus necesidades
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0), // Ajusta el valor para mover el texto hacia abajo
            child: Text(_appBarTitle), // Usar la variable _appBarTitle para el texto del AppBar
          ),
        ),
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
              decoration: const InputDecoration(labelText: 'Nombre del puesto'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(width: 20), // Agrega un espacio entre los botones
                ElevatedButton(
                  onPressed: _guardarDatos,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Cambia el color del botón a azul
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

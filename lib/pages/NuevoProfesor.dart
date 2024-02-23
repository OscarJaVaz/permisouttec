import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NuevoProfesor extends StatefulWidget {
  final String idDoc;
  const NuevoProfesor({Key? key, required this.idDoc}) : super(key: key);

  @override
  State<NuevoProfesor> createState() => _NuevoProfesorState();
}

class _NuevoProfesorState extends State<NuevoProfesor> {
  late TextEditingController _numeroController;
  late TextEditingController _nombreController;
  late TextEditingController _horasController;
  late TextEditingController _diasController;
  late TextEditingController _divisionController;
  late TextEditingController _puestoController;

  String? valorExistenteDelCampoDivision;
  String? valorExistenteDelCampoPuesto;
  bool _seleccionValida = false;

  @override
  void initState() {
    super.initState();
    _numeroController = TextEditingController();
    _nombreController = TextEditingController();
    _horasController = TextEditingController();
    _diasController = TextEditingController();
    _divisionController = TextEditingController();
    _puestoController = TextEditingController();

    _numeroController.text = '';
    _nombreController.text = '';
    _horasController.text = '';
    _diasController.text = '';
    _divisionController.text = ''; // Establecer en blanco al principio
    _puestoController.text = '';

    if (widget.idDoc.isNotEmpty) {
      FirebaseFirestore.instance.collection('profesores').doc(widget.idDoc).get().then((value) {
        setState(() {
          _numeroController.text = value["numero de empleado"];
          _nombreController.text = value["nombre"];
          _horasController.text = value["horas por semana"];
          _diasController.text = value["dias de descanso permitidos"];
          valorExistenteDelCampoDivision = value["division"];

          // Si el valor existente no está en la lista, establecer en blanco
          if (!Division.contains(valorExistenteDelCampoDivision)) {
            _divisionController.text = '';
          } else {
            _divisionController.text = valorExistenteDelCampoDivision!;
          }

          _puestoController.text = value["puesto"];
          _seleccionValida = true;
        });
      });
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      cargarDivisiones();
      cargarPuestos(); // Llamar al método para cargar puestos
    });
  }

  Future<void> _guardarDatos() async {
    try {
      if (widget.idDoc.isNotEmpty) {
        await FirebaseFirestore.instance.collection('profesores').doc(widget.idDoc).update({
          'numero de empleado': _numeroController.text,
          'nombre': _nombreController.text,
          'horas por semana': _horasController.text,
          'dias de descanso permitidos': _diasController.text,
          'division': _divisionController.text,
          'puesto': _puestoController.text,
        });
      } else {
        await FirebaseFirestore.instance.collection('profesores').add({
          'numero de empleado': _numeroController.text,
          'nombre': _nombreController.text,
          'horas por semana': _horasController.text,
          'dias de descanso permitidos': _diasController.text,
          'division': _divisionController.text,
          'puesto': _puestoController.text,
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
      await FirebaseFirestore.instance.collection('profesores').doc(widget.idDoc).delete();
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar los datos')),
      );
    }
  }

  List<String> Division = [];

  Future<void> cargarDivisiones() async {
    final QuerySnapshot divisionesSnapshot = await FirebaseFirestore.instance.collection('divisiones').get();

    setState(() {
      Division = divisionesSnapshot.docs
          .map((doc) => doc['nombre'] as String?) // Obtener nombres, permitiendo nulos
          .where((nombre) => nombre != null) // Filtrar valores nulos
          .cast<String>() // Convertir a String
          .toList();
    });
  }

  List<String> Puestos = [];

  Future<void> cargarPuestos() async {
    final QuerySnapshot puestosSnapshot = await FirebaseFirestore.instance.collection('puestos').get();

    setState(() {
      Puestos = puestosSnapshot.docs
          .map((doc) => doc['nombre'] as String?) // Obtener nombres, permitiendo nulos
          .where((nombre) => nombre != null) // Filtrar valores nulos
          .cast<String>() // Convertir a String
          .toList();
    });
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
            child: const Text("Nuevo Profesor"),
          ),
        ),
      ),
      body: SingleChildScrollView( // Envuelve todo el contenido en un SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _numeroController,
                decoration: const InputDecoration(labelText: 'Numero de empleado'),
              ),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _horasController,
                decoration: const InputDecoration(labelText: 'Horas por semana'),
              ),
              TextField(
                controller: _diasController,
                decoration: const InputDecoration(labelText: 'Dias de descanso permitidos por cuatrimestre'),
              ),

              //DIVISION
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 32, // Ajustar el ancho del contenedor
                  child: DropdownButtonFormField<String>(
                    value: _divisionController.text.isNotEmpty ? _divisionController.text : valorExistenteDelCampoDivision,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('Selecciona una opción'),
                      ),
                      ...Division.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.length > 40 ? '${value.substring(0, 40)}...' : value, // Limitar la longitud del texto
                          ),
                        );
                      }),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _divisionController.text = newValue!;
                        _seleccionValida = newValue != null && newValue != 'Selecciona una opción'; // Actualizar la validez de la selección
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Division',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              // Puestos

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: DropdownButtonFormField<String>(
                  value: _puestoController.text.isNotEmpty ? _puestoController.text : valorExistenteDelCampoPuesto,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Selecciona una opción'),
                    ),
                    ...Puestos.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _puestoController.text = newValue!;
                      _seleccionValida = newValue != null && newValue != 'Selecciona una opción'; // Actualizar la validez de la selección
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Puesto', // Cambié 'Division' a 'Puesto'
                    border: OutlineInputBorder(),
                  ),
                ),
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
                    onPressed: _seleccionValida ? _guardarDatos : null,
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
      ),
    );
  }
}

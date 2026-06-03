import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/providers/navigation_params_provider.dart';
import 'package:permisouttec/widgets/dismiss_keyboard.dart';
import 'package:permisouttec/widgets/form_text_field.dart';

class NuevoProfesor extends ConsumerStatefulWidget {
  const NuevoProfesor({super.key});

  @override
  ConsumerState<NuevoProfesor> createState() => _NuevoProfesorState();
}

class _NuevoProfesorState extends ConsumerState<NuevoProfesor> {
  late final String _idDoc;
  late TextEditingController _numeroController;
  late TextEditingController _nombreController;
  late TextEditingController _horasController;
  late TextEditingController _diasController;
  late TextEditingController _divisionController;
  late TextEditingController _puestoController;

  String? valorExistenteDelCampoDivision;
  String? valorExistenteDelCampoPuesto;
  bool _seleccionValida = false;
  final FocusNode _numeroFocusNode = FocusNode();
  final FocusNode _nombreFocusNode = FocusNode();
  final FocusNode _horasFocusNode = FocusNode();
  final FocusNode _diasFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _idDoc = ref.read(nuevoProfesorDocIdProvider) ?? '';
    _numeroController = TextEditingController();
    _nombreController = TextEditingController();
    _horasController = TextEditingController();
    _diasController = TextEditingController();
    _divisionController = TextEditingController();
    _puestoController = TextEditingController();

    if (_idDoc.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('profesores')
          .doc(_idDoc)
          .get()
          .then((value) {
        setState(() {
          _numeroController.text = value['numero de empleado'];
          _nombreController.text = value['nombre'];
          _horasController.text = value['horas por semana'];
          _diasController.text = value['dias de descanso permitidos'];
          valorExistenteDelCampoDivision = value['division'];
          if (!division.contains(valorExistenteDelCampoDivision)) {
            _divisionController.text = '';
          } else {
            _divisionController.text = valorExistenteDelCampoDivision!;
          }
          _puestoController.text = value['puesto'];
          _seleccionValida = true;
        });
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cargarDivisiones();
      cargarPuestos();
    });
  }

  Future<void> _guardarDatos() async {
    try {
      if (_idDoc.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('profesores')
            .doc(_idDoc)
            .update({
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
      if (mounted) {
        ref.read(nuevoProfesorDocIdProvider.notifier).state = null;
        context.pop();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los datos')),
      );
    }
  }

  Future<void> _eliminarDatos() async {
    try {
      await FirebaseFirestore.instance
          .collection('profesores')
          .doc(_idDoc)
          .delete();
      if (mounted) {
        ref.read(nuevoProfesorDocIdProvider.notifier).state = null;
        context.pop();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar los datos')),
      );
    }
  }

  List<String> division = [];

  Future<void> cargarDivisiones() async {
    final divisionesSnapshot =
        await FirebaseFirestore.instance.collection('divisiones').get();

    setState(() {
      division = divisionesSnapshot.docs
          .map((doc) => doc['nombre'] as String?)
          .where((nombre) => nombre != null)
          .cast<String>()
          .toList();
    });
  }

  List<String> puestos = [];

  Future<void> cargarPuestos() async {
    final puestosSnapshot =
        await FirebaseFirestore.instance.collection('puestos').get();

    setState(() {
      puestos = puestosSnapshot.docs
          .map((doc) => doc['nombre'] as String?)
          .where((nombre) => nombre != null)
          .cast<String>()
          .toList();
    });
  }

  @override
  void dispose() {
    _numeroFocusNode.dispose();
    _nombreFocusNode.dispose();
    _horasFocusNode.dispose();
    _diasFocusNode.dispose();
    ref.read(nuevoProfesorDocIdProvider.notifier).state = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: const Text('Nuevo Profesor'),
          ),
        ),
      ),
      body: DismissKeyboard(
        child: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FocusTraversalGroup(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormTextField(
                controller: _numeroController,
                focusNode: _numeroFocusNode,
                labelText: 'Numero de empleado',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    submitFormField(context, nextFocus: _nombreFocusNode),
              ),
              FormTextField(
                controller: _nombreController,
                focusNode: _nombreFocusNode,
                labelText: 'Nombre',
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    submitFormField(context, nextFocus: _horasFocusNode),
              ),
              FormTextField(
                controller: _horasController,
                focusNode: _horasFocusNode,
                labelText: 'Horas por semana',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    submitFormField(context, nextFocus: _diasFocusNode),
              ),
              FormTextField(
                controller: _diasController,
                focusNode: _diasFocusNode,
                labelText: 'Dias de descanso permitidos por cuatrimestre',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => submitFormField(context),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 32,
                  child: DropdownButtonFormField<String>(
                    initialValue: _divisionController.text.isNotEmpty
                        ? _divisionController.text
                        : valorExistenteDelCampoDivision,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Selecciona una opción'),
                      ),
                      ...division.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.length > 40
                                ? '${value.substring(0, 40)}...'
                                : value,
                          ),
                        );
                      }),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _divisionController.text = newValue!;
                        _seleccionValida = newValue != 'Selecciona una opción';
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Division',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: DropdownButtonFormField<String>(
                  initialValue: _puestoController.text.isNotEmpty
                      ? _puestoController.text
                      : valorExistenteDelCampoPuesto,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Selecciona una opción'),
                    ),
                    ...puestos.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _puestoController.text = newValue!;
                      _seleccionValida = newValue != 'Selecciona una opción';
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Puesto',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _idDoc.isNotEmpty,
                    child: ElevatedButton(
                      onPressed: _eliminarDatos,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _seleccionValida ? _guardarDatos : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
        ),
      ),
    );
  }
}

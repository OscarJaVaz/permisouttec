import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/providers/navigation_params_provider.dart';
import 'package:permisouttec/providers/permisos_provider.dart';
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
      ref.read(profesoresDatasourceProvider).getById(_idDoc).then((value) {
        if (value == null || !mounted) return;
        setState(() {
          _numeroController.text = value['numero de empleado']?.toString() ?? '';
          _nombreController.text = value['nombre']?.toString() ?? '';
          _horasController.text = value['horas por semana']?.toString() ?? '';
          _diasController.text =
              value['dias de descanso permitidos']?.toString() ?? '';
          valorExistenteDelCampoDivision = value['division']?.toString();
          if (!division.contains(valorExistenteDelCampoDivision)) {
            _divisionController.text = '';
          } else {
            _divisionController.text = valorExistenteDelCampoDivision!;
          }
          _puestoController.text = value['puesto']?.toString() ?? '';
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
      final ds = ref.read(profesoresDatasourceProvider);
      final data = {
        'numero de empleado': _numeroController.text,
        'nombre': _nombreController.text,
        'horas por semana': _horasController.text,
        'dias de descanso permitidos': _diasController.text,
        'division': _divisionController.text,
        'puesto': _puestoController.text,
      };
      if (_idDoc.isNotEmpty) {
        await ds.update(_idDoc, data);
      } else {
        await ds.create(data);
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
      await ref.read(profesoresDatasourceProvider).delete(_idDoc);
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
    final nombres = await ref.read(divisionesDatasourceProvider).listNombres();

    setState(() {
      division = nombres;
    });
  }

  List<String> puestos = [];

  Future<void> cargarPuestos() async {
    final nombres = await ref.read(puestosDatasourceProvider).listNombres();

    setState(() {
      puestos = nombres;
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

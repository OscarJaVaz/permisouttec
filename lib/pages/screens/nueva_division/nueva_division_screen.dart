import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/providers/navigation_params_provider.dart';
import 'package:permisouttec/widgets/dismiss_keyboard.dart';

final TextEditingController _codigoDivisionController = TextEditingController();
final TextEditingController _nombreDivisionController = TextEditingController();

class NuevaDivision extends ConsumerStatefulWidget {
  const NuevaDivision({super.key});

  @override
  ConsumerState<NuevaDivision> createState() => _NuevaDivisionState();
}

class _NuevaDivisionState extends ConsumerState<NuevaDivision> {
  late final String _idDoc;
  Future<void> _guardarDatos() async {
    try {
      if (_idDoc.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('divisiones')
            .doc(_idDoc)
            .update({
          'codigo': _codigoDivisionController.text,
          'nombre': _nombreDivisionController.text,
        });
      } else {
        await FirebaseFirestore.instance.collection('divisiones').add({
          'codigo': _codigoDivisionController.text,
          'nombre': _nombreDivisionController.text,
        });
      }
      if (mounted) {
        ref.read(nuevaDivisionDocIdProvider.notifier).state = null;
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
          .collection('divisiones')
          .doc(_idDoc)
          .delete();
      if (mounted) {
        ref.read(nuevaDivisionDocIdProvider.notifier).state = null;
        context.pop();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar los datos')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _idDoc = ref.read(nuevaDivisionDocIdProvider) ?? '';
    _codigoDivisionController.text = '';
    _nombreDivisionController.text = '';
    if (_idDoc.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('divisiones')
          .doc(_idDoc)
          .get()
          .then((value) {
        _codigoDivisionController.text = value['codigo'];
        _nombreDivisionController.text = value['nombre'];
      });
    }
  }

  @override
  void dispose() {
    ref.read(nuevaDivisionDocIdProvider.notifier).state = null;
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
            child: const Text('Nueva División'),
          ),
        ),
      ),
      body: DismissKeyboard(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codigoDivisionController,
              decoration: const InputDecoration(labelText: 'Código'),
            ),
            TextField(
              controller: _nombreDivisionController,
              decoration: const InputDecoration(labelText: 'Nombre'),
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
                  onPressed: _guardarDatos,
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
    );
  }
}

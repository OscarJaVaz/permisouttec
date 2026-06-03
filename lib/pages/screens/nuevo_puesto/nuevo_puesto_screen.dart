import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/providers/navigation_params_provider.dart';

final TextEditingController _codigoController = TextEditingController();
final TextEditingController _nombreController = TextEditingController();

class NuevoPuesto extends ConsumerStatefulWidget {
  const NuevoPuesto({super.key});

  @override
  ConsumerState<NuevoPuesto> createState() => _NuevoPuestoState();
}

class _NuevoPuestoState extends ConsumerState<NuevoPuesto> {
  late final String _idDoc;
  final String _appBarTitle = 'Nuevo Puesto';

  Future<void> _guardarDatos() async {
    try {
      if (_idDoc.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('puestos')
            .doc(_idDoc)
            .update({
          'codigo': _codigoController.text,
          'nombre': _nombreController.text,
        });
      } else {
        await FirebaseFirestore.instance.collection('puestos').add({
          'codigo': _codigoController.text,
          'nombre': _nombreController.text,
        });
      }
      if (mounted) {
        ref.read(nuevoPuestoDocIdProvider.notifier).state = null;
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
          .collection('puestos')
          .doc(_idDoc)
          .delete();
      if (mounted) {
        ref.read(nuevoPuestoDocIdProvider.notifier).state = null;
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
    _idDoc = ref.read(nuevoPuestoDocIdProvider) ?? '';
    _codigoController.text = '';
    _nombreController.text = '';
    if (_idDoc.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('puestos')
          .doc(_idDoc)
          .get()
          .then((value) {
        _codigoController.text = value['codigo'];
        _nombreController.text = value['nombre'];
      });
    }
  }

  @override
  void dispose() {
    ref.read(nuevoPuestoDocIdProvider.notifier).state = null;
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
            child: Text(_appBarTitle),
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
    );
  }
}

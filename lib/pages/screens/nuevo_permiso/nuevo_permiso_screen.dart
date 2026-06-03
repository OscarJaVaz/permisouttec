import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/providers/permisos_provider.dart';

class NuevoPermiso extends ConsumerStatefulWidget {
  const NuevoPermiso({super.key});

  @override
  ConsumerState<NuevoPermiso> createState() => _NuevoPermisoState();
}

class _NuevoPermisoState extends ConsumerState<NuevoPermiso> {
  final _tipoPermisoController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _solicitarPermiso() async {
    try {
      final permisosDs = ref.read(permisosDatasourceProvider);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userInfo = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();
      final String? rol = userInfo['puesto'];

      if (rol == 'Profesor') {
        final permisos = await permisosDs.countAusenciasAprobadas(userId);

        if (permisos.docs.length < 7) {
          await permisosDs.addPermiso({
            'usuarioId': userId,
            'tipo': _tipoPermisoController.text,
            'fecha': _selectedDate,
            'estado': 'pendiente',
            'contador': 1,
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Solicitud de permiso de ausencia enviada correctamente',
              ),
              duration: Duration(seconds: 2),
            ),
          );
          context.pop();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Has alcanzado el límite de 7 permisos de ausencia'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tienes permiso para solicitar este tipo de permiso'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al solicitar permiso de ausencia: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Permiso de Ausencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tipoPermisoController,
              decoration: const InputDecoration(
                labelText: 'Motivo de la Ausencia',
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha del Permiso',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Seleccionar fecha',
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _solicitarPermiso,
              child: const Text('Solicitar Permiso de Ausencia'),
            ),
          ],
        ),
      ),
    );
  }
}

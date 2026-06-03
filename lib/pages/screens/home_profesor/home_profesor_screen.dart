import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/providers/auth_provider.dart';
import 'package:permisouttec/providers/permisos_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePageProfesor extends ConsumerStatefulWidget {
  const HomePageProfesor({super.key});

  @override
  ConsumerState<HomePageProfesor> createState() => _HomePageProfesorState();
}

class _HomePageProfesorState extends ConsumerState<HomePageProfesor> {
  late User _currentUser;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _selectedDay = DateTime.now();
  }

  Future<void> _showAbsenceDetails(DateTime selectedDay) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('permisos')
        .where('usuarioId', isEqualTo: _currentUser.uid)
        .where('fecha', isEqualTo: selectedDay)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return;
    }

    final doc = querySnapshot.docs[0];
    final String tipo = doc['tipo'];
    final String estado = doc['estado'];

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles de la Ausencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Fecha: ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
              ),
              const SizedBox(height: 10),
              Text('Tipo: $tipo'),
              const SizedBox(height: 10),
              Text('Estado: $estado'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final permisosDs = ref.watch(permisosDatasourceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Profesor'),
      ),
      body: StreamBuilder(
        stream: permisosDs.streamByUsuario(_currentUser.uid),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Sin registros'));
          }

          return Column(
            children: [
              TableCalendar(
                focusedDay: _selectedDay,
                firstDay: DateTime.utc(2010, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                  _showAbsenceDetails(selectedDay);
                },
                eventLoader: (day) {
                  final selectedEvents = <Color>[];
                  for (final doc in snapshot.data!.docs) {
                    final Timestamp fechaTimestamp = doc['fecha'];
                    final DateTime fecha = fechaTimestamp.toDate();
                    if (fecha.day == day.day &&
                        fecha.month == day.month &&
                        fecha.year == day.year) {
                      final String estado = doc['estado'];
                      if (estado == 'pendiente') {
                        selectedEvents.add(Colors.orange);
                      } else if (estado == 'aprobado') {
                        selectedEvents.add(Colors.green);
                      } else if (estado == 'rechazado') {
                        selectedEvents.add(Colors.red);
                      }
                    }
                  }
                  return selectedEvents;
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot doc = snapshot.data!.docs[index];
                    final String estado = doc['estado'];
                    final String tipo = doc['tipo'];
                    final Timestamp fechaTimestamp = doc['fecha'];
                    final DateTime fecha = fechaTimestamp.toDate();
                    final Map<String, dynamic>? data =
                        doc.data() as Map<String, dynamic>?;
                    final bool archivado = data != null &&
                        data.containsKey('archivado')
                        ? data['archivado']
                        : false;

                    if (!archivado &&
                        fecha.day == _selectedDay.day &&
                        fecha.month == _selectedDay.month &&
                        fecha.year == _selectedDay.year) {
                      return ListTile(
                        title: Text('Tipo: $tipo'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estado: $estado'),
                            Text(
                              'Fecha: ${fecha.day}/${fecha.month}/${fecha.year}',
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () async {
                await context.push(AppRoutes.nuevoPermiso);
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.add_circle),
              color: Colors.blue,
              tooltip: 'Solicitar Permiso',
            ),
            IconButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (!context.mounted) return;
                context.go(AppRoutes.login);
              },
              icon: const Icon(Icons.logout),
              color: Colors.red,
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
      ),
    );
  }
}

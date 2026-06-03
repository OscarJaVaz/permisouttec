import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_date_helper.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';
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
    final records = await ref
        .read(permisosDatasourceProvider)
        .findByUsuarioAndFecha(_currentUser.uid, selectedDay);

    if (records.isEmpty) {
      return;
    }

    final record = records.first;
    final String tipo = record.string('tipo') ?? '';
    final String estado = record.string('estado') ?? '';

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
    final stream =
        ref.watch(permisosDatasourceProvider).streamByUsuario(_currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Profesor'),
      ),
      body: StreamBuilder<List<RtdbRecord>>(
        stream: stream,
        builder: (context, AsyncSnapshot<List<RtdbRecord>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
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
                  for (final record in records) {
                    if (RtdbDateHelper.isSameDay(record.data['fecha'], day)) {
                      final String estado = record.string('estado') ?? '';
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
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final String estado = record.string('estado') ?? '';
                    final String tipo = record.string('tipo') ?? '';
                    final fecha = RtdbDateHelper.fromValue(record.data['fecha']);
                    final bool archivado = record.boolValue('archivado');

                    if (fecha != null &&
                        !archivado &&
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

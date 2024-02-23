import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:permisouttec/pages/NuevoPermiso.dart';
import 'package:permisouttec/pages/login.dart';

class HomePageProfesor extends StatefulWidget {
  @override
  _HomePageProfesorState createState() => _HomePageProfesorState();
}

class _HomePageProfesorState extends State<HomePageProfesor> {
  late User _currentUser;
  late DateTime _selectedDay; // Variable para almacenar el día seleccionado

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _selectedDay = DateTime.now(); // Inicializar _selectedDay con la fecha actual
  }

  Future<void> _showAbsenceDetails(DateTime selectedDay) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Ausencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Fecha: ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'),
              SizedBox(height: 10),
              Text('Tipo: $tipo'),
              SizedBox(height: 10),
              Text('Estado: $estado'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio - Profesor'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('permisos')
            .where('usuarioId', isEqualTo: _currentUser.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Sin registros'));
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
                  _showAbsenceDetails(selectedDay); // Mostrar detalles de la ausencia al hacer clic en el día
                },
                eventLoader: (day) {
                  final selectedEvents = <Color>[];
                  // Cargar eventos para el día seleccionado
                  for (final doc in snapshot.data!.docs) {
                    final Timestamp fechaTimestamp = doc['fecha'];
                    final DateTime fecha = fechaTimestamp.toDate();
                    if (fecha.day == day.day && fecha.month == day.month && fecha.year == day.year) {
                      final String estado = doc['estado'];
                      // Establecer el color del evento según el estado del permiso
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

                    // Verificar si el campo 'archivado' existe en el documento
                    final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

                    // Si el campo 'archivado' existe y es verdadero, se archiva el permiso
                    final bool archivado = data != null && data.containsKey('archivado') ? data['archivado'] : false;

                    // Mostrar solo los permisos que no están archivados y que coinciden con el día seleccionado
                    if (!archivado && fecha.day == _selectedDay.day && fecha.month == _selectedDay.month && fecha.year == _selectedDay.year) {
                      return ListTile(
                        title: Text('Tipo: $tipo'), // Mostrar el tipo como motivo de la inasistencia
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estado: $estado'),
                            Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}'), // Mostrar la fecha
                          ],
                        ),
                      );
                    } else {
                      return SizedBox.shrink(); // Ocultar permisos archivados o que no coinciden con el día seleccionado
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Solicitar Permiso'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NuevoPermiso()),
                        ).then((_) {
                          // Actualizar la lista de permisos después de que se solicite uno nuevo
                          setState(() {});
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Cerrar sesión'),
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        tooltip: 'Opciones',
        child: Icon(Icons.more_vert),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SelectedDayModel extends ChangeNotifier {
  late DateTime _selectedDay;

  SelectedDayModel() {
    _selectedDay = DateTime.now(); // Inicializar con la fecha actual al crear una instancia del modelo
  }

  DateTime get selectedDay => _selectedDay;

  void updateSelectedDay(DateTime newSelectedDay) {
    _selectedDay = newSelectedDay;
    notifyListeners(); // Notificar a los widgets que dependen de este modelo que ha habido un cambio
  }
}

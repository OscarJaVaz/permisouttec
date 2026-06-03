import 'package:flutter/material.dart';

class SelectedDayModel extends ChangeNotifier {
  late DateTime _selectedDay;

  SelectedDayModel() {
    _selectedDay = DateTime.now();
  }

  DateTime get selectedDay => _selectedDay;

  void updateSelectedDay(DateTime newSelectedDay) {
    _selectedDay = newSelectedDay;
    notifyListeners();
  }
}

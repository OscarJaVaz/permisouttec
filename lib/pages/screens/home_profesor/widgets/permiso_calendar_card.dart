import 'package:flutter/material.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_date_helper.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';
import 'package:table_calendar/table_calendar.dart';

class PermisoCalendarCard extends StatefulWidget {
  const PermisoCalendarCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.records,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<RtdbRecord> records;
  final void Function(DateTime selected, DateTime focused) onDaySelected;

  @override
  State<PermisoCalendarCard> createState() => _PermisoCalendarCardState();
}

class _PermisoCalendarCardState extends State<PermisoCalendarCard> {
  late Set<DateTime> _markedDays;

  @override
  void initState() {
    super.initState();
    _markedDays = _computeMarkedDays(widget.records);
  }

  @override
  void didUpdateWidget(PermisoCalendarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _computeMarkedDays(widget.records);
    if (!_setEquals(_markedDays, next)) {
      _markedDays = next;
    }
  }

  static Set<DateTime> _computeMarkedDays(List<RtdbRecord> records) {
    final days = <DateTime>{};
    for (final record in records) {
      if (record.boolValue('archivado')) continue;
      final fecha = RtdbDateHelper.fromValue(record.data['fecha']);
      if (fecha != null) {
        days.add(DateTime(fecha.year, fecha.month, fecha.day));
      }
    }
    return days;
  }

  static bool _setEquals(Set<DateTime> a, Set<DateTime> b) {
    if (a.length != b.length) return false;
    for (final day in a) {
      if (!b.contains(day)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LoginColors.paperWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LoginColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TableCalendar<void>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2035, 12, 31),
          focusedDay: widget.focusedDay,
          selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
          onDaySelected: widget.onDaySelected,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'es_MX',
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: UttTextStyles.montserrat(16, FontWeight.w600),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: LoginColors.deepEmerald,
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: LoginColors.deepEmerald,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: UttTextStyles.inter(12, color: LoginColors.outline),
            weekendStyle: UttTextStyles.inter(12, color: LoginColors.outline),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: UttTextStyles.inter(14),
            weekendTextStyle: UttTextStyles.inter(14),
            selectedDecoration: const BoxDecoration(
              color: LoginColors.deepEmerald,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: UttTextStyles.inter(
              14,
              color: LoginColors.onPrimary,
              weight: FontWeight.w600,
            ),
            todayDecoration: BoxDecoration(
              color: LoginColors.deepEmerald.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            todayTextStyle: UttTextStyles.inter(
              14,
              color: LoginColors.deepEmerald,
              weight: FontWeight.w600,
            ),
            markerDecoration: const BoxDecoration(
              color: LoginColors.institutionalGold,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 1,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final normalized = DateTime(day.year, day.month, day.day);
              if (!_markedDays.contains(normalized)) return null;
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: LoginColors.institutionalGold,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

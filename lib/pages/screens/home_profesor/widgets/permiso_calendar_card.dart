import 'package:flutter/material.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_date_helper.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';
import 'package:table_calendar/table_calendar.dart';

class PermisoCalendarCard extends StatelessWidget {
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
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  Color _colorForEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobado':
        return LoginColors.deepEmerald;
      case 'rechazado':
        return const Color(0xFFB3261E);
      default:
        return LoginColors.secondary;
    }
  }

  List<Color> _eventsForDay(DateTime day) {
    final colors = <Color>[];
    for (final record in records) {
      if (record.boolValue('archivado')) continue;
      if (!RtdbDateHelper.isSameDay(record.data['fecha'], day)) continue;
      final estado = record.string('estado') ?? 'pendiente';
      colors.add(_colorForEstado(estado));
    }
    return colors;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LoginColors.paperWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: LoginColors.deepEmerald.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: TableCalendar<Color>(
          focusedDay: focusedDay,
          firstDay: DateTime.utc(2010, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: onDaySelected,
          eventLoader: _eventsForDay,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: UttTextStyles.inter(14, color: LoginColors.onSurfaceVariant),
            defaultTextStyle: UttTextStyles.inter(14),
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
              color: LoginColors.institutionalGold.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            todayTextStyle: UttTextStyles.inter(14, weight: FontWeight.w600),
            markerSize: 6,
            markersMaxCount: 3,
            markerDecoration: const BoxDecoration(
              color: LoginColors.deepEmerald,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: true,
            titleTextStyle: UttTextStyles.montserrat(17, FontWeight.w600),
            formatButtonTextStyle: UttTextStyles.inter(
              12,
              color: LoginColors.deepEmerald,
              weight: FontWeight.w600,
            ),
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: LoginColors.outlineVariant),
              borderRadius: BorderRadius.circular(20),
            ),
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
            weekdayStyle: UttTextStyles.inter(
              12,
              color: LoginColors.onSurfaceVariant,
              weight: FontWeight.w600,
            ),
            weekendStyle: UttTextStyles.inter(
              12,
              color: LoginColors.onSurfaceVariant,
              weight: FontWeight.w600,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              return Positioned(
                bottom: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: events.take(3).map((color) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

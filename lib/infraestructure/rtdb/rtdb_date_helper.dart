/// Fechas en RTDB como milisegundos desde epoch (inicio del día local).
abstract final class RtdbDateHelper {
  static int toDayMillis(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return local.millisecondsSinceEpoch;
  }

  static DateTime? fromValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed != null
          ? DateTime(parsed.year, parsed.month, parsed.day)
          : null;
    }
    return null;
  }

  static bool isSameDay(dynamic stored, DateTime day) {
    final parsed = fromValue(stored);
    if (parsed == null) return false;
    return parsed.year == day.year &&
        parsed.month == day.month &&
        parsed.day == day.day;
  }
}

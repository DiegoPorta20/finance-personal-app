/// Periodo de tiempo compartido para filtrar datos (reportes, movimientos, etc.).
enum TimePeriod { daily, weekly, monthly, yearly }

extension TimePeriodX on TimePeriod {
  String get label {
    switch (this) {
      case TimePeriod.daily:
        return 'Diario';
      case TimePeriod.weekly:
        return 'Semanal';
      case TimePeriod.monthly:
        return 'Mensual';
      case TimePeriod.yearly:
        return 'Anual';
    }
  }

  /// Rango [start, end] del periodo relativo a [now].
  ({DateTime start, DateTime end}) range(DateTime now) {
    switch (this) {
      case TimePeriod.daily:
        return (
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case TimePeriod.weekly:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        return (
          start: start,
          end: start.add(
            const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
          ),
        );
      case TimePeriod.monthly:
        return (
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case TimePeriod.yearly:
        return (
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
    }
  }

  /// Meses de histórico para gráficas de tendencia.
  int get trendMonths {
    switch (this) {
      case TimePeriod.daily:
        return 1;
      case TimePeriod.weekly:
        return 1;
      case TimePeriod.monthly:
        return 6;
      case TimePeriod.yearly:
        return 12;
    }
  }
}

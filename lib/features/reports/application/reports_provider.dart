import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/report_model.dart';
import '../domain/report_period.dart';
import '../data/analytics_repository.dart';

/// Periodo seleccionado en Reportes (Diario/Semanal/Mensual/Anual).
/// Por defecto, Mensual.
final reportPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.monthly);

final categorySpendingProvider =
    FutureProvider<List<CategorySpending>>((ref) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final period = ref.watch(reportPeriodProvider);
  final range = period.range(DateTime.now());

  final data = await repo.spendingByCategory(
    range.start.toIso8601String(),
    range.end.toIso8601String(),
  );

  final totalSpent = data.fold<int>(
    0,
    (sum, d) => sum + (d['totalAmount'] as int? ?? 0),
  );

  return data.map((d) {
    final amount = d['totalAmount'] as int? ?? 0;
    return CategorySpending(
      categoryName: d['categoryName'] as String? ?? '',
      categoryIcon: d['categoryIcon'] as String? ?? 'more_horiz',
      totalAmount: amount,
      percentage: totalSpent > 0 ? (amount / totalSpent * 100) : 0,
    );
  }).toList();
});

final incomeCategoryProvider =
    FutureProvider<List<CategorySpending>>((ref) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final period = ref.watch(reportPeriodProvider);
  final range = period.range(DateTime.now());

  final data = await repo.incomeByCategory(
    range.start.toIso8601String(),
    range.end.toIso8601String(),
  );

  final total = data.fold<int>(
    0,
    (sum, d) => sum + (d['totalAmount'] as int? ?? 0),
  );

  return data.map((d) {
    final amount = d['totalAmount'] as int? ?? 0;
    return CategorySpending(
      categoryName: d['categoryName'] as String? ?? '',
      categoryIcon: d['categoryIcon'] as String? ?? 'more_horiz',
      totalAmount: amount,
      percentage: total > 0 ? (amount / total * 100) : 0,
    );
  }).toList();
});

final monthlyComparisonProvider =
    FutureProvider<List<MonthlyComparison>>((ref) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final period = ref.watch(reportPeriodProvider);
  final data = await repo.incomeVsExpense(months: period.trendMonths);

  return data.map((d) {
    final month = d['month'] as int? ?? 1;
    return MonthlyComparison(
      month: _monthLabel(month),
      income: d['totalIncome'] as int? ?? 0,
      expense: d['totalExpense'] as int? ?? 0,
    );
  }).toList();
});

final savingsTrendProvider =
    FutureProvider<List<SavingsTrend>>((ref) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final period = ref.watch(reportPeriodProvider);
  final data = await repo.savingsTrend(months: period.trendMonths);

  return data.map((d) {
    final month = d['month'] as int? ?? 1;
    return SavingsTrend(
      month: _monthLabel(month),
      amount: d['savedAmount'] as int? ?? 0,
    );
  }).toList();
});

String _monthLabel(int month) {
  const labels = [
    '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];
  return labels[month.clamp(1, 12)];
}

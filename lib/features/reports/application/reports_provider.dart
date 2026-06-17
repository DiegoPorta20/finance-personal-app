import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/report_model.dart';
import '../data/analytics_repository.dart';

final categorySpendingProvider =
    FutureProvider<List<CategorySpending>>((ref) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0);

  final data = await repo.spendingByCategory(
    start.toIso8601String(),
    end.toIso8601String(),
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

final monthlyComparisonProvider =
    FutureProvider<List<MonthlyComparison>>((ref) async {
  final repo = ref.read(analyticsRepositoryProvider);
  final data = await repo.incomeVsExpense(months: 6);

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
  final data = await repo.savingsTrend(months: 6);

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

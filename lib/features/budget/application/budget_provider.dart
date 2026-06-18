import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/budget_model.dart';
import '../data/budget_repository.dart';

const _essentialSlugs = ['housing', 'food', 'transport', 'health', 'debts'];

final budgetProvider = FutureProvider<BudgetSummary>((ref) async {
  final repo = ref.read(budgetRepositoryProvider);
  final now = DateTime.now();
  final data = await repo.getStatus(now.month, now.year);

  final categories = data.map((d) {
    final slug = d['categorySlug'] as String? ?? '';
    final group = _essentialSlugs.contains(slug) ? 'essentials' : 'lifestyle';
    return BudgetCategory(
      budgetId: d['budgetId'] as String? ?? '',
      categoryId: d['categoryId'] as String? ?? '',
      categoryName: d['categoryName'] as String? ?? '',
      categoryIcon: d['categoryIcon'] as String? ?? 'more_horiz',
      budgetAmount: d['budgetAmount'] as int? ?? 0,
      spentAmount: d['spentAmount'] as int? ?? 0,
      group: group,
    );
  }).toList();

  final totalIncome = categories.fold<int>(0, (s, c) => s + c.budgetAmount);

  return BudgetSummary(
    totalIncome: totalIncome,
    categories: categories,
  );
});

final autoGenerateProvider =
    FutureProvider.family<Map<String, dynamic>, void>((ref, _) async {
  final repo = ref.read(budgetRepositoryProvider);
  return repo.autoGenerate();
});

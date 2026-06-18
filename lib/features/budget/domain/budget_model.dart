class BudgetCategory {
  final String budgetId;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int budgetAmount;
  final int spentAmount;
  final String group; // essentials, lifestyle, savings

  const BudgetCategory({
    required this.budgetId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.budgetAmount,
    required this.spentAmount,
    required this.group,
  });

  double get progress =>
      budgetAmount > 0 ? (spentAmount / budgetAmount).clamp(0.0, 999.0) : 0;

  bool get isOverBudget => spentAmount > budgetAmount;

  int get remaining => budgetAmount - spentAmount;
}

class BudgetSummary {
  final int totalIncome;
  final List<BudgetCategory> categories;

  const BudgetSummary({
    required this.totalIncome,
    required this.categories,
  });

  int get totalBudget =>
      categories.fold<int>(0, (sum, c) => sum + c.budgetAmount);

  int get totalSpent =>
      categories.fold<int>(0, (sum, c) => sum + c.spentAmount);
}

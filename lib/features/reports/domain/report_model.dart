class CategorySpending {
  final String categoryName;
  final String categoryIcon;
  final int totalAmount;
  final double percentage;

  const CategorySpending({
    required this.categoryName,
    required this.categoryIcon,
    required this.totalAmount,
    required this.percentage,
  });
}

class MonthlyComparison {
  final String month;
  final int income;
  final int expense;

  const MonthlyComparison({
    required this.month,
    required this.income,
    required this.expense,
  });
}

class SavingsTrend {
  final String month;
  final int amount;

  const SavingsTrend({required this.month, required this.amount});
}

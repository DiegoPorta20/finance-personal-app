class DashboardData {
  final int totalBalance;
  final int monthlySavingsGoal;
  final int monthlySavingsCurrent;
  final List<AccountSummary> accounts;
  final List<RecentTransaction> recentTransactions;

  const DashboardData({
    required this.totalBalance,
    required this.monthlySavingsGoal,
    required this.monthlySavingsCurrent,
    required this.accounts,
    required this.recentTransactions,
  });

  double get savingsProgress =>
      monthlySavingsGoal > 0 ? monthlySavingsCurrent / monthlySavingsGoal : 0;
}

class AccountSummary {
  final String id;
  final String name;
  final String type;
  final int balance;
  final IconType icon;

  const AccountSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
  });
}

enum IconType { bank, cash, wallet }

class RecentTransaction {
  final String id;
  final String description;
  final String categoryName;
  final String categoryIcon;
  final int amount;
  final String type;
  final DateTime date;

  const RecentTransaction({
    required this.id,
    required this.description,
    required this.categoryName,
    required this.categoryIcon,
    required this.amount,
    required this.type,
    required this.date,
  });
}

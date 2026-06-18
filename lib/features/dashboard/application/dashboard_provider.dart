import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dashboard_model.dart';
import '../data/dashboard_repository.dart';

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() async {
    return _fetchData();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchData);
  }

  Future<DashboardData> _fetchData() async {
    final repo = ref.read(dashboardRepositoryProvider);

    final results = await Future.wait([
      repo.getAccounts(),
      repo.getRecentTransactions(),
    ]);

    final accounts = results[0] as List<AccountSummary>;
    final transactions = results[1] as List<RecentTransaction>;
    final totalBalance =
        accounts.fold<int>(0, (sum, a) => sum + a.balance);

    // Calculate monthly savings from transactions
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthTransactions = transactions
        .where((t) => t.date.isAfter(monthStart))
        .toList();
    final monthIncome = monthTransactions
        .where((t) => t.type == 'income')
        .fold<int>(0, (sum, t) => sum + t.amount);
    final monthExpense = monthTransactions
        .where((t) => t.type == 'expense')
        .fold<int>(0, (sum, t) => sum + t.amount);

    return DashboardData(
      totalBalance: totalBalance,
      monthlySavingsGoal: (monthIncome * 0.2).round(),
      monthlySavingsCurrent: monthIncome - monthExpense,
      accounts: accounts,
      recentTransactions: transactions,
    );
  }
}

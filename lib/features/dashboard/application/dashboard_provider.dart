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

    try {
      final results = await Future.wait([
        repo.getAccounts(),
        repo.getRecentTransactions(),
      ]);

      final accounts = results[0] as List<AccountSummary>;
      final transactions = results[1] as List<RecentTransaction>;
      final totalBalance =
          accounts.fold<int>(0, (sum, a) => sum + a.balance);

      return DashboardData(
        totalBalance: totalBalance,
        monthlySavingsGoal: 200000, // TODO: from savings goals API
        monthlySavingsCurrent: 135000, // TODO: calculate from transactions
        accounts: accounts,
        recentTransactions: transactions,
      );
    } catch (_) {
      // Fallback to mock if API unavailable
      return _mockData();
    }
  }

  DashboardData _mockData() {
    return DashboardData(
      totalBalance: 1250000,
      monthlySavingsGoal: 200000,
      monthlySavingsCurrent: 135000,
      accounts: const [
        AccountSummary(
            id: '1', name: 'Banco Principal', type: 'bank',
            balance: 850000, icon: IconType.bank),
        AccountSummary(
            id: '2', name: 'Efectivo', type: 'cash',
            balance: 250000, icon: IconType.cash),
        AccountSummary(
            id: '3', name: 'Billetera Digital', type: 'digital_wallet',
            balance: 150000, icon: IconType.wallet),
      ],
      recentTransactions: [
        RecentTransaction(
            id: '1', description: 'Supermercado',
            categoryName: 'Alimentacion', categoryIcon: 'restaurant',
            amount: 8500, type: 'expense',
            date: DateTime.now().subtract(const Duration(hours: 2))),
        RecentTransaction(
            id: '2', description: 'Sueldo mensual',
            categoryName: 'Sueldo fijo', categoryIcon: 'payments',
            amount: 500000, type: 'income',
            date: DateTime.now().subtract(const Duration(days: 1))),
        RecentTransaction(
            id: '3', description: 'Netflix',
            categoryName: 'Suscripciones', categoryIcon: 'autorenew',
            amount: 1599, type: 'expense',
            date: DateTime.now().subtract(const Duration(days: 2))),
      ],
    );
  }
}

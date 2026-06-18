import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_period.dart';
import '../domain/dashboard_model.dart';
import '../data/dashboard_repository.dart';
import '../../income_sources/data/income_sources_repository.dart';

/// Periodo seleccionado en el Dashboard (Diario/Semanal/Mensual/Anual).
final dashboardPeriodProvider =
    StateProvider<TimePeriod>((ref) => TimePeriod.monthly);

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() async {
    // Refetch cuando cambia el periodo seleccionado.
    ref.watch(dashboardPeriodProvider);
    return _fetchData();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchData);
  }

  Future<DashboardData> _fetchData() async {
    final repo = ref.read(dashboardRepositoryProvider);

    // Generar ingresos recurrentes vencidos antes de cargar los datos.
    await ref.read(incomeSourcesRepositoryProvider).generateDue();

    final results = await Future.wait([
      repo.getAccounts(),
      repo.getRecentTransactions(),
    ]);

    final accounts = results[0] as List<AccountSummary>;
    final transactions = results[1] as List<RecentTransaction>;
    final totalBalance =
        accounts.fold<int>(0, (sum, a) => sum + a.balance);

    // Ingresos/egresos del periodo seleccionado.
    final range = ref.read(dashboardPeriodProvider).range(DateTime.now());
    final periodTransactions = transactions
        .where((t) =>
            !t.date.isBefore(range.start) && !t.date.isAfter(range.end))
        .toList();
    final income = periodTransactions
        .where((t) => t.type == 'income')
        .fold<int>(0, (sum, t) => sum + t.amount);
    final expense = periodTransactions
        .where((t) => t.type == 'expense')
        .fold<int>(0, (sum, t) => sum + t.amount);

    return DashboardData(
      totalBalance: totalBalance,
      monthlySavingsGoal: (income * 0.2).round(),
      monthlySavingsCurrent: income - expense,
      accounts: accounts,
      recentTransactions: transactions,
    );
  }
}

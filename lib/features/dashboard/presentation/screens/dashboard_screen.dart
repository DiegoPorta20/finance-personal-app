import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/period_selector.dart';
import '../../application/dashboard_provider.dart';
import '../../domain/dashboard_model.dart';
import '../widgets/savings_ring.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_tile.dart';
import '../../../auth/application/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text('Error al cargar datos',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.read(dashboardProvider.notifier).refresh(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (data) => _DashboardContent(data: data),
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final DashboardData data;

  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tu resumen',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              IconButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Selector de periodo
          PeriodSelector(
            selected: ref.watch(dashboardPeriodProvider),
            onChanged: (p) =>
                ref.read(dashboardPeriodProvider.notifier).state = p,
          ),
          const SizedBox(height: 16),

          // Total balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.cCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance total',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.formatDefault(data.totalBalance),
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Savings ring
          SavingsRing(
            currentAmount: data.monthlySavingsCurrent,
            goalAmount: data.monthlySavingsGoal,
          ),
          const SizedBox(height: 20),

          // Accounts section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mis cuentas',
                  style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => context.push('/accounts'),
                child: const Text('Ver todas',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.accounts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  AccountCard(account: data.accounts[index]),
            ),
          ),
          const SizedBox(height: 24),

          // Recent transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transacciones recientes',
                  style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => context.push('/transactions'),
                child: const Text('Ver todas',
                    style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (data.recentTransactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Sin transacciones aun',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...data.recentTransactions
                .map((tx) => TransactionTile(transaction: tx)),
        ],
      ),
    );
  }
}

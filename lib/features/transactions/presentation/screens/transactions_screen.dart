import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/time_period.dart';
import '../../../../core/widgets/period_selector.dart';
import '../../application/transactions_provider.dart';
import '../../domain/transaction_model.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transacciones'),
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Todo'),
              Tab(text: 'Gastos'),
              Tab(text: 'Ingresos'),
            ],
          ),
        ),
        body: Column(
          children: [
            PeriodSelector(
              selected: ref.watch(transactionsPeriodProvider),
              onChanged: (p) =>
                  ref.read(transactionsPeriodProvider.notifier).state = p,
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _TransactionList(filter: null),
                  _TransactionList(filter: 'expense'),
                  _TransactionList(filter: 'income'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _TransactionList extends ConsumerWidget {
  final String? filter;

  const _TransactionList({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);
    final range = ref.watch(transactionsPeriodProvider).range(DateTime.now());

    return txAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text('Error al cargar', style: Theme.of(context).textTheme.bodyLarge),
            TextButton(
              onPressed: () =>
                  ref.read(transactionsProvider.notifier).refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      data: (transactions) {
        final filtered = transactions.where((tx) {
          final matchesType = filter == null || tx.type == filter;
          final inRange = !tx.date.isBefore(range.start) &&
              !tx.date.isAfter(range.end);
          return matchesType && inRange;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: AppColors.textSecondary, size: 64),
                const SizedBox(height: 16),
                Text('Sin transacciones',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () =>
              ref.read(transactionsProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                _TransactionItem(transaction: filtered[index]),
          ),
        );
      },
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final sign = isIncome ? '+' : '-';
    final amountColor = isIncome ? AppColors.accent : AppColors.textPrimary;
    final dateFormat = DateFormat('dd MMM, HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _mapIcon(transaction.categoryIcon ?? 'more_horiz'),
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.note ?? transaction.categoryName ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.categoryName ?? ''} · ${dateFormat.format(transaction.date)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text(
              '$sign${CurrencyFormatter.formatDefault(transaction.amount)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: amountColor),
            ),
          ],
        ),
      ),
    );
  }

  IconData _mapIcon(String iconName) {
    return switch (iconName) {
      'restaurant' => Icons.restaurant,
      'payments' => Icons.payments,
      'autorenew' => Icons.autorenew,
      'directions_car' => Icons.directions_car,
      'home' => Icons.home,
      'movie' => Icons.movie,
      'local_hospital' => Icons.local_hospital,
      'credit_card' => Icons.credit_card,
      'school' => Icons.school,
      'work' => Icons.work,
      'home_work' => Icons.home_work,
      'trending_up' => Icons.trending_up,
      _ => Icons.more_horiz,
    };
  }
}

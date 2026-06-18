import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/list_skeleton.dart';
import '../../../../core/utils/time_period.dart';
import '../../../../core/widgets/period_selector.dart';
import '../../application/transactions_provider.dart';
import '../../domain/transaction_model.dart';
import '../widgets/create_transaction_sheet.dart';
import '../../../dashboard/application/dashboard_provider.dart';
import '../../../accounts/application/accounts_provider.dart';

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
            unselectedLabelColor: context.cTextSecondary,
            tabs: const [
              Tab(text: 'Todo'),
              Tab(text: 'Gastos'),
              Tab(text: 'Ingresos'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: (v) =>
                    ref.read(transactionsSearchProvider.notifier).state = v,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nota o categoria',
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textSecondary),
                ),
                style: TextStyle(color: context.cTextPrimary),
              ),
            ),
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
    final query = ref.watch(transactionsSearchProvider).trim().toLowerCase();

    return txAsync.when(
      loading: () => const ListSkeleton(),
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
          final matchesQuery = query.isEmpty ||
              (tx.note ?? '').toLowerCase().contains(query) ||
              (tx.categoryName ?? '').toLowerCase().contains(query);
          return matchesType && inRange && matchesQuery;
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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: context.cCard,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const CreateTransactionSheet(),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar movimiento'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () =>
              ref.read(transactionsProvider.notifier).refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                ref.read(transactionsProvider.notifier).loadMore();
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              itemBuilder: (context, index) =>
                  _TransactionItem(transaction: filtered[index]),
            ),
          ),
        );
      },
    );
  }
}

class _TransactionItem extends ConsumerWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.isIncome;
    final sign = isIncome ? '+' : '-';
    final amountColor = isIncome ? AppColors.accent : context.cTextPrimary;
    final dateFormat = DateFormat('dd MMM, HH:mm');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetail(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.cBg,
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
        ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.isIncome;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final color = isIncome ? AppColors.accent : AppColors.error;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(_mapIcon(transaction.categoryIcon ?? 'more_horiz'),
                  color: color),
            ),
            const SizedBox(height: 12),
            Text(
              '${isIncome ? '+' : '-'}'
              '${CurrencyFormatter.formatDefault(transaction.amount)}',
              style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                  color: isIncome ? AppColors.accent : context.cTextPrimary),
            ),
            Text(isIncome ? 'Ingreso' : 'Gasto',
                style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 20),
            _detailRow(ctx, 'Categoria', transaction.categoryName ?? '-'),
            _detailRow(ctx, 'Cuenta', transaction.accountName ?? '-'),
            _detailRow(ctx, 'Fecha', dateFormat.format(transaction.date)),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              _detailRow(ctx, 'Nota', transaction.note!),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _edit(context);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _delete(ctx, ref),
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                    label: const Text('Eliminar',
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ))),
    );
  }

  void _edit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateTransactionSheet(transaction: transaction),
    );
  }

  Future<void> _delete(BuildContext sheetCtx, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(sheetCtx);
    final navigator = Navigator.of(sheetCtx);
    final confirmed = await showConfirmDialog(
      sheetCtx,
      title: 'Eliminar transaccion',
      message:
          'Esta accion no se puede deshacer y ajustara el balance de la cuenta.',
    );
    if (!confirmed) return;
    await ref
        .read(transactionsProvider.notifier)
        .deleteTransaction(transaction.id);
    ref.invalidate(dashboardProvider);
    ref.invalidate(accountsProvider);
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Transaccion eliminada')),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 16),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
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

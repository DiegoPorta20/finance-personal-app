import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/dashboard_model.dart';

class TransactionTile extends StatelessWidget {
  final RecentTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final sign = isIncome ? '+' : '-';
    final amountColor = isIncome ? AppColors.accent : context.cTextPrimary;

    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.cCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _mapIcon(transaction.categoryIcon),
              color: context.cTextSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  transaction.categoryName,
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

  void _showDetail(BuildContext context) {
    final isIncome = transaction.type == 'income';
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
              child: Icon(_mapIcon(transaction.categoryIcon), color: color),
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
            _detailRow(ctx, 'Categoria', transaction.categoryName),
            _detailRow(ctx, 'Descripcion', transaction.description),
            _detailRow(ctx, 'Fecha', dateFormat.format(transaction.date)),
          ],
        ),
      ))),
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

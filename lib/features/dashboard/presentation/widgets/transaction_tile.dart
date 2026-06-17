import 'package:flutter/material.dart';

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
    final amountColor = isIncome ? AppColors.accent : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _mapIcon(transaction.categoryIcon),
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

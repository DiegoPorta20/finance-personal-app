import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/dashboard_model.dart';

class AccountCard extends StatelessWidget {
  final AccountSummary account;

  const AccountCard({super.key, required this.account});

  IconData get _icon => switch (account.icon) {
        IconType.bank => Icons.account_balance,
        IconType.cash => Icons.money,
        IconType.wallet => Icons.account_balance_wallet,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            account.name,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatDefault(account.balance),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

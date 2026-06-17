import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../application/budget_provider.dart';
import '../../domain/budget_model.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Presupuesto')),
      body: budgetAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (_, _) =>
            const Center(child: Text('Error al cargar presupuesto')),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text('Regla 50/30/20',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Ingreso: ${CurrencyFormatter.formatDefault(summary.totalIncome)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _RulePill(
                          label: 'Esenciales', percent: '50%',
                          color: AppColors.accent),
                      _RulePill(
                          label: 'Estilo de vida', percent: '30%',
                          color: const Color(0xFF5AC8FA)),
                      _RulePill(
                          label: 'Ahorro', percent: '20%',
                          color: const Color(0xFFFF9500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionHeader(title: 'Esenciales (50%)'),
            ...summary.categories
                .where((c) => c.group == 'essentials')
                .map((c) => _BudgetTile(category: c)),

            const SizedBox(height: 16),
            _SectionHeader(title: 'Estilo de vida (30%)'),
            ...summary.categories
                .where((c) => c.group == 'lifestyle')
                .map((c) => _BudgetTile(category: c)),

            const SizedBox(height: 16),
            _SectionHeader(title: 'Ahorro (20%)'),
            ...summary.categories
                .where((c) => c.group == 'savings')
                .map((c) => _BudgetTile(category: c)),
          ],
        ),
      ),
    );
  }
}

class _RulePill extends StatelessWidget {
  final String label;
  final String percent;
  final Color color;

  const _RulePill({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(percent,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final BudgetCategory category;

  const _BudgetTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final progressColor =
        category.isOverBudget ? AppColors.error : AppColors.accent;
    final clampedProgress = category.progress.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category.categoryName,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${CurrencyFormatter.formatDefault(category.spentAmount)}'
                  ' / ${CurrencyFormatter.formatDefault(category.budgetAmount)}',
                  style: TextStyle(
                    color: category.isOverBudget
                        ? AppColors.error
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: clampedProgress,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

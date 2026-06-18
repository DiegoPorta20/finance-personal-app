import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/spending_pie_chart.dart';
import '../widgets/income_expense_bar_chart.dart';
import '../widgets/savings_line_chart.dart';
import '../widgets/period_selector.dart';
import '../../application/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reportes'),
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Categorias'),
              Tab(text: 'Ing vs Eg'),
              Tab(text: 'Ahorro'),
            ],
          ),
        ),
        body: Column(
          children: [
            PeriodSelector(
              selected: ref.watch(reportPeriodProvider),
              onChanged: (p) =>
                  ref.read(reportPeriodProvider.notifier).state = p,
            ),
            Expanded(
              child: TabBarView(
                children: const [
                  SpendingPieChart(),
                  IncomeExpenseBarChart(),
                  SavingsLineChart(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/reports_provider.dart';

class IncomeExpenseBarChart extends ConsumerWidget {
  const IncomeExpenseBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(monthlyComparisonProvider);

    return dataAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, _) => const Center(child: Text('Error al cargar')),
      data: (months) {
        if (months.isEmpty) {
          return const Center(child: Text('Sin datos'));
        }

        final maxVal = months.fold<int>(0, (max, m) {
          final bigger = m.income > m.expense ? m.income : m.expense;
          return bigger > max ? bigger : max;
        });

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(
                      color: AppColors.accent, label: 'Ingresos'),
                  const SizedBox(width: 24),
                  _LegendDot(
                      color: AppColors.error, label: 'Egresos'),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: maxVal / 100 * 1.2,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= months.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(months[idx].month,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 48,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox.shrink();
                            return Text(_compactMoney(value),
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10));
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: context.cDivider, strokeWidth: 1),
                    ),
                    barGroups: months.asMap().entries.map((entry) {
                      final i = entry.key;
                      final m = entry.value;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: m.income / 100,
                            color: AppColors.accent,
                            width: 14,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                          BarChartRodData(
                            toY: m.expense / 100,
                            color: AppColors.error,
                            width: 14,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _compactMoney(double value) {
  if (value.abs() >= 1000) {
    final k = value / 1000;
    return '\$${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
  }
  return '\$${value.toInt()}';
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}

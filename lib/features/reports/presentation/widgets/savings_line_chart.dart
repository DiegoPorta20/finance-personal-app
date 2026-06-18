import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../application/reports_provider.dart';

class SavingsLineChart extends ConsumerWidget {
  const SavingsLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(savingsTrendProvider);

    return dataAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, _) => const Center(child: Text('Error al cargar')),
      data: (trend) {
        if (trend.isEmpty) {
          return const Center(child: Text('Sin datos'));
        }

        final maxVal = trend.fold<int>(
            0, (max, t) => t.amount > max ? t.amount : max);
        final total = trend.fold<int>(0, (sum, t) => sum + t.amount);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Ahorro acumulado',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.formatDefault(total),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxVal / 100 * 1.3,
                    lineTouchData: const LineTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= trend.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(trend[idx].month,
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
                          FlLine(color: AppColors.divider, strokeWidth: 1),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: trend.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.amount / 100,
                          );
                        }).toList(),
                        isCurved: true,
                        color: AppColors.accent,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.accent,
                            strokeWidth: 0,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.accent.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
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

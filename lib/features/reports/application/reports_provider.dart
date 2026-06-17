import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/report_model.dart';

final categorySpendingProvider =
    FutureProvider<List<CategorySpending>>((ref) async {
  // TODO: Replace with analytics API call
  await Future.delayed(const Duration(milliseconds: 400));
  return const [
    CategorySpending(
        categoryName: 'Alimentacion', categoryIcon: 'restaurant',
        totalAmount: 45000, percentage: 35),
    CategorySpending(
        categoryName: 'Transporte', categoryIcon: 'directions_car',
        totalAmount: 20000, percentage: 15.5),
    CategorySpending(
        categoryName: 'Entretenimiento', categoryIcon: 'movie',
        totalAmount: 18000, percentage: 14),
    CategorySpending(
        categoryName: 'Suscripciones', categoryIcon: 'autorenew',
        totalAmount: 12000, percentage: 9.3),
    CategorySpending(
        categoryName: 'Salud', categoryIcon: 'local_hospital',
        totalAmount: 15000, percentage: 11.6),
    CategorySpending(
        categoryName: 'Otros', categoryIcon: 'more_horiz',
        totalAmount: 19000, percentage: 14.6),
  ];
});

final monthlyComparisonProvider =
    FutureProvider<List<MonthlyComparison>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return const [
    MonthlyComparison(month: 'Ene', income: 500000, expense: 380000),
    MonthlyComparison(month: 'Feb', income: 500000, expense: 420000),
    MonthlyComparison(month: 'Mar', income: 575000, expense: 350000),
    MonthlyComparison(month: 'Abr', income: 500000, expense: 410000),
    MonthlyComparison(month: 'May', income: 550000, expense: 390000),
    MonthlyComparison(month: 'Jun', income: 500000, expense: 365000),
  ];
});

final savingsTrendProvider =
    FutureProvider<List<SavingsTrend>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return const [
    SavingsTrend(month: 'Ene', amount: 120000),
    SavingsTrend(month: 'Feb', amount: 80000),
    SavingsTrend(month: 'Mar', amount: 225000),
    SavingsTrend(month: 'Abr', amount: 90000),
    SavingsTrend(month: 'May', amount: 160000),
    SavingsTrend(month: 'Jun', amount: 135000),
  ];
});

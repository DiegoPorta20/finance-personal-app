import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/budget_model.dart';

final budgetProvider = FutureProvider<BudgetSummary>((ref) async {
  // TODO: Replace with API call
  await Future.delayed(const Duration(milliseconds: 400));

  const totalIncome = 500000; // $5,000.00

  // 50/30/20 rule applied
  return const BudgetSummary(
    totalIncome: totalIncome,
    categories: [
      // Essentials (50%)
      BudgetCategory(
          categoryId: 'housing', categoryName: 'Vivienda',
          categoryIcon: 'home', budgetAmount: 100000,
          spentAmount: 95000, group: 'essentials'),
      BudgetCategory(
          categoryId: 'food', categoryName: 'Alimentacion',
          categoryIcon: 'restaurant', budgetAmount: 75000,
          spentAmount: 45000, group: 'essentials'),
      BudgetCategory(
          categoryId: 'transport', categoryName: 'Transporte',
          categoryIcon: 'directions_car', budgetAmount: 40000,
          spentAmount: 20000, group: 'essentials'),
      BudgetCategory(
          categoryId: 'health', categoryName: 'Salud',
          categoryIcon: 'local_hospital', budgetAmount: 25000,
          spentAmount: 15000, group: 'essentials'),
      BudgetCategory(
          categoryId: 'debts', categoryName: 'Deudas',
          categoryIcon: 'credit_card', budgetAmount: 10000,
          spentAmount: 10000, group: 'essentials'),
      // Lifestyle (30%)
      BudgetCategory(
          categoryId: 'entertainment', categoryName: 'Entretenimiento',
          categoryIcon: 'movie', budgetAmount: 60000,
          spentAmount: 18000, group: 'lifestyle'),
      BudgetCategory(
          categoryId: 'subscriptions', categoryName: 'Suscripciones',
          categoryIcon: 'autorenew', budgetAmount: 30000,
          spentAmount: 12000, group: 'lifestyle'),
      BudgetCategory(
          categoryId: 'education', categoryName: 'Educacion',
          categoryIcon: 'school', budgetAmount: 40000,
          spentAmount: 0, group: 'lifestyle'),
      BudgetCategory(
          categoryId: 'other_expense', categoryName: 'Otros',
          categoryIcon: 'more_horiz', budgetAmount: 20000,
          spentAmount: 19000, group: 'lifestyle'),
      // Savings (20%)
      BudgetCategory(
          categoryId: 'savings', categoryName: 'Ahorro',
          categoryIcon: 'savings', budgetAmount: 100000,
          spentAmount: 0, group: 'savings'),
    ],
  );
});

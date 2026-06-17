import 'package:flutter_test/flutter_test.dart';
import 'package:finance_personal_app/features/budget/domain/budget_model.dart';

void main() {
  group('BudgetCategory', () {
    test('progress is 0 when budgetAmount is 0', () {
      const category = BudgetCategory(
        categoryId: '1', categoryName: 'Test', categoryIcon: 'test',
        budgetAmount: 0, spentAmount: 100, group: 'essentials',
      );
      expect(category.progress, 0);
    });

    test('progress calculates correctly', () {
      const category = BudgetCategory(
        categoryId: '1', categoryName: 'Test', categoryIcon: 'test',
        budgetAmount: 10000, spentAmount: 7500, group: 'essentials',
      );
      expect(category.progress, 0.75);
    });

    test('progress can exceed 1.0 (over budget)', () {
      const category = BudgetCategory(
        categoryId: '1', categoryName: 'Test', categoryIcon: 'test',
        budgetAmount: 10000, spentAmount: 15000, group: 'essentials',
      );
      expect(category.progress, 1.5);
    });

    test('isOverBudget true when spent > budget', () {
      const category = BudgetCategory(
        categoryId: '1', categoryName: 'Test', categoryIcon: 'test',
        budgetAmount: 10000, spentAmount: 12000, group: 'essentials',
      );
      expect(category.isOverBudget, true);
    });

    test('isOverBudget false when spent <= budget', () {
      const category = BudgetCategory(
        categoryId: '1', categoryName: 'Test', categoryIcon: 'test',
        budgetAmount: 10000, spentAmount: 10000, group: 'essentials',
      );
      expect(category.isOverBudget, false);
    });

    test('remaining is negative when over budget', () {
      const category = BudgetCategory(
        categoryId: '1', categoryName: 'Test', categoryIcon: 'test',
        budgetAmount: 10000, spentAmount: 15000, group: 'essentials',
      );
      expect(category.remaining, -5000);
    });

    test('remaining is positive when under budget', () {
      const category = BudgetCategory(
        categoryId: '1', categoryName: 'Test', categoryIcon: 'test',
        budgetAmount: 10000, spentAmount: 3000, group: 'essentials',
      );
      expect(category.remaining, 7000);
    });
  });

  group('BudgetSummary', () {
    test('totalBudget sums all category budgets', () {
      const summary = BudgetSummary(
        totalIncome: 500000,
        categories: [
          BudgetCategory(
            categoryId: '1', categoryName: 'A', categoryIcon: 'a',
            budgetAmount: 10000, spentAmount: 0, group: 'essentials',
          ),
          BudgetCategory(
            categoryId: '2', categoryName: 'B', categoryIcon: 'b',
            budgetAmount: 20000, spentAmount: 0, group: 'lifestyle',
          ),
        ],
      );
      expect(summary.totalBudget, 30000);
    });

    test('totalSpent sums all category spending', () {
      const summary = BudgetSummary(
        totalIncome: 500000,
        categories: [
          BudgetCategory(
            categoryId: '1', categoryName: 'A', categoryIcon: 'a',
            budgetAmount: 10000, spentAmount: 5000, group: 'essentials',
          ),
          BudgetCategory(
            categoryId: '2', categoryName: 'B', categoryIcon: 'b',
            budgetAmount: 20000, spentAmount: 8000, group: 'lifestyle',
          ),
        ],
      );
      expect(summary.totalSpent, 13000);
    });
  });
}

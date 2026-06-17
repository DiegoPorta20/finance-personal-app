import 'package:flutter_test/flutter_test.dart';
import 'package:finance_personal_app/features/savings_goals/domain/savings_goal_model.dart';

void main() {
  group('SavingsGoal', () {
    test('progress is 0 when targetAmount is 0', () {
      const goal = SavingsGoal(
        id: '1', name: 'Test', targetAmount: 0, currentAmount: 100,
      );
      expect(goal.progress, 0);
    });

    test('progress calculates correctly', () {
      const goal = SavingsGoal(
        id: '1', name: 'Test', targetAmount: 100000, currentAmount: 65000,
      );
      expect(goal.progress, 0.65);
    });

    test('progress clamps at 1.0', () {
      const goal = SavingsGoal(
        id: '1', name: 'Test', targetAmount: 100000, currentAmount: 150000,
      );
      expect(goal.progress, 1.0);
    });

    test('remaining is positive when not reached', () {
      const goal = SavingsGoal(
        id: '1', name: 'Test', targetAmount: 100000, currentAmount: 40000,
      );
      expect(goal.remaining, 60000);
    });

    test('remaining is negative when exceeded', () {
      const goal = SavingsGoal(
        id: '1', name: 'Test', targetAmount: 100000, currentAmount: 120000,
      );
      expect(goal.remaining, -20000);
    });

    test('remaining is 0 when exactly met', () {
      const goal = SavingsGoal(
        id: '1', name: 'Test', targetAmount: 100000, currentAmount: 100000,
      );
      expect(goal.remaining, 0);
    });

    test('fromJson parses correctly', () {
      final goal = SavingsGoal.fromJson({
        'id': 'goal-1',
        'name': 'Vacation',
        'targetAmount': 300000,
        'currentAmount': 150000,
        'deadline': '2026-12-31T00:00:00.000Z',
      });

      expect(goal.id, 'goal-1');
      expect(goal.name, 'Vacation');
      expect(goal.targetAmount, 300000);
      expect(goal.currentAmount, 150000);
      expect(goal.deadline, isNotNull);
      expect(goal.progress, 0.5);
    });

    test('fromJson handles null currentAmount', () {
      final goal = SavingsGoal.fromJson({
        'id': 'goal-1',
        'name': 'Test',
        'targetAmount': 100000,
      });

      expect(goal.currentAmount, 0);
      expect(goal.progress, 0);
    });

    test('fromJson handles null deadline', () {
      final goal = SavingsGoal.fromJson({
        'id': 'goal-1',
        'name': 'Test',
        'targetAmount': 100000,
        'currentAmount': 50000,
        'deadline': null,
      });

      expect(goal.deadline, isNull);
    });
  });
}

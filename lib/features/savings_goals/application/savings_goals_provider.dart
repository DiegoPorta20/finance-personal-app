import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/savings_goal_model.dart';

final savingsGoalsProvider =
    AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoal>>(
  SavingsGoalsNotifier.new,
);

class SavingsGoalsNotifier extends AsyncNotifier<List<SavingsGoal>> {
  @override
  Future<List<SavingsGoal>> build() async {
    // TODO: Replace with API call
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockGoals();
  }

  Future<void> addGoal(String name, int targetAmount, DateTime? deadline) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      final current = state.valueOrNull ?? [];
      final newGoal = SavingsGoal(
        id: 'goal-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0,
        deadline: deadline,
      );
      return [...current, newGoal];
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockGoals();
    });
  }

  List<SavingsGoal> _mockGoals() {
    return [
      SavingsGoal(
        id: '1',
        name: 'Fondo de emergencia',
        targetAmount: 1000000,
        currentAmount: 650000,
        deadline: DateTime(2026, 12, 31),
      ),
      SavingsGoal(
        id: '2',
        name: 'Vacaciones',
        targetAmount: 300000,
        currentAmount: 120000,
        deadline: DateTime(2026, 8, 15),
      ),
      SavingsGoal(
        id: '3',
        name: 'Laptop nueva',
        targetAmount: 200000,
        currentAmount: 45000,
      ),
    ];
  }
}

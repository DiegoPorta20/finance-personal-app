import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/savings_goal_model.dart';
import '../data/savings_goals_repository.dart';

final savingsGoalsProvider =
    AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoal>>(
  SavingsGoalsNotifier.new,
);

class SavingsGoalsNotifier extends AsyncNotifier<List<SavingsGoal>> {
  @override
  Future<List<SavingsGoal>> build() async {
    final repo = ref.read(savingsGoalsRepositoryProvider);
    final data = await repo.getAll();
    return data.map(SavingsGoal.fromJson).toList();
  }

  Future<void> addGoal(
      String name, int targetAmount, DateTime? deadline) async {
    final repo = ref.read(savingsGoalsRepositoryProvider);
    await repo.create({
      'name': name,
      'targetAmount': targetAmount,
      if (deadline != null) 'deadline': deadline.toIso8601String(),
    });
    ref.invalidateSelf();
  }

  Future<void> updateGoal(String id, String name, int targetAmount) async {
    final repo = ref.read(savingsGoalsRepositoryProvider);
    await repo.update(id, {'name': name, 'targetAmount': targetAmount});
    ref.invalidateSelf();
  }

  Future<void> addFunds(String id, int amount) async {
    final repo = ref.read(savingsGoalsRepositoryProvider);
    await repo.addFunds(id, amount);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

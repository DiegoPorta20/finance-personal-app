class SavingsGoal {
  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final DateTime? deadline;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;

  int get remaining => targetAmount - currentAmount;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: json['targetAmount'] as int,
      currentAmount: json['currentAmount'] as int? ?? 0,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
    );
  }
}

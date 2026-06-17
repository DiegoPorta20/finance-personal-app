class IncomeSource {
  final String id;
  final String name;
  final String type;
  final int amount;
  final String periodicity;
  final DateTime nextDate;
  final String accountId;

  const IncomeSource({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.periodicity,
    required this.nextDate,
    required this.accountId,
  });

  factory IncomeSource.fromJson(Map<String, dynamic> json) {
    return IncomeSource(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      amount: json['amount'] as int,
      periodicity: json['periodicity'] as String,
      nextDate: DateTime.parse(json['nextDate'] as String),
      accountId: json['accountId'] as String,
    );
  }

  String get typeLabel => switch (type) {
        'salary' => 'Sueldo fijo',
        'freelance' => 'Freelance',
        'rent_income' => 'Renta',
        'investment' => 'Inversiones',
        'other_income' => 'Otros',
        _ => type,
      };

  String get periodicityLabel => switch (periodicity) {
        'weekly' => 'Semanal',
        'biweekly' => 'Quincenal',
        'monthly' => 'Mensual',
        _ => periodicity,
      };
}

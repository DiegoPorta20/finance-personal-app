class Transaction {
  final String id;
  final String type;
  final int amount;
  final DateTime date;
  final String? note;
  final String accountId;
  final String categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? accountName;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
    required this.accountId,
    required this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.accountName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final account = json['account'] as Map<String, dynamic>?;
    return Transaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as int,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      accountId: json['accountId'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
      accountName: account?['name'] as String?,
    );
  }

  bool get isIncome => type == 'income';
}

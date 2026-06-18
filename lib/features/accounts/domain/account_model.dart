class Account {
  final String id;
  final String name;
  final String type;
  final String currency;
  final int balance;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      currency: json['currency'] as String? ?? 'USD',
      balance: json['balance'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'type': type,
      'currency': currency,
    };
  }

  String get typeLabel => switch (type) {
        'bank' => 'Banco',
        'cash' => 'Efectivo',
        'digital_wallet' => 'Billetera Digital',
        _ => type,
      };
}

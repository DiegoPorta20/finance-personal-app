class Recommendation {
  final String type; // budget_alert | savings_warning | goal_at_risk | tip
  final String severity; // high | medium | low
  final String title;
  final String message;

  const Recommendation({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      type: json['type'] as String? ?? 'tip',
      severity: json['severity'] as String? ?? 'low',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

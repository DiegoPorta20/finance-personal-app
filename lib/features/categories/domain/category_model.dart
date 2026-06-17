class Category {
  final String id;
  final String slug;
  final String name;
  final String icon;
  final String type;

  const Category({
    required this.id,
    required this.slug,
    required this.name,
    required this.icon,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'more_horiz',
      type: json['type'] as String,
    );
  }
}

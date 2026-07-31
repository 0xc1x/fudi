/// DB-driven category model backed by the `categories` table.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.slug,
    this.emoji,
    this.imageUrl,
    this.active = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String?,
    emoji: json['emoji'] as String?,
    imageUrl: json['image_url'] as String?,
    active: json['active'] as bool? ?? true,
  );

  final String id;
  final String name;
  final String? slug;
  final String? emoji;
  final String? imageUrl;
  final bool active;

  /// Parses the embedded `offer_categories → categories` shape returned by
  /// PostgREST when an offer row is selected with its categories.
  static List<Category> fromEmbedded(List<dynamic>? rows) {
    if (rows == null) return const [];
    final result = <Category>[];
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      final categoryJson = map['categories'] as Map<String, dynamic>?;
      if (categoryJson != null) {
        result.add(Category.fromJson(categoryJson));
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'emoji': emoji,
    'image_url': imageUrl,
    'active': active,
  };
}

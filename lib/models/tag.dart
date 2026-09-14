class Tag {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? color;
  final int position;

  Tag({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.color,
    this.position = 0,
  });

  factory Tag.fromJsonApi(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    return Tag(
      id: json['id']?.toString() ?? '',
      name: attributes['name'] as String? ?? '',
      slug: attributes['slug'] as String? ?? '',
      description: attributes['description'] as String?,
      color: attributes['color'] as String?,
      position: attributes['position'] as int? ?? 0,
    );
  }
}

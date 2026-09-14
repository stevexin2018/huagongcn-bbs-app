class Discussion {
  final String id;
  final String title;
  final String? slug;
  final int commentCount;
  final int participantCount;
  final DateTime? createdAt;
  final DateTime? lastPostedAt;
  final String? userName;
  final String? userAvatarUrl;
  final String? firstPostExcerpt;
  final List<String> tagIds;
  final List<String> tagNames;

  Discussion({
    required this.id,
    required this.title,
    this.slug,
    this.commentCount = 0,
    this.participantCount = 0,
    this.createdAt,
    this.lastPostedAt,
    this.userName,
    this.userAvatarUrl,
    this.firstPostExcerpt,
    this.tagIds = const [],
    this.tagNames = const [],
  });

  factory Discussion.fromJsonApi(Map<String, dynamic> json, List<dynamic> included) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    final relationships = json['relationships'] as Map<String, dynamic>? ?? {};

    // 查找关联的发帖用户信息
    String? authorName;
    String? authorAvatar;
    final userRel = relationships['user']?['data'];
    if (userRel != null && userRel is Map<String, dynamic>) {
      final userId = userRel['id']?.toString();
      for (final inc in included) {
        if (inc['type'] == 'users' && inc['id']?.toString() == userId) {
          final userAttr = inc['attributes'] as Map<String, dynamic>? ?? {};
          authorName = userAttr['displayName'] ?? userAttr['username'];
          authorAvatar = userAttr['avatarUrl'];
          break;
        }
      }
    }

    // 查找关联的 Tags 标签
    final List<String> tagIdList = [];
    final List<String> tagNameList = [];
    final tagsRel = relationships['tags']?['data'];
    if (tagsRel != null && tagsRel is List) {
      for (final tr in tagsRel) {
        final tId = tr['id']?.toString();
        if (tId != null) {
          tagIdList.add(tId);
          for (final inc in included) {
            if (inc['type'] == 'tags' && inc['id']?.toString() == tId) {
              final tAttr = inc['attributes'] as Map<String, dynamic>? ?? {};
              if (tAttr['name'] != null) {
                tagNameList.add(tAttr['name']);
              }
              break;
            }
          }
        }
      }
    }

    // 查找首楼内容预览（firstPost）
    String? excerpt;
    final firstPostRel = relationships['firstPost']?['data'];
    if (firstPostRel != null && firstPostRel is Map<String, dynamic>) {
      final fpId = firstPostRel['id']?.toString();
      for (final inc in included) {
        if (inc['type'] == 'posts' && inc['id']?.toString() == fpId) {
          final pAttr = inc['attributes'] as Map<String, dynamic>? ?? {};
          excerpt = pAttr['contentHtml'] ?? pAttr['content'];
          break;
        }
      }
    }

    DateTime? parseDate(String? d) => d != null ? DateTime.tryParse(d) : null;

    return Discussion(
      id: json['id']?.toString() ?? '',
      title: attributes['title'] as String? ?? '无标题讨论',
      slug: attributes['slug'] as String?,
      commentCount: attributes['commentCount'] as int? ?? 0,
      participantCount: attributes['participantCount'] as int? ?? 0,
      createdAt: parseDate(attributes['createdAt'] as String?),
      lastPostedAt: parseDate(attributes['lastPostedAt'] as String?),
      userName: authorName ?? '匿名工程师',
      userAvatarUrl: authorAvatar,
      firstPostExcerpt: excerpt,
      tagIds: tagIdList,
      tagNames: tagNameList,
    );
  }
}

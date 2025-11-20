class NewsDetail {
  final String id;
  final String? title;
  final String? description;
  final String? content;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? totalViewed;
  final int? totalLike;
  final int? totalComment;
  final bool? isLiked;

  const NewsDetail({
    required this.id,
    this.title,
    this.description,
    this.content,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
    this.totalViewed,
    this.totalLike,
    this.totalComment,
    this.isLiked,
  });

  NewsDetail copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalViewed,
    int? totalLike,
    int? totalComment,
    bool? isLiked,
  }) {
    return NewsDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalViewed: totalViewed ?? this.totalViewed,
      totalLike: totalLike ?? this.totalLike,
      totalComment: totalComment ?? this.totalComment,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

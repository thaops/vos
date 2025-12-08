class News {
  final String id;
  final String? title;
  final String? description;
  final String? content;
  final String? thumbnailUrl;
  final String? image;
  final String? url;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? sourceName;
  final String? sourceUrl;
  final int? totalLike;
  final int? totalViewed;
  final int? totalComment;
  final String? creator;
  final String? categoryCode;

  const News({
    required this.id,
    this.title,
    this.description,
    this.content,
    this.thumbnailUrl,
    this.image,
    this.url,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.sourceName,
    this.sourceUrl,
    this.totalLike,
    this.totalViewed,
    this.totalComment,
    this.creator,
    this.categoryCode,
  });

  News copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? thumbnailUrl,
    String? image,
    String? url,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceName,
    String? sourceUrl,
    int? totalLike,
    int? totalViewed,
    int? totalComment,
    String? creator,
    String? categoryCode,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      image: image ?? this.image,
      url: url ?? this.url,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      totalLike: totalLike ?? this.totalLike,
      totalViewed: totalViewed ?? this.totalViewed,
      totalComment: totalComment ?? this.totalComment,
      creator: creator ?? this.creator,
      categoryCode: categoryCode ?? this.categoryCode,
    );
  }
}

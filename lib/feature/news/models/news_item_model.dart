class NewsItemModel {
  final String id;
  final String title;
  final String bannerImageUrl;
  final DateTime publishDate;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final String? content;
  final String? author;

  NewsItemModel({
    required this.id,
    required this.title,
    required this.bannerImageUrl,
    required this.publishDate,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.content,
    this.author,
  });

  String get formattedDate {
    final day = publishDate.day.toString().padLeft(2, '0');
    final month = publishDate.month.toString().padLeft(2, '0');
    final year = publishDate.year;
    final hour = publishDate.hour.toString().padLeft(2, '0');
    final minute = publishDate.minute.toString().padLeft(2, '0');
    return '$day-$month-$year $hour:$minute';
  }
}

